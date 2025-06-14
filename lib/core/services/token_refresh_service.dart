import 'dart:async';
import 'package:dio/dio.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/utils/device_utils.dart';
import 'package:trao_doi_do_app/data/datasources/local/auth_local_datasource.dart';

/// Centralized token refresh service to prevent race conditions
class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  factory TokenRefreshService() => _instance;
  TokenRefreshService._internal();

  // Singleton state for token refresh
  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;
  final List<Completer<String?>> _waitingCompleters = [];

  /// Thread-safe token refresh with queue management
  Future<String?> refreshToken(AuthLocalDataSource authDataSource) async {
    // If refresh is already in progress, wait for it
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _waitingCompleters.add(completer);
      return completer.future;
    }

    // Start refresh process
    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await authDataSource.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No valid refresh token available');
      }

      final newAccessToken = await _performTokenRefresh(refreshToken);

      // Save new token
      await authDataSource.saveAccessToken(newAccessToken);

      // Complete all waiting requests
      _completeAllWaiters(newAccessToken);

      return newAccessToken;
    } catch (error) {
      // Complete all waiting requests with error
      _completeAllWaitersWithError(error);
      rethrow;
    } finally {
      _cleanup();
    }
  }

  /// Performs the actual HTTP request to refresh token
  Future<String> _performTokenRefresh(String refreshToken) async {
    final dio = Dio();
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = Duration(
      milliseconds: ApiConstants.connectTimeout,
    );
    dio.options.receiveTimeout = Duration(
      milliseconds: ApiConstants.receiveTimeout,
    );

    final deviceId = await DeviceUtils.getDeviceId();

    try {
      final response = await dio.post(
        '/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            ApiConstants.contentType: ApiConstants.applicationJson,
            ApiConstants.deviceId: deviceId,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['code'] == 200 && data['data'] != null) {
          final newAccessToken = data['data']['jwt'];
          if (newAccessToken == null || newAccessToken.isEmpty) {
            throw Exception('Invalid access token received');
          }
          return newAccessToken;
        } else {
          throw Exception(data['message'] ?? 'Token refresh failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Token refresh failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Refresh token expired or invalid');
      }
      throw Exception('Network error during token refresh: ${e.message}');
    }
  }

  /// Complete all waiting requests with success
  void _completeAllWaiters(String token) {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete(token);
    }

    for (final completer in _waitingCompleters) {
      if (!completer.isCompleted) {
        completer.complete(token);
      }
    }
  }

  /// Complete all waiting requests with error
  void _completeAllWaitersWithError(dynamic error) {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete(null);
    }

    for (final completer in _waitingCompleters) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
  }

  /// Cleanup refresh state
  void _cleanup() {
    _isRefreshing = false;
    _refreshCompleter = null;
    _waitingCompleters.clear();
  }

  /// Check if refresh is currently in progress
  bool get isRefreshing => _isRefreshing;

  /// Force cleanup (useful for testing or app shutdown)
  void forceCleanup() {
    _completeAllWaitersWithError(Exception('Service cleanup'));
    _cleanup();
  }
}
