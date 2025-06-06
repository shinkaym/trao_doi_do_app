class ApiConstants {
  static const String baseUrl = 'http://34.142.168.171:8000/api/v1';

  // Endpoints
  static const String categories = '/categories';
  static const String items = '/items';
  static const String posts = '/posts';
  static const String clientLogin = '/client/login';
  static const String clientLogout = '/client/logout';
  static const String clientPosts = '/client/posts';
  static const String interests = '/interests';

  // Headers
  static const String contentType = 'Content-Type';
  static const String authorization = 'Authorization';
  static const String deviceId = 'Device-Id';
  static const String applicationJson = 'application/json';

  // Request timeout
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
