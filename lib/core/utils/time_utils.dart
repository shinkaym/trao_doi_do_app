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
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Trả về chỉ ngày: dd/MM/yyyy
  static String formatDateOnly(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
           '${dateTime.month.toString().padLeft(2, '0')}/'
           '${dateTime.year}';
  }

  /// Trả về chỉ giờ: HH:mm
  static String formatTimeOnly(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
