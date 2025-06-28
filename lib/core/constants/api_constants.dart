import 'package:trao_doi_do_app/core/config/flavor.dart';

class ApiConstants {
  static String get baseUrl => AppConfig.apiUrl;

  // Endpoints
  static const String client = '/client';
  static const String categories = '/categories';
  static const String items = '/items';
  static const String posts = '/posts';
  static const String clientLogin = '$client/login';
  static const String clientLogout = '$client/logout';
  static const String clientPosts = '$client/posts';
  static const String clientGetMe = '$client/get-me';
  static const String clients = '/clients';
  static const String clientSendOtp = '/client/send-otp';
  static const String clientVerifyOtp = '/client/verify-otp';
  static const String clientSignup = '/client/signup';
  static const String clientResetPassword = '/client/reset-password';
  static const String interests = '/interests';
  static const String transactions = '/transactions';
  static const String refreshToken = '/refresh-token';
  static const String messages = '/messages';
  static const String clientItemWarehouses = '$client/item-warehouses';
  static const String claimRequest = '$clientItemWarehouses/claim-request';
  static const String oldStock = '$clientItemWarehouses/old-stock';
  static const String myPosts = '$posts/my-post';
  static const String clientAppointments = '$client/appointments';
  static const String appointments = '/appointments';
  static const String users = '/users';
  static const String ranks = '$client$users/ranks';
  static const String myRanks = '$client$users/my-good-dees';
  static const String settings = '/settings';

  // Headers
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String deviceId = 'Device-Id';
  static const String applicationJson = 'application/json';

  // Request timeout
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Token expiry times (in minutes for easier calculation)
  static const int accessTokenExpiryMinutes = 240; // 4 hours
  static const int refreshTokenExpiryMinutes = 43200; // 30 days (30 * 24 * 60)

  // Token expiry times in milliseconds for DateTime calculations
  static const int accessTokenExpiryMs = accessTokenExpiryMinutes * 60 * 1000;
  static const int refreshTokenExpiryMs = refreshTokenExpiryMinutes * 60 * 1000;

  // Buffer time before token expires (refresh 5 minutes before expiry)
  static const int tokenRefreshBufferMinutes = 5;
  static const int tokenRefreshBufferMs = tokenRefreshBufferMinutes * 60 * 1000;
}
