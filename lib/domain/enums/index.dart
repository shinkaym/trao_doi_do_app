import 'package:flutter/material.dart';

enum AppBarType {
  standard, // CustomAppBar thường với notification
  detail, // SliverAppBar cho detail screens
  chat, // AppBar riêng cho chat
  minimal, // AppBar đơn giản không có notification
}

enum CreatePostType {
  giveAway(1, 'Gửi đồ cũ', Icons.volunteer_activism, Colors.blue),
  foundItem(2, 'Nhặt đồ thất lạc', Icons.help_outline, Colors.green),
  findLost(3, 'Tìm đồ thất lạc', Icons.search, Colors.red),
  freePost(4, 'Bài đăng tự do', Icons.edit_note, Colors.purple);

  final int typeValue;
  final String label;
  final IconData icon;
  final Color color;

  const CreatePostType(this.typeValue, this.label, this.icon, this.color);
}
