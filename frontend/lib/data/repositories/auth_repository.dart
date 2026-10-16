import '../models/user.dart';
import '../../services/api_service.dart';
import '../../models/user.dart' as api_models;

/// Authentication boundary for the Material/Riverpod application shell.
///
/// It deliberately delegates token handling to [ApiService], so protected
/// device and pump calls use the same persisted JWT as the login screen.
class AuthRepository {
  final ApiService _api;

  AuthRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<User?> getCurrentUser() async {
    final session = await _api.restoreSession();
    if (session == null) return null;
    return _loadCurrentProfile(session);
  }

  Future<User> login({required String email, required String password}) async {
    final response = await _api.login(email, password);
    final token = response['accessToken'];
    final session = token is String ? _api.userFromAccessToken(token) : null;
    if (session == null) throw Exception('Không đọc được phiên đăng nhập.');
    return _loadCurrentProfile(session);
  }

  Future<User> signUp({required String fullName, required String email, required String password}) async {
    await _api.register(email, password, fullName);
    return login(email: email, password: password);
  }

  Future<void> logout() => _api.logout();

  Future<User> _loadCurrentProfile(api_models.User session) async {
    try {
      final profile = await _api.getProfile();
      final roles = (profile['roles'] as List<dynamic>? ?? const [])
          .map((role) => role.toString());
      return _toScreenUser(
        profile['id'] as String? ?? session.id,
        profile['fullName'] as String? ?? session.fullName,
        profile['email'] as String? ?? session.email,
        roles.contains('Admin') ? 'admin' : 'user',
      );
    } catch (_) {
      // Retain an authenticated offline session when the profile API is unavailable.
      return _toScreenUser(
        session.id,
        session.fullName,
        session.email,
        session.role,
      );
    }
  }

  User _toScreenUser(String id, String fullName, String email, String role) => User(
        id: id,
        fullName: fullName,
        email: email,
        role: role,
        plan: 'Pro',
      );
}
