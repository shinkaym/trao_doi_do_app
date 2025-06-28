import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/data/datasources/local/auth_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/auth_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/get_access_token_usecase.dart';
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
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';
import '../modules/core_module.dart';
import '../modules/network_module.dart';

/// Authentication Module - Contains auth-related dependencies
class AuthModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

// =============================================================================
// AUTH DATA LAYER PROVIDERS
// =============================================================================

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthLocalDataSourceImpl(secureStorage);
});

final authRemoteDataSourceProvider = Provider.autoDispose<AuthRemoteDataSource>(
  (ref) {
    final dioClient = ref.watch(dioClientProvider);
    return AuthRemoteDataSourceImpl(dioClient);
  },
);

// =============================================================================
// AUTH DOMAIN LAYER PROVIDERS
// =============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource, localDataSource);
});

// =============================================================================
// AUTH USE CASES PROVIDERS
// =============================================================================

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final isLoggedInUseCaseProvider = Provider<IsLoggedInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return IsLoggedInUseCase(repository);
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshTokenUseCase(repository);
});

final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetMeUseCase(repository);
});

final getAccessTokenUseCaseProvider = Provider<GetAccessTokenUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetAccessTokenUseCase(repository);
});

// NEW: Profile update use case provider
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

// NEW: OTP operation use case providers
final sendOtpUseCaseProvider = Provider<SendOtpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SendOtpUseCase(repository);
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyOtpUseCase(repository);
});

// NEW: Account operation use case providers
final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignupUseCase(repository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return ResetPasswordUseCase(repository);
});

// =============================================================================
// AUTH PRESENTATION LAYER PROVIDER
// =============================================================================

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final isLoggedInUseCase = ref.watch(isLoggedInUseCaseProvider);
  final refreshTokenUseCase = ref.watch(refreshTokenUseCaseProvider);
  final getMeUseCase = ref.watch(getMeUseCaseProvider);
  final updateProfileUseCase = ref.watch(updateProfileUseCaseProvider);
  final sendOtpUseCase = ref.watch(sendOtpUseCaseProvider);
  final verifyOtpUseCase = ref.watch(verifyOtpUseCaseProvider);
  final signupUseCase = ref.watch(signupUseCaseProvider);
  final resetPasswordUseCase = ref.watch(resetPasswordUseCaseProvider);

  return AuthNotifier(
    loginUseCase,
    logoutUseCase,
    getCurrentUserUseCase,
    isLoggedInUseCase,
    refreshTokenUseCase,
    getMeUseCase,
    updateProfileUseCase,
    sendOtpUseCase,
    verifyOtpUseCase,
    signupUseCase,
    resetPasswordUseCase,
  );
});