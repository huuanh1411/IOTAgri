import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/google_sign_in_service.dart';
import '../services/session_timeout_manager.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isDisposed = false;
  String? _errorMessage;
  final VoidCallback? _onSessionExpired;
  late final VoidCallback _sessionExpiredHandler;
  late final SessionTimeoutManager _sessionTimeoutManager;

  AuthProvider({
    ApiService? apiService,
    User? initialUser,
    VoidCallback? onSessionExpired,
  })
    : _apiService = apiService ?? ApiService(),
      _user = initialUser,
      _onSessionExpired = onSessionExpired {
    _sessionExpiredHandler = _handleSessionExpired;
    ApiService.onSessionExpired = _sessionExpiredHandler;
    
    _sessionTimeoutManager = SessionTimeoutManager(
      onRefreshToken: _handleTokenRefresh,
      onSessionExpired: _handleSessionExpired,
      onSessionWarning: _handleSessionWarning,
    );
    
    initialize();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  SessionTimeoutManager get sessionTimeoutManager => _sessionTimeoutManager;
  VoidCallback? onSessionWarningCallback;

  Future<void> initialize() async {
    try {
      _user = await _apiService.restoreSession() ?? _user;
      if (_user != null) {
        await _sessionTimeoutManager.initialize();
      }
    } catch (_) {
      // Keep the authenticated Riverpod user when legacy session restore fails.
    } finally {
      _isInitialized = true;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.login(email, password);
      final accessToken = data['accessToken'];
      final user = accessToken is String
          ? _apiService.userFromAccessToken(accessToken)
          : null;
      if (user == null) throw Exception('Invalid access token');
      _user = user;
      
      // Initialize session timeout manager with new token
      await _sessionTimeoutManager.initialize();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = _formatLoginError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final idToken = await GoogleSignInService().signInForIdToken();
      if (idToken == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final data = await _apiService.loginWithGoogleIdToken(idToken);
      final accessToken = data['accessToken'];
      final user = accessToken is String
          ? _apiService.userFromAccessToken(accessToken)
          : null;
      if (user == null) throw Exception('Invalid access token');
      _user = user;
      
      // Initialize session timeout manager with new token
      await _sessionTimeoutManager.initialize();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = _formatLoginError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.register(email, password, fullName);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = _formatLoginError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmail(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.verifyEmail(email, code);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendVerificationCode(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.resendVerificationCode(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  bool _isNetworkError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('clientexception') ||
        message.contains('socketexception') ||
        message.contains('failed to fetch') ||
        message.contains('connection refused') ||
        message.contains('timed out') ||
        message.contains('failed host lookup');
  }

  String _formatLoginError(Object error) {
    final message = error.toString();
    if (_isNetworkError(error)) {
      return 'Không thể kết nối máy chủ. Vui lòng thử lại sau.';
    }
    if (message.contains('Email hoặc mật khẩu')) {
      return 'Email hoặc mật khẩu không đúng.';
    }
    if (message.contains('already been registered') ||
        message.contains('đã được đăng ký')) {
      return 'Email này đã được đăng ký.';
    }
    return 'Đăng nhập thất bại. Vui lòng thử lại.';
  }

  void _handleSessionExpired() {
    if (_user == null) return;
    _user = null;
    notifyListeners();
    _onSessionExpired?.call();
  }

  void _handleSessionWarning() {
    onSessionWarningCallback?.call();
  }

  Future<void> _handleTokenRefresh() async {
    // Trigger a dummy authenticated request to force token refresh
    // The API service handles automatic token refresh internally
    try {
      await _apiService.getProfile();
      // After successful refresh, update the session timeout manager
      final accessToken = await _apiService.getCurrentAccessToken();
      if (accessToken != null) {
        await _sessionTimeoutManager.updateTokenExpiry(accessToken);
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      // If refresh fails, the session will be marked as expired
      // and the user will need to log in again
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (error) {
      debugPrint('Logout error: $error');
    } finally {
      await _sessionTimeoutManager.clear();
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tải hồ sơ đầy đủ (số điện thoại, vai trò) từ API. Trả về false khi không tải được.
  Future<bool> loadProfile() async {
    try {
      final data = await _apiService.getProfile();
      _user = User.fromProfileJson(data);
      if (!_isDisposed) notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Profile load error: $error');
      return false;
    }
  }

  /// Cập nhật họ tên và số điện thoại. Trả về false và đặt errorMessage khi thất bại.
  Future<bool> updateProfile({
    required String fullName,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      _user = User.fromProfileJson(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (identical(ApiService.onSessionExpired, _sessionExpiredHandler)) {
      ApiService.onSessionExpired = null;
    }
    _sessionTimeoutManager.dispose();
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
