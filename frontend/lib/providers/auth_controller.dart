import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user.dart';

const _keepAuthError = Object();

enum AuthErrorType { invalidCredentials, emailVerificationRequired, network, unknown }

/// State representing authentication status.
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isInitializing;
  final String? error;
  final AuthErrorType? errorType;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isInitializing = true,
    this.error,
    this.errorType,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isInitializing,
    Object? error = _keepAuthError,
    Object? errorType = _keepAuthError,
  }) => AuthState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    isInitializing: isInitializing ?? this.isInitializing,
    error: identical(error, _keepAuthError) ? this.error : error as String?,
    errorType: identical(errorType, _keepAuthError)
        ? this.errorType
        : errorType as AuthErrorType?,
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
    state = state.copyWith(isLoading: true, error: null, errorType: null);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
        errorType: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorType: _classifyError(e),
        error: _displayMessage(e),
      );
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null, errorType: null);
    try {
      final user = await _repo.loginWithGoogle();
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      _completeGoogleLogin(user);
    } catch (e) {
      _failGoogleLogin(e);
    }
  }

  Future<void> loginWithGoogleIdToken(String idToken) async {
    state = state.copyWith(isLoading: true, error: null, errorType: null);
    try {
      _completeGoogleLogin(await _repo.loginWithGoogleIdToken(idToken));
    } catch (e) {
      _failGoogleLogin(e);
    }
  }

  void _completeGoogleLogin(User user) {
    state = state.copyWith(
      user: user,
      isLoading: false,
      error: null,
      errorType: null,
    );
  }

  void _failGoogleLogin(Object error) {
    state = state.copyWith(
      isLoading: false,
      errorType: _classifyError(error),
      error: _displayMessage(error),
    );
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null, errorType: null);
    try {
      await _repo.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = state.copyWith(
        isLoading: false,
        error: null,
        errorType: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorType: _classifyError(e),
        error: _displayMessage(e),
      );
    }
  }

  Future<bool> verifyEmail({required String email, required String code}) async {
    state = state.copyWith(isLoading: true, error: null, errorType: null);
    try {
      await _repo.verifyEmail(email: email, code: code);
      state = state.copyWith(isLoading: false, error: null, errorType: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorType: _classifyError(e),
        error: _displayMessage(e),
      );
      return false;
    }
  }

  Future<bool> resendVerificationCode({required String email}) async {
    state = state.copyWith(isLoading: true, error: null, errorType: null);
    try {
      await _repo.resendVerificationCode(email: email);
      state = state.copyWith(isLoading: false, error: null, errorType: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorType: _classifyError(e),
        error: _displayMessage(e),
      );
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null, errorType: null);
    try {
      await _repo.deleteAccount();
      state = const AuthState(isInitializing: false);
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorType: _classifyError(error),
        error: _displayMessage(error),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repo.logout();
    } catch (error) {
      debugPrint('Logout error: $error');
    } finally {
      state = const AuthState(isInitializing: false);
    }
  }

  void handleSessionExpired() {
    state = const AuthState(isInitializing: false);
  }

  void clearError() {
    state = state.copyWith(error: null, errorType: null);
  }

  AuthErrorType _classifyError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('email verification is required')) {
      return AuthErrorType.emailVerificationRequired;
    }
    if (msg.contains('401') ||
        msg.contains('unauthorized') ||
        msg.contains('invalid email') ||
        msg.contains('invalid credential') ||
        msg.contains('không đúng') ||
        msg.contains('wrong password')) {
      return AuthErrorType.invalidCredentials;
    }
    if (error is SocketException ||
        msg.contains('socketexception') ||
        msg.contains('clientexception') ||
        msg.contains('connection') ||
        msg.contains('failed host lookup') ||
        msg.contains('network') ||
        msg.contains('offline')) {
      return AuthErrorType.network;
    }
    return AuthErrorType.unknown;
  }

  String _displayMessage(Object error) {
    final classified = _classifyError(error);
    if (classified == AuthErrorType.invalidCredentials) {
      return 'Email hoặc mật khẩu không đúng.';
    }
    if (classified == AuthErrorType.network) {
      return 'Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.';
    }
    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.toLowerCase().contains('exception') || raw.contains('{')) {
      return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
    return raw.isNotEmpty ? raw : 'Đã xảy ra lỗi. Vui lòng thử lại.';
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
