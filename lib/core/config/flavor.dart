import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get env => dotenv.env['ENV'] ?? 'dev';
  static String get appName => dotenv.env['APP_NAME'] ?? 'ShareAndSave';

  static String get apiDomain =>
      dotenv.env['API_DOMAIN'] ?? 'http://34.142.168.171:8000';
  static String get apiVersion => dotenv.env['API_VERSION'] ?? '/api/v1';
  static String get apiUrl => '$apiDomain$apiVersion';

  static String get wsDomain =>
      dotenv.env['WS_DOMAIN'] ?? 'ws://34.142.168.171:8001';
}
