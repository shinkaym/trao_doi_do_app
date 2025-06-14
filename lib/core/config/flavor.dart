import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get env => dotenv.env['ENV'] ?? 'dev';
  static String get appName => dotenv.env['APP_NAME'] ?? 'ShareAndSave';
  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://34.142.168.171:8000/api/v1';
}
