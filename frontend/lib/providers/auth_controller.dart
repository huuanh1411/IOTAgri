// lib/providers/auth_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user.dart';

const _keepAuthError = Object();

/// State representing authentication status.
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isInitializing;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isInitializing = true,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isInitializing,
    Object? error = _keepAuthError,
  }) => AuthState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    isInitializing: isInitializing ?? this.isInitializing,
    error: identical(error, _keepAuthError) ? this.error : error as String?,
  );
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthController(this._repo) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final current = await _repo.getCurrentUser();
      if (current != null) {
        state = state.copyWith(user: current);
      }
    } finally {
      state = state.copyWith(isInitializing: false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: _displayMessage(e));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: _displayMessage(e));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repo.logout();
    state = const AuthState(isInitializing: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _displayMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.read(authRepositoryProvider));
  },
);

// UI helper provider for the selected tab (0 = login, 1 = sign‑up)
final authTabProvider = StateProvider<int>((ref) => 0);
