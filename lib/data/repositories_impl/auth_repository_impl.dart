import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/local/auth_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:trao_doi_do_app/data/models/user_model.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, LoginResponse>> login(LoginRequest request) async {
    try {
      final requestModel = LoginRequestModel.fromEntity(request);
      final response = await _remoteDataSource.login(requestModel);

      // Lưu tokens và user info vào local storage
      await _localDataSource.saveAccessToken(response.jwt);
      await _localDataSource.saveRefreshToken(response.refreshToken);
      await _saveUserInfo(response.user);

      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Gọi API logout trước (với error handling)
      try {
        await _remoteDataSource.logout();
      } on ServerException {
      } catch (e) {}

      // Clear local storage (luôn thực hiện dù API fail)
      await _localDataSource.clearTokens();
      await _localDataSource.clearUserInfo();

      return const Right(null);
    } catch (e) {
      // Nếu clear local storage fail, vẫn cố gắng clear
      try {
        await _localDataSource.clearTokens();
        await _localDataSource.clearUserInfo();
      } catch (clearError) {}
      return Left(ServerFailure('Lỗi khi đăng xuất: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> refreshToken() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return const Left(ValidationFailure('Không tìm thấy refresh token'));
      }

      final response = await _remoteDataSource.refreshToken(refreshToken);

      // Cập nhật access token mới (chỉ có jwt)
      await _localDataSource.saveAccessToken(response.jwt);
      // Refresh token không đổi, giữ nguyên

      // Lấy user hiện tại từ local storage
      final currentUser = await getCurrentUser();
      return currentUser.fold(
        (failure) => Left(failure),
        (user) => Right(user),
      );
    } on ServerException catch (e) {
      // Nếu refresh token fail, clear tokens
      await _localDataSource.clearTokens();
      await _localDataSource.clearUserInfo();
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      // Clear tokens nếu có lỗi không xác định
      await _localDataSource.clearTokens();
      await _localDataSource.clearUserInfo();
      return Left(ServerFailure('Lỗi không xác định khi refresh token: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userJson = await _localDataSource.getUserInfo();
      if (userJson == null || userJson.isEmpty) {
        return const Right(null);
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);
      return Right(user);
    } on FormatException catch (e) {
      // JSON parse error, clear corrupted data
      await _localDataSource.clearUserInfo();
      return Left(ServerFailure('Dữ liệu người dùng bị lỗi: $e'));
    } catch (e) {
      return Left(ServerFailure('Lỗi khi lấy thông tin người dùng: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final accessToken = await _localDataSource.getAccessToken();
      final refreshToken = await _localDataSource.getRefreshToken();
      return Right(
        accessToken != null &&
            refreshToken != null &&
            accessToken.isNotEmpty &&
            refreshToken.isNotEmpty,
      );
    } catch (e) {
      return Left(ServerFailure('Lỗi khi kiểm tra trạng thái đăng nhập: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      final response = await _remoteDataSource.getMe();

      // Cập nhật user info trong local storage
      await _saveUserInfo(response.user);

      return Right(response.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Lỗi không xác định khi lấy thông tin người dùng: $e'),
      );
    }
  }

  // Helper methods for user info storage
  Future<void> _saveUserInfo(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final userJson = jsonEncode(userModel.toJson());
      await _localDataSource.saveUserInfo(userJson);
    } catch (e) {
      // Don't throw error, just log it
    }
  }
}
