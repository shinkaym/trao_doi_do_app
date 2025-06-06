import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/domain/usecases/auth_usecases.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final User? user;
  final Failure? failure;
  final String? successMessage;

  AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.failure,
    this.successMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    User? user,
    Failure? failure,
    String? successMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      failure: failure,
      successMessage: successMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;

  AuthNotifier(
    this._loginUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._isLoggedInUseCase,
    this._refreshTokenUseCase,
  ) : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final isLoggedInResult = await _isLoggedInUseCase();

    await isLoggedInResult.fold(
      (failure) async {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
          failure: failure,
        );
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          await _loadCurrentUser();
        } else {
          state = state.copyWith(isLoading: false, isLoggedIn: false);
        }
      },
    );
  }

  Future<void> _loadCurrentUser() async {
    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
          failure: failure,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: user != null,
          user: user,
        );
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
    String device = 'mobile',
  }) async {
    state = state.copyWith(isLoading: true, failure: null);

    final request = LoginRequest(
      device: device,
      email: email,
      password: password,
    );

    final result = await _loginUseCase(request);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (loginResponse) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          user: loginResponse.user,
          successMessage: 'Đăng nhập thành công!',
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, failure: null);

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        // Dù logout API fail, vẫn clear state
        state = AuthState(
          failure: failure,
          successMessage: 'Đăng xuất thành công!', // Vẫn thông báo thành công
        );
      },
      (_) {
        state = AuthState(successMessage: 'Đăng xuất thành công!');
      },
    );
  }

  Future<void> refreshToken() async {
    final result = await _refreshTokenUseCase();

    result.fold(
      (failure) {
        // Token refresh failed, logout user
        state = AuthState(failure: failure);
      },
      (user) {
        // Refresh thành công, cập nhật user
        state = state.copyWith(user: user, isLoggedIn: user != null);
      },
    );
  }

  void clearError() {
    state = state.copyWith(failure: null);
  }

  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final isLoggedInUseCase = ref.watch(isLoggedInUseCaseProvider);
  final refreshTokenUseCase = ref.watch(refreshTokenUseCaseProvider);

  return AuthNotifier(
    loginUseCase,
    logoutUseCase,
    getCurrentUserUseCase,
    isLoggedInUseCase,
    refreshTokenUseCase,
  );
});
