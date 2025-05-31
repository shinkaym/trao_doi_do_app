// ===================================================================
// File: /lib/core/extensions/extensions.dart
// Barrel file để export tất cả extensions - giúp import dễ dàng hơn
// ===================================================================

// Context extensions - navigation, theme, dialogs, snackbars, etc.
export 'context_extensions.dart';

// Có thể thêm các extensions khác ở đây khi cần
// export 'string_extensions.dart';
// export 'date_extensions.dart';
// export 'number_extensions.dart';
// export 'list_extensions.dart';

// ===================================================================
// Cách sử dụng:
// ===================================================================

// Trong các file widget, chỉ cần import duy nhất file này:
// import 'package:your_app_name/core/extensions/extensions.dart';

// Thay vì phải import từng file extension riêng lẻ:
// import 'package:your_app_name/core/extensions/context_extensions.dart';
// import 'package:your_app_name/core/extensions/string_extensions.dart';
// import 'package:your_app_name/core/extensions/date_extensions.dart';

// ===================================================================
// Ví dụ extensions khác có thể thêm vào tương lai:
// ===================================================================

/*
// String Extensions
extension StringExtensions on String {
  String get capitalize => isEmpty ? this : this[0].toUpperCase() + substring(1);
  
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');
  
  String truncate(int length, {String suffix = '...'}) {
    return this.length <= length ? this : '${substring(0, length)}$suffix';
  }
}

// Date Extensions  
extension DateExtensions on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
  
  String get formattedDate => '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  
  bool get isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }
  
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.year == year && yesterday.month == month && yesterday.day == day;
  }
}

// Number Extensions
extension NumberExtensions on num {
  String get formattedCurrency => '${toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
    (Match m) => '${m[1]},'
  )} đ';
  
  String get compactFormat {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
  
  bool get isEven => this % 2 == 0;
  bool get isOdd => this % 2 != 0;
}

// List Extensions
extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  
  List<T> get unique => toSet().toList();
  
  List<T> chunked(int size) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, math.min(i + size, length)));
    }
    return chunks.expand((chunk) => chunk).toList();
  }
  
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}
*/