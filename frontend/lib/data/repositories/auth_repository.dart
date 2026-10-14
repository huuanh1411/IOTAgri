import '../models/user.dart';
import '../../services/api_service.dart';

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
    return _toScreenUser(session.id, session.fullName, session.email, session.role);
  }

  Future<User> login({required String email, required String password}) async {
    final response = await _api.login(email, password);
    final token = response['accessToken'];
    final session = token is String ? _api.userFromAccessToken(token) : null;
    if (session == null) throw Exception('Không đọc được phiên đăng nhập.');
    return _toScreenUser(session.id, session.fullName, session.email, session.role);
  }

  Future<User> signUp({required String fullName, required String email, required String password}) async {
    await _api.register(email, password, fullName);
    return login(email: email, password: password);
  }

  Future<void> logout() => _api.logout();

  User _toScreenUser(String id, String fullName, String email, String role) => User(
        id: id,
        fullName: fullName,
        email: email,
        role: role,
        plan: 'Pro',
      );
}
