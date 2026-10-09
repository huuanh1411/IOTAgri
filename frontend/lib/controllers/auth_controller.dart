// lib/controllers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Auth state – holds the current user, loading flag and possible error message.
// ---------------------------------------------------------------------------
class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({User? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// Auth controller – mock implementation using SharedPreferences.
// ---------------------------------------------------------------------------
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AuthState()) {
    _loadPersistedUser();
  }

  // Load the persisted user on start.
  Future<void> _loadPersistedUser() async {
    final u = await _repo.getCurrentUser();
    if (u != null) {
      state = state.copyWith(user: u);
    }
  }

  // Mock credentials – hard‑coded user.
  static const _mockEmail = 'mira@aerogreen.app';
  static const _mockPassword = 'Password123'; // >= 8 chars
  static const _mockFullName = 'Mira Patel';
  static const _mockPlan = 'Pro';

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1)); // simulate network
    if (email == _mockEmail && password == _mockPassword) {
      final user = User(fullName: _mockFullName, email: email, plan: _mockPlan);
      await _repo.persistUser(user);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: 'Email hoặc mật khẩu không chính xác.');
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1)); // simulate network
    // In a real app we would check for existing user – here we always succeed.
    final user = User(fullName: fullName, email: email, plan: 'Free');
    await _repo.persistUser(user);
    state = state.copyWith(user: user, isLoading: false);
    return true;
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    await _repo.clearUser();
    state = const AuthState();
  }
}

// Provider for the controller.
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(AuthRepository());
});
