import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/domain/usecases/auth_usecases.dart';
import 'package:trao_doi_do_app/domain/usecases/get_me_usecase.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final User? user;
  final Failure? failure;
  final String? successMessage;
  final bool isInitialized;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.failure,
    this.successMessage,
    this.isInitialized = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    User? user,
    Failure? failure,
    String? successMessage,
    bool? isInitialized,
    bool clearUser = false,
    bool clearFailure = false,
    bool clearSuccessMessage = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: clearUser ? null : (user ?? this.user),
      failure: clearFailure ? null : (failure ?? this.failure),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final GetMeUseCase _getMeUseCase;

  AuthNotifier(
    this._loginUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._isLoggedInUseCase,
    this._refreshTokenUseCase,
    this._getMeUseCase,
  ) : super(const AuthState()) {
    _initializeAuth();
  }

  // Tối ưu: Khởi tạo auth một cách có trật tự
  Future<void> _initializeAuth() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);

    try {
      // Kiểm tra trạng thái đăng nhập
      final isLoggedInResult = await _isLoggedInUseCase();

      await isLoggedInResult.fold(
        (failure) async {
          state = state.copyWith(
            isLoading: false,
            isLoggedIn: false,
            isInitialized: true,
            clearUser: true,
          );
        },
        (isLoggedIn) async {
          if (isLoggedIn) {
            await _loadUserFromLocal();
          } else {
            state = state.copyWith(
              isLoading: false,
              isLoggedIn: false,
              isInitialized: true,
              clearUser: true,
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: false,
        isInitialized: true,
        clearUser: true,
      );
    }
  }

  // Tối ưu: Load user từ local storage trước
  Future<void> _loadUserFromLocal() async {
    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
          isInitialized: true,
          clearUser: true,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: user != null,
          user: user,
          isInitialized: true,
        );

        // Nếu có user, refresh thông tin từ server (background)
        if (user != null) {
          _refreshUserFromServer();
        }
      },
    );
  }

  // Tối ưu: Refresh user từ server trong background
  Future<void> _refreshUserFromServer() async {
    try {
      final result = await _getMeUseCase();

      result.fold(
        (failure) {
          // Silent fail - không làm gì để không ảnh hưởng UX
          print('Background refresh failed: ${failure.message}');
        },
        (user) {
          // Chỉ update nếu có thay đổi
          if (state.user != user) {
            state = state.copyWith(user: user);
          }
        },
      );
    } catch (e) {
      print('Background refresh error: $e');
    }
  }

  // Tối ưu: Get user info với loading state riêng
  Future<void> getMe({bool showLoading = true}) async {
    if (showLoading) {
      state = state.copyWith(isLoading: true, clearFailure: true);
    }

    final result = await _getMeUseCase();

    result.fold(
      (failure) {
        if (showLoading) {
          state = state.copyWith(isLoading: false, failure: failure);
        }
      },
      (user) {
        state = state.copyWith(
          isLoading: showLoading ? false : state.isLoading,
          user: user,
          isLoggedIn: true,
          successMessage: 'Cập nhật thông tin thành công!',
        );
      },
    );
  }

  // Tối ưu: Refresh user info không loading
  Future<void> refreshUserInfo() async {
    await getMe(showLoading: false);
  }

  Future<void> login({
    required String email,
    required String password,
    String device = 'mobile',
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

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
          isInitialized: true,
        );
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    await _logoutUseCase();

    // Luôn clear state dù API có fail hay không
    state = const AuthState(
      isInitialized: true,
      successMessage: 'Đăng xuất thành công!',
    );
  }

  Future<void> refreshToken() async {
    final result = await _refreshTokenUseCase();

    result.fold(
      (failure) {
        // Token refresh failed, logout user
        state = const AuthState(isInitialized: true, isLoggedIn: false);
      },
      (user) {
        // Refresh thành công
        state = state.copyWith(user: user, isLoggedIn: user != null);
      },
    );
  }

  void clearError() {
    if (state.failure != null) {
      state = state.copyWith(clearFailure: true);
    }
  }

  void clearSuccess() {
    if (state.successMessage != null) {
      state = state.copyWith(clearSuccessMessage: true);
    }
  }

  // Tối ưu: Reset toàn bộ state
  void reset() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final isLoggedInUseCase = ref.watch(isLoggedInUseCaseProvider);
  final refreshTokenUseCase = ref.watch(refreshTokenUseCaseProvider);
  final getMeUseCase = ref.watch(getMeUseCaseProvider);

  return AuthNotifier(
    loginUseCase,
    logoutUseCase,
    getCurrentUserUseCase,
    isLoggedInUseCase,
    refreshTokenUseCase,
    getMeUseCase,
  );
});
