import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      return Left(ServerFailure('Lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Gọi API logout trước
      try {
        await _remoteDataSource.logout();
      } on ServerException catch (e) {
        // Log error nhưng vẫn tiếp tục clear local data
        print('Logout API failed: ${e.message}');
      } catch (e) {
        // Log error nhưng vẫn tiếp tục clear local data
        print('Logout API failed: $e');
      }

      // Clear local storage (luôn thực hiện dù API fail)
      await _localDataSource.clearTokens();
      await _clearUserInfo();

      return const Right(null);
    } catch (e) {
      // Nếu clear local storage fail, vẫn cố gắng clear
      try {
        await _localDataSource.clearTokens();
        await _clearUserInfo();
      } catch (clearError) {
        print('Failed to clear local data: $clearError');
      }
      return Left(ServerFailure('Lỗi khi đăng xuất'));
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
      await _clearUserInfo();
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      // Clear tokens nếu có lỗi không xác định
      await _localDataSource.clearTokens();
      await _clearUserInfo();
      return Left(ServerFailure('Lỗi không xác định khi refresh token'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userJson = await _getUserInfo();
      if (userJson == null) {
        return const Right(null);
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure('Lỗi khi lấy thông tin người dùng'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final accessToken = await _localDataSource.getAccessToken();
      final refreshToken = await _localDataSource.getRefreshToken();
      return Right(accessToken != null && refreshToken != null);
    } catch (e) {
      return Left(ServerFailure('Lỗi khi kiểm tra trạng thái đăng nhập'));
    }
  }

  // Helper methods for user info storage
  Future<void> _saveUserInfo(User user) async {
    final userModel = UserModel.fromEntity(user);
    final userJson = jsonEncode(userModel.toJson());
    await _localDataSource.saveUserInfo(userJson);
  }

  Future<String?> _getUserInfo() async {
    return await _localDataSource.getUserInfo();
  }

  Future<void> _clearUserInfo() async {
    await _localDataSource.clearUserInfo();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource, localDataSource);
});