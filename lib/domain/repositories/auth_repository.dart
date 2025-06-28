import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/request/auth_request.dart';
import 'package:trao_doi_do_app/domain/entities/response/auth_response.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login(LoginRequest request);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> refreshToken();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isLoggedIn();
  Future<Either<Failure, User>> getMe();
  Future<Either<Failure, String?>> getAccessToken();

  Future<Either<Failure, User>> updateProfile(
    int userId,
    UpdateProfileRequest request,
  );

  Future<Either<Failure, void>> sendOtp(SendOtpRequest request);
  Future<Either<Failure, String>> verifyOtp(VerifyOtpRequest request);

  Future<Either<Failure, void>> signup(SignupRequest request);
  Future<Either<Failure, void>> resetPassword(ResetPasswordRequest request);
}
