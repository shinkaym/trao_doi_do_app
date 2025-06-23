import 'package:flutter/material.dart';

enum AppBarType {
  standard, // CustomAppBar thường với notification
  detail, // SliverAppBar cho detail screens
  chat, // AppBar riêng cho chat
  minimal, // AppBar đơn giản không có notification
}

// Enum cho loại bài đăng
enum PostType {
  all('Tất cả', Icons.list, null),
  giveAway('Tặng đồ', Icons.volunteer_activism, 1),
  foundItem('Tôi nhặt được đồ', Icons.help_outline, 2),
  findLost('Tôi bị mất đồ', Icons.search, 3),
  freePost('Bài viết', Icons.edit_note, 4);

  const PostType(this.label, this.icon, this.value);

  final String label;
  final IconData icon;
  final int? value;

  /// Màu sắc tương ứng
  Color get color {
    switch (this) {
      case PostType.giveAway:
        return Colors.blue;
      case PostType.foundItem:
        return Colors.green;
      case PostType.findLost:
        return Colors.red;
      case PostType.freePost:
        return Colors.purple;
      case PostType.all:
        return Colors.grey;
    }
  }

  static PostType fromValue(int value) {
    return PostType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PostType.all,
    );
  }
}

// Enum cho trạng thái bài post
enum PostStatus {
  all('Tất cả', Icons.list, null),
  pending('Đang chờ duyệt', Icons.hourglass_empty, 1),
  rejected('Đã từ chối', Icons.block, 2),
  approved('Đã duyệt', Icons.check_circle, 3),
  locked('Đã khóa', Icons.lock, 4);

  const PostStatus(this.label, this.icon, this.value);

  final String label;
  final IconData icon;
  final int? value;

  static PostStatus fromValue(int value) {
    return PostStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PostStatus.all,
    );
  }

  Color get color {
    switch (this) {
      case PostStatus.pending:
        return Colors.orange;
      case PostStatus.rejected:
        return Colors.red;
      case PostStatus.approved:
        return Colors.green;
      case PostStatus.locked:
        return Colors.blueGrey;
      case PostStatus.all:
        return Colors.grey;
    }
  }
}

// Enum cho sắp xếp thời gian
enum SortOrder {
  newest('Mới nhất', Icons.arrow_downward, 'createdAt', 'DESC'),
  oldest('Cũ nhất', Icons.arrow_upward, 'createdAt', 'ASC');

  const SortOrder(this.label, this.icon, this.sort, this.order);
  final String label;
  final IconData icon;
  final String sort;
  final String order;
}

enum TransactionStatus {
  pending('Đang trong giao dịch', Icons.pending, Colors.orange, 1),
  accepted('Hoàn tất', Icons.check_circle, Colors.green, 2),
  rejected('Đã từ chối', Icons.cancel, Colors.red, 3),
  failed(
    'Giao dịch thất bại',
    Icons.error,
    Color(0xFFD32F2F),
    4,
  ), // red.shade700
  unknown('Không xác định', Icons.help, Colors.grey, 0);

  const TransactionStatus(this._label, this.icon, this.color, this.value);

  final String _label;
  final IconData icon;
  final Color color;
  final int value;

  /// Lấy label mặc định
  String get label => _label;

  /// Trả về label tùy thuộc chủ bài viết
  String getLabel({required bool isPostOwner}) {
    switch (this) {
      case TransactionStatus.rejected:
        return isPostOwner ? 'Đã từ chối' : 'Đã bị từ chối';
      case TransactionStatus.pending:
        return 'Đang trong giao dịch';
      default:
        return _label;
    }
  }

  static TransactionStatus fromValue(int value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.unknown,
    );
  }
}

enum InterestAction { create, cancel }

enum DeliveryMethod {
  meetInPerson('Gặp trực tiếp'),
  delivery('Giao hàng');

  const DeliveryMethod(this.displayName);
  final String displayName;

  String get value {
    switch (this) {
      case DeliveryMethod.meetInPerson:
        return 'Gặp trực tiếp';
      case DeliveryMethod.delivery:
        return 'Giao hàng';
    }
  }
}
