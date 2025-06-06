import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponse>> login(LoginRequest request);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> refreshToken(); // Sửa return type
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isLoggedIn();
}