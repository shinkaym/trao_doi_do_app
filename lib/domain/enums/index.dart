import 'package:flutter/material.dart';

enum AppBarType {
  standard, // CustomAppBar thường với notification
  detail, // SliverAppBar cho detail screens
  chat, // AppBar riêng cho chat
  minimal, // AppBar đơn giản không có notification
}

enum CreatePostType {
  giveAway(1, 'Tặng đồ', Icons.volunteer_activism, Colors.blue),
  foundItem(2, 'Tôi nhặt được đồ', Icons.help_outline, Colors.green),
  findLost(3, 'Tôi bị mất đồ', Icons.search, Colors.red),
  freePost(4, 'Bài viết', Icons.edit_note, Colors.purple);

  final int typeValue;
  final String label;
  final IconData icon;
  final Color color;

  const CreatePostType(this.typeValue, this.label, this.icon, this.color);

  static CreatePostType? fromValue(int value) {
    return CreatePostType.values.firstWhere(
      (e) => e.typeValue == value,
      orElse: () => CreatePostType.freePost,
    );
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

enum InterestAction { create, cancel }
