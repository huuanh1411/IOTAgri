import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isDisposed = false;
  String? _errorMessage;
  late final VoidCallback _sessionExpiredHandler;

  AuthProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService() {
    _sessionExpiredHandler = _handleSessionExpired;
    ApiService.onSessionExpired = _sessionExpiredHandler;
    initialize();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // ==================== MOCK DATA - XÓA KHI CÓ BACKEND THẬT ====================

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _user = null;
    _isInitialized = true;
    if (!_isDisposed) notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // === MOCK: Phân biệt role dựa trên email ===
    final isAdminEmail = email.toLowerCase() == 'admin@aerogreen.com';

    _user = User(
      id: isAdminEmail ? 'mock_admin_001' : 'mock_user_001',
      email: email,
      fullName: isAdminEmail ? 'Quản trị viên' : 'Nguyễn Văn Test',
      role: isAdminEmail ? 'admin' : 'user',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register(String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // === MOCK: User mới đăng ký luôn là role 'user' ===
    _user = User(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      role: 'user',
    );

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _user = null;
    _isLoading = false;
    notifyListeners();
  }

  void _handleSessionExpired() {
    if (_user == null) return;
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (identical(ApiService.onSessionExpired, _sessionExpiredHandler)) {
      ApiService.onSessionExpired = null;
    }
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

// ==================== KẾT THÚC MOCK DATA ====================


// ==================== CODE CŨ - GIỮ NGUYÊN 100% ====================
/*

  Future<void> initialize() async {
    try {
      _user = await _apiService.restoreSession();
    } catch (_) {
      _user = null;
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

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _formatLoginError(e);
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
      return await login(email, password);
    } catch (e) {
      _isLoading = false;
      _errorMessage = _formatLoginError(e);
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
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      debugPrint('Logout error: $e');
    } finally {
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (identical(ApiService.onSessionExpired, _sessionExpiredHandler)) {
      ApiService.onSessionExpired = null;
    }
    super.dispose();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  */
// ==================== KẾT THÚC CODE CŨ ====================
}