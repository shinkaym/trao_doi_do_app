import 'package:flutter/material.dart';

enum AppBarType {
  standard, // CustomAppBar thường với notification
  detail, // SliverAppBar cho detail screens
  chat, // AppBar riêng cho chat
  minimal, // AppBar đơn giản không có notification
}

enum CreatePostType {
  giveAway(1),
  foundItem(2),
  findLost(3),
  freePost(4),
  unknown(0);

  final int value;

  const CreatePostType(this.value);

  static CreatePostType fromValue(int value) {
    return CreatePostType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CreatePostType.unknown,
    );
  }

  String label() {
    switch (this) {
      case CreatePostType.giveAway:
        return 'Tặng đồ';
      case CreatePostType.foundItem:
        return 'Tôi nhặt được đồ';
      case CreatePostType.findLost:
        return 'Tôi bị mất đồ';
      case CreatePostType.freePost:
        return 'Bài viết';
      case CreatePostType.unknown:
        return 'Không xác định';
    }
  }

  IconData icon() {
    switch (this) {
      case CreatePostType.giveAway:
        return Icons.volunteer_activism;
      case CreatePostType.foundItem:
        return Icons.help_outline;
      case CreatePostType.findLost:
        return Icons.search;
      case CreatePostType.freePost:
        return Icons.edit_note;
      case CreatePostType.unknown:
        return Icons.help;
    }
  }

  Color color() {
    switch (this) {
      case CreatePostType.giveAway:
        return Colors.blue;
      case CreatePostType.foundItem:
        return Colors.green;
      case CreatePostType.findLost:
        return Colors.red;
      case CreatePostType.freePost:
        return Colors.purple;
      case CreatePostType.unknown:
        return Colors.grey;
    }
  }
}


// Enum cho loại bài đăng
enum PostType {
  all('Tất cả', Icons.list, null),
  giveAway('Tặng đồ', Icons.volunteer_activism, 1),
  foundItem('Tôi nhặt được đồ', Icons.find_in_page, 2),
  findLost('Tôi bị mất đồ', Icons.search, 3),
  freePost('Bài viết', Icons.article, 4);

  const PostType(this.label, this.icon, this.value);
  final String label;
  final IconData icon;
  final int? value;

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
  pending(1),
  accepted(2),
  rejected(3),
  unknown(0);

  final int value;

  const TransactionStatus(this.value);

  static TransactionStatus fromValue(int value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.unknown,
    );
  }

  IconData icon() {
    switch (this) {
      case TransactionStatus.pending:
        return Icons.pending;
      case TransactionStatus.accepted:
        return Icons.check_circle;
      case TransactionStatus.rejected:
        return Icons.cancel;
      case TransactionStatus.unknown:
        return Icons.help;
    }
  }

  Color color() {
    switch (this) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.accepted:
        return Colors.green;
      case TransactionStatus.rejected:
        return Colors.red;
      case TransactionStatus.unknown:
        return Colors.grey;
    }
  }

  String label({required bool isPostOwner}) {
    switch (this) {
      case TransactionStatus.pending:
        return isPostOwner ? 'Đang trong giao dịch' : 'Đang trong giao dịch';
      case TransactionStatus.accepted:
        return 'Hoàn tất';
      case TransactionStatus.rejected:
        return isPostOwner ? 'Đã từ chối' : 'Đã bị từ chối';
      case TransactionStatus.unknown:
        return 'Không xác định';
    }
  }
}

enum InterestAction { create, cancel }
