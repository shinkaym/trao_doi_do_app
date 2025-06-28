import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:trao_doi_do_app/core/error/app_exception.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/local/auth_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:trao_doi_do_app/data/models/request/auth_request_model.dart';
import 'package:trao_doi_do_app/data/models/user_model.dart';
import 'package:trao_doi_do_app/domain/entities/request/auth_request.dart';
import 'package:trao_doi_do_app/domain/entities/response/auth_response.dart';
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

      // Save tokens with timestamp để tracking expiry chính xác hơn
      await _localDataSource.saveTokensWithTimestamp(
        loginResponse.jwt,
        loginResponse.refreshToken,
      );

      // Save user info
      await _saveUserInfo(loginResponse.user);

      return loginResponse;
    });
  }

  @override
  Future<Either<Failure, void>> logout() {
    return handleRepositoryCall(() async {
      // Always clear local data first để đảm bảo user được logout
      await _clearAuthData();

      // Try logout API, nhưng không block nếu fail
      try {
        await _remoteDataSource.logout();
      } catch (e) {
        // Log error nhưng không throw để không ảnh hưởng logout flow
        print('Logout API failed: $e');
      }
    }, "Lỗi khi đăng xuất");
  }

  @override
  Future<Either<Failure, User?>> refreshToken() async {
    final result = await handleRepositoryCall(() async {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null) {
        throw const ValidationException('Refresh token không tồn tại');
      }

      final response = await _remoteDataSource.refreshToken(refreshToken);

      // Save new access token với timestamp
      await _localDataSource.saveAccessToken(response.jwt);

      // Return current user từ local
      return await _getCurrentUserFromLocal();
    }, "Lỗi khi refresh token");

    // Clear auth data khi refresh token fail
    if (result.isLeft()) {
      await _clearAuthData();
    }

    return result;
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() {
    return handleRepositoryCall(() async {
      return await _getCurrentUserFromLocal();
    }, "Lỗi khi lấy thông tin người dùng");
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() {
    return handleRepositoryCall(() async {
      // Check cả access token và refresh token
      final refreshToken = await _localDataSource.getRefreshToken();

      // Cần ít nhất refresh token để được coi là logged in
      // Access token có thể expired nhưng có thể refresh được
      return refreshToken?.isNotEmpty == true;
    }, "Lỗi khi kiểm tra trạng thái đăng nhập");
  }

  @override
  Future<Either<Failure, User>> getMe() {
    return handleRepositoryCall(() async {
      final responseModel = await _remoteDataSource.getMe();
      final userEntity = responseModel.user.toEntity();

      // Update local user info
      await _saveUserInfo(userEntity);

      return userEntity;
    }, "Lỗi khi lấy thông tin người dùng từ server");
  }

  @override
  Future<Either<Failure, String?>> getAccessToken() {
    return handleRepositoryCall(() async {
      return await _localDataSource.getAccessToken();
    }, "Lỗi khi lấy access token");
  }

  /// Helper method để get user từ local storage
  Future<User?> _getCurrentUserFromLocal() async {
    final userJson = await _localDataSource.getUserInfo();
    if (userJson == null || userJson.isEmpty) return null;

    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap).toEntity();
    } on FormatException catch (e) {
      // Clear corrupted user data
      await _localDataSource.clearUserInfo();
      throw ValidationException('Dữ liệu người dùng bị lỗi: $e');
    }
  }

  /// Helper method để save user info
  Future<void> _saveUserInfo(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final userJson = jsonEncode(userModel.toJson());
      await _localDataSource.saveUserInfo(userJson);
    } catch (e) {
      // Log error nhưng không throw để không block main flow
      print('Failed to save user info: $e');
    }
  }

  /// Helper method để clear tất cả auth data
  Future<void> _clearAuthData() async {
    await Future.wait([
      _localDataSource.clearTokens(),
      _localDataSource.clearUserInfo(),
    ]);
  }
}
