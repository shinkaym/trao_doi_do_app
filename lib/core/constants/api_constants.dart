class ApiConstants {
  static const String baseUrl = 'http://34.142.168.171:8000/api/v1';

  // Endpoints
  static const String categories = '/categories';
  static const String items = '/items';
  static const String posts = '/posts';
  static const String clientLogin = '/client/login';
  static const String clientLogout = '/client/logout';
  static const String clientPosts = '/client/posts';
  static const String clientGetMe = '/client/get-me';
  static const String interests = '/interests';
  static const String transactions = '/transactions';

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
