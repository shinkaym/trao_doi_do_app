import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/auth_request.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/domain/usecases/get_current_user_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_me_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/is_logged_in_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/login_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/logout_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/refresh_token_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/reset_password_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/send_otp_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/signup_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_profile_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/verify_otp_usecase.dart';

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final User? user;
  final Failure? failure;
  final String? successMessage;
  final bool isInitialized;
  final bool forceLogout; // Thêm flag để force logout
  // NEW: OTP related states
  final String? verifyToken;
  final bool isOtpSent;
  final bool isOtpVerified;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.failure,
    this.successMessage,
    this.isInitialized = false,
    this.forceLogout = false,
    this.verifyToken,
    this.isOtpSent = false,
    this.isOtpVerified = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    User? user,
    Failure? failure,
    String? successMessage,
    bool? isInitialized,
    bool? forceLogout,
    String? verifyToken,
    bool? isOtpSent,
    bool? isOtpVerified,
    bool clearUser = false,
    bool clearFailure = false,
    bool clearSuccessMessage = false,
    bool clearVerifyToken = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: clearUser ? null : (user ?? this.user),
      failure: clearFailure ? null : (failure ?? this.failure),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      isInitialized: isInitialized ?? this.isInitialized,
      forceLogout: forceLogout ?? this.forceLogout,
      verifyToken: clearVerifyToken ? null : (verifyToken ?? this.verifyToken),
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isLoggedIn == other.isLoggedIn &&
          user == other.user &&
          failure == other.failure &&
          successMessage == other.successMessage &&
          isInitialized == other.isInitialized &&
          forceLogout == other.forceLogout &&
          verifyToken == other.verifyToken &&
          isOtpSent == other.isOtpSent &&
          isOtpVerified == other.isOtpVerified;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      isLoggedIn.hashCode ^
      user.hashCode ^
      failure.hashCode ^
      successMessage.hashCode ^
      isInitialized.hashCode ^
      forceLogout.hashCode ^
      verifyToken.hashCode ^
      isOtpSent.hashCode ^
      isOtpVerified.hashCode;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final IsLoggedInUseCase _isLoggedInUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final GetMeUseCase _getMeUseCase;
  // NEW: Additional use cases
  final UpdateProfileUseCase _updateProfileUseCase;
  final SendOtpUseCase _sendOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final SignupUseCase _signupUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  AuthNotifier(
    this._loginUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._isLoggedInUseCase,
    this._refreshTokenUseCase,
    this._getMeUseCase,
    this._updateProfileUseCase,
    this._sendOtpUseCase,
    this._verifyOtpUseCase,
    this._signupUseCase,
    this._resetPasswordUseCase,
  ) : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true);

    try {
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
            // Đã đăng nhập, load user và verify token
            await _loadAndVerifyUser();
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
        failure: ServerFailure('Lỗi khởi tạo: $e'),
      );
    }
  }

  /// Load user từ local và verify bằng cách gọi API getMe
  Future<void> _loadAndVerifyUser() async {
    final localUserResult = await _getCurrentUserUseCase();

    await localUserResult.fold(
      (failure) async {
        // Không có user local hoặc lỗi, logout
        await _clearAuthState();
      },
      (localUser) async {
        if (localUser == null) {
          await _clearAuthState();
          return;
        }

        // Set user local trước, sau đó verify với server
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          user: localUser,
          isInitialized: true,
        );

        // Verify token bằng cách gọi getMe (background)
        _verifyTokenInBackground();
      },
    );
  }

  /// Verify token trong background, không ảnh hưởng UI loading
  Future<void> _verifyTokenInBackground() async {
    try {
      final result = await _getMeUseCase();

      result.fold(
        (failure) {
          // Token không hợp lệ, logout user
          _clearAuthState();
        },
        (serverUser) {
          // Token hợp lệ, update user info nếu có thay đổi
          if (_shouldUpdateUser(state.user, serverUser)) {
            state = state.copyWith(user: serverUser);
          }
        },
      );
    } catch (e) {
      // Network error hoặc lỗi khác, giữ nguyên state hiện tại
      // Log error nhưng không logout user
    }
  }

  bool _shouldUpdateUser(User? currentUser, User serverUser) {
    if (currentUser == null) return true;

    return currentUser.id != serverUser.id ||
        currentUser.email != serverUser.email ||
        currentUser.fullName != serverUser.fullName ||
        currentUser.avatar != serverUser.avatar ||
        currentUser.goodPoint != serverUser.goodPoint ||
        currentUser.status != serverUser.status;
  }

  Future<void> _clearAuthState() async {
    state = state.copyWith(
      isLoading: false,
      isLoggedIn: false,
      isInitialized: true,
      clearUser: true,
      forceLogout: true, // Set force logout
    );

    // Reset force logout sau một frame để tránh infinite loop
    await Future.delayed(Duration.zero);
    if (mounted) {
      state = state.copyWith(forceLogout: false);
    }
  }

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
          successMessage: showLoading ? 'Cập nhật thông tin thành công!' : null,
        );
      },
    );
  }

  /// Refresh user info từ server (cho pull-to-refresh)
  Future<void> refreshUserInfo() async {
    await getMe(showLoading: false);
  }

  /// Handle khi token expired từ interceptor - QUAN TRỌNG
  void handleTokenExpired() {
    print('🚨 AuthNotifier: handleTokenExpired called');

    state = state.copyWith(
      isInitialized: true,
      isLoggedIn: false,
      clearUser: true,
      forceLogout: true,
      failure: ServerFailure(
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      ),
    );

    // Reset force logout sau một frame
    Future.delayed(Duration.zero).then((_) {
      if (mounted) {
        state = state.copyWith(forceLogout: false);
      }
    });
  }

  Future<void> login({
    required String email,
    required String password,
    String device = 'mobile',
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    final request = LoginRequest(
      device: device,
      email: email.trim(),
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

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        // Log error nhưng vẫn clear local state
        state = const AuthState(
          isInitialized: true,
          successMessage: 'Đăng xuất thành công!',
        );
      },
      (_) {
        state = const AuthState(
          isInitialized: true,
          successMessage: 'Đăng xuất thành công!',
        );
      },
    );
  }

  /// IMPROVED: Better refresh token handling
  Future<void> refreshToken() async {
    print('🔄 AuthNotifier: refreshToken called');

    final result = await _refreshTokenUseCase();

    result.fold(
      (failure) {
        print('❌ AuthNotifier: Token refresh failed - ${failure.message}');

        // Token refresh failed, clear auth state và force logout
        state = state.copyWith(
          isInitialized: true,
          isLoggedIn: false,
          clearUser: true,
          forceLogout: true,
          failure: ServerFailure('Phiên đăng nhập đã hết hạn'),
        );

        // Reset force logout sau một frame
        Future.delayed(Duration.zero).then((_) {
          if (mounted) {
            state = state.copyWith(forceLogout: false);
          }
        });
      },
      (user) {
        print('✅ AuthNotifier: Token refresh successful');
        state = state.copyWith(
          user: user,
          isLoggedIn: user != null,
          clearFailure: true,
        );
      },
    );
  }

  // NEW: Update profile method
  Future<void> updateProfile({
    required int userId,
    String? address,
    String? avatar,
    required String fullName,
    required String major,
    required String phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    final request = UpdateProfileRequest(
      address: address,
      avatar: avatar,
      fullName: fullName,
      major: major,
      phoneNumber: phoneNumber,
    );

    final result = await _updateProfileUseCase.execute(userId, request);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (updatedUser) {
        state = state.copyWith(
          isLoading: false,
          user: updatedUser,
          successMessage: 'Cập nhật thông tin thành công!',
        );
      },
    );
  }

  // NEW: Send OTP method
  Future<void> sendOtp({
    required String email,
    required String purpose, // "activeAccount" or "resetPassword"
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      isOtpSent: false,
    );

    final request = SendOtpRequest(email: email, purpose: purpose);

    final result = await _sendOtpUseCase.execute(request);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          failure: failure,
          isOtpSent: false,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          isOtpSent: true,
          successMessage: 'Mã OTP đã được gửi đến email của bạn!',
        );
      },
    );
  }

  // NEW: Verify OTP method
  Future<void> verifyOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      isOtpVerified: false,
      clearVerifyToken: true,
    );

    final request = VerifyOtpRequest(email: email, otp: otp, purpose: purpose);

    final result = await _verifyOtpUseCase.execute(request);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          failure: failure,
          isOtpVerified: false,
        );
      },
      (verifyToken) {
        state = state.copyWith(
          isLoading: false,
          isOtpVerified: true,
          verifyToken: verifyToken,
          successMessage: 'Xác thực OTP thành công!',
        );
      },
    );
  }

  // NEW: Signup method
  Future<void> signup({
    required String email,
    required String fullName,
    required String password,
    required String phoneNumber,
    required String rePassword,
    required String verifyToken,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    final request = SignupRequest(
      email: email,
      fullName: fullName,
      password: password,
      phoneNumber: phoneNumber,
      rePassword: rePassword,
      verifyToken: verifyToken,
    );

    final result = await _signupUseCase.execute(request);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Đăng ký tài khoản thành công!',
          // Reset OTP states after successful signup
          isOtpSent: false,
          isOtpVerified: false,
          clearVerifyToken: true,
        );
      },
    );
  }

  // NEW: Reset password method
  Future<void> resetPassword({
    required String email,
    required String password,
    required String rePassword,
    required String verifyToken,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);

    final request = ResetPasswordRequest(
      email: email,
      password: password,
      rePassword: rePassword,
      verifyToken: verifyToken,
    );

    final result = await _resetPasswordUseCase.execute(request);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Đặt lại mật khẩu thành công!',
          // Reset OTP states after successful password reset
          isOtpSent: false,
          isOtpVerified: false,
          clearVerifyToken: true,
        );
      },
    );
  }

  // NEW: Reset OTP states (useful for resetting forms)
  void resetOtpStates() {
    state = state.copyWith(
      isOtpSent: false,
      isOtpVerified: false,
      clearVerifyToken: true,
      clearFailure: true,
      clearSuccessMessage: true,
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

  void reset() {
    state = const AuthState();
  }
}
