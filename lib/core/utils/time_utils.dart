import 'package:timeago/timeago.dart' as timeago;

class TimeUtils {
  static void init() {
    timeago.setLocaleMessages('vi', timeago.ViMessages());
  }

  /// Trả về dạng tương đối
  static String formatTimeAgo(DateTime dateTime, {String locale = 'vi'}) {
    return timeago.format(dateTime, locale: 'vi');
  }

  /// Trả về dạng tuyệt đối: dd/MM/yyyy HH:mm
  static String formatAbsolute(DateTime dateTime) {
    DateTime dt = dateTime.toLocal();
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Trả về chỉ ngày: dd/MM/yyyy
  static String formatDateOnly(DateTime dateTime) {
    DateTime dt = dateTime.toLocal();
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  /// Trả về chỉ giờ: HH:mm
  static String formatTimeOnly(DateTime dateTime) {
    DateTime dt = dateTime.toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
