import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages session timeout and automatic token refresh
class SessionTimeoutManager {
  static const String _accessTokenKey = 'access_token';
  static const String _tokenExpiryKey = 'token_expiry';
  
  // Warning threshold: show warning 2 minutes before expiry
  static const Duration _warningThreshold = Duration(minutes: 2);
  
  // Refresh threshold: attempt refresh 1 minute before expiry
  static const Duration _refreshThreshold = Duration(minutes: 1);
  
  final FlutterSecureStorage _storage;
  final bool _allowWebStorageFallback;
  Timer? _expiryCheckTimer;
  Timer? _warningTimer;
  Timer? _refreshTimer;
  DateTime? _tokenExpiry;
  bool _isDisposed = false;
  
  // Callbacks
  final Future<void> Function() onRefreshToken;
  final VoidCallback onSessionExpired;
  final VoidCallback onSessionWarning;

  SessionTimeoutManager({
    FlutterSecureStorage? storage,
    bool? allowWebStorageFallback,
    required this.onRefreshToken,
    required this.onSessionExpired,
    required this.onSessionWarning,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _allowWebStorageFallback = allowWebStorageFallback ?? kIsWeb;

  static String _webFallbackKey(String key) => 'iotagri.auth.$key';

  Future<String?> _readToken(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null || !_allowWebStorageFallback) return value;
    } catch (error) {
      if (!_allowWebStorageFallback) rethrow;
      debugPrint('Secure token storage unavailable; using web fallback: $error');
    }

    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_webFallbackKey(key));
  }

  Future<void> _saveTokenExpiry(DateTime expiry) async {
    try {
      await _storage.write(key: _tokenExpiryKey, value: expiry.toIso8601String());
      if (_allowWebStorageFallback) {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_webFallbackKey(_tokenExpiryKey));
      }
    } catch (error) {
      if (!_allowWebStorageFallback) rethrow;
      debugPrint('Secure token storage unavailable; using web fallback: $error');
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _webFallbackKey(_tokenExpiryKey),
        expiry.toIso8601String(),
      );
    }
    _tokenExpiry = expiry;
  }

  Future<void> _clearTokenExpiry() async {
    try {
      await _storage.delete(key: _tokenExpiryKey);
    } catch (_) {
      if (!_allowWebStorageFallback) rethrow;
    }
    if (_allowWebStorageFallback) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_webFallbackKey(_tokenExpiryKey));
    }
    _tokenExpiry = null;
  }

  /// Extract expiry time from JWT access token
  DateTime? _extractExpiryFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      
      final expiresAt = payload['exp'];
      if (expiresAt is! num) return null;
      
      return DateTime.fromMillisecondsSinceEpoch(expiresAt.toInt() * 1000);
    } catch (_) {
      return null;
    }
  }

  /// Initialize the session timeout manager with current token
  Future<void> initialize() async {
    if (_isDisposed) return;
    
    final accessToken = await _readToken(_accessTokenKey);
    if (accessToken == null) {
      _cancelAllTimers();
      return;
    }

    final expiry = _extractExpiryFromToken(accessToken);
    if (expiry == null) {
      debugPrint('Could not extract expiry from access token');
      return;
    }

    await _saveTokenExpiry(expiry);
    _scheduleTimers(expiry);
  }

  /// Update token expiry after token refresh
  Future<void> updateTokenExpiry(String newAccessToken) async {
    if (_isDisposed) return;
    
    final expiry = _extractExpiryFromToken(newAccessToken);
    if (expiry == null) {
      debugPrint('Could not extract expiry from new access token');
      return;
    }

    await _saveTokenExpiry(expiry);
    _cancelAllTimers();
    _scheduleTimers(expiry);
    
    debugPrint('Token expiry updated. New expiry: $expiry');
  }

  void _scheduleTimers(DateTime expiry) {
    final now = DateTime.now();
    final timeUntilExpiry = expiry.difference(now);

    if (timeUntilExpiry <= Duration.zero) {
      // Token already expired
      onSessionExpired();
      return;
    }

    // Schedule warning timer
    final warningDelay = timeUntilExpiry - _warningThreshold;
    if (warningDelay > Duration.zero) {
      _warningTimer = Timer(warningDelay, () {
        if (!_isDisposed) {
          onSessionWarning();
        }
      });
    } else {
      // Already past warning threshold, show warning immediately
      _warningTimer = Timer(Duration.zero, () {
        if (!_isDisposed) {
          onSessionWarning();
        }
      });
    }

    // Schedule refresh timer
    final refreshDelay = timeUntilExpiry - _refreshThreshold;
    if (refreshDelay > Duration.zero) {
      _refreshTimer = Timer(refreshDelay, () async {
        if (!_isDisposed) {
          try {
            await onRefreshToken();
          } catch (e) {
            debugPrint('Token refresh failed: $e');
            onSessionExpired();
          }
        }
      });
    }

    // Schedule expiry check timer
    _expiryCheckTimer = Timer(timeUntilExpiry, () {
      if (!_isDisposed) {
        onSessionExpired();
      }
    });

    debugPrint('Session timeout timers scheduled. Expires at: $expiry');
  }

  void _cancelAllTimers() {
    _warningTimer?.cancel();
    _warningTimer = null;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _expiryCheckTimer?.cancel();
    _expiryCheckTimer = null;
  }

  /// Clear all timers and token expiry data
  Future<void> clear() async {
    _cancelAllTimers();
    await _clearTokenExpiry();
  }

  /// Get remaining time until token expiry
  Duration? getTimeUntilExpiry() {
    if (_tokenExpiry == null) return null;
    final now = DateTime.now();
    final remaining = _tokenExpiry!.difference(now);
    return remaining > Duration.zero ? remaining : Duration.zero;
  }

  /// Check if session is about to expire (within warning threshold)
  bool isAboutToExpire() {
    final remaining = getTimeUntilExpiry();
    if (remaining == null) return false;
    return remaining <= _warningThreshold;
  }

  void dispose() {
    _isDisposed = true;
    _cancelAllTimers();
  }
}
