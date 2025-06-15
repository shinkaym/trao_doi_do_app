import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/local/auth_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:trao_doi_do_app/data/models/request/login_request_model.dart';
import 'package:trao_doi_do_app/data/models/user_model.dart';
import 'package:trao_doi_do_app/domain/entities/request/login_request.dart';
import 'package:trao_doi_do_app/domain/entities/response/login_response.dart';
import 'package:trao_doi_do_app/domain/entities/user.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, LoginResponse>> login(LoginRequest request) {
    return handleRepositoryCall(() async {
      final requestModel = LoginRequestModel.fromEntity(request);
      final responseModel = await _remoteDataSource.login(requestModel);
      final loginResponse = responseModel.toEntity();

      await Future.wait([
        _localDataSource.saveAccessToken(loginResponse.jwt),
        _localDataSource.saveRefreshToken(loginResponse.refreshToken),
        _saveUserInfo(
          loginResponse.user,
        ).catchError((_) => null), // Silent fail
      ]);

      return loginResponse;
    });
  }

  @override
  Future<Either<Failure, void>> logout() {
    return handleRepositoryCall(() async {
      // Try logout API, ignore errors
      _remoteDataSource.logout().catchError((_) => '');

      // Always clear local data
      await Future.wait([
        _localDataSource.clearTokens(),
        _localDataSource.clearUserInfo(),
      ]);
    }, "Lỗi khi đăng xuất");
  }

  @override
  Future<Either<Failure, User?>> refreshToken() async {
    final result = await handleRepositoryCall(() async {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null) {
        throw const ValidationException('Không tìm thấy refresh token');
      }

      final response = await _remoteDataSource.refreshToken(refreshToken);
      await _localDataSource.saveAccessToken(response.jwt);

      // Get current user from local
      final userJson = await _localDataSource.getUserInfo();
      if (userJson == null || userJson.isEmpty) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap).toEntity();
    }, "Lỗi khi refresh token");

    // Clear auth data on failure
    if (result.isLeft()) {
      _clearAuthData().catchError((_) => null);
    }

    return result;
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() {
    return handleRepositoryCall(() async {
      final userJson = await _localDataSource.getUserInfo();
      if (userJson == null || userJson.isEmpty) return null;

      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap).toEntity();
      } on FormatException catch (e) {
        _localDataSource.clearUserInfo().catchError((_) => null);
        throw ValidationException('Dữ liệu người dùng bị lỗi: $e');
      }
    }, "Lỗi khi lấy thông tin người dùng");
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() {
    return handleRepositoryCall(() async {
      final tokens = await Future.wait([
        _localDataSource.getAccessToken(),
        _localDataSource.getRefreshToken(),
      ]);

      return tokens.every((token) => token?.isNotEmpty == true);
    }, "Lỗi khi kiểm tra trạng thái đăng nhập");
  }

  @override
  Future<Either<Failure, User>> getMe() {
    return handleRepositoryCall(() async {
      final responseModel = await _remoteDataSource.getMe();
      final userEntity = responseModel.user.toEntity();

      _saveUserInfo(userEntity).catchError((_) => null); // Silent fail
      return userEntity;
    }, "Lỗi khi lấy thông tin người dùng");
  }

  Future<void> _saveUserInfo(User user) async {
    final userModel = UserModel.fromEntity(user);
    final userJson = jsonEncode(userModel.toJson());
    await _localDataSource.saveUserInfo(userJson);
  }

  Future<void> _clearAuthData() async {
    await Future.wait([
      _localDataSource.clearTokens(),
      _localDataSource.clearUserInfo(),
    ]);
  }
}
