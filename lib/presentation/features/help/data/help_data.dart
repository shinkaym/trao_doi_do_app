import 'package:flutter/material.dart';

class HelpItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;

  const HelpItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
  });
}

class HelpData {
  static const List<HelpItem> helpItems = [
    HelpItem(
      id: 'ranking',
      title: 'Bảng xếp hạng',
      description:
          '''Bảng xếp hạng hiển thị danh sách người dùng có điểm cao nhất trong hệ thống.

🏆 Cách hoạt động:
• Top 5 người dùng sẽ được hiển thị với badge đặc biệt
• Vị trí #1, #2, #3 có màu vàng, bạc, đồng
• Vị trí #4, #5 có màu chủ đề chính
• Các vị trí khác có màu phụ

📊 Thông tin hiển thị:
• Xếp hạng hiện tại của bạn
• Tổng điểm việc tốt
• Số lượng việc tốt đã thực hiện
• Avatar và thông tin cá nhânn''',
      icon: Icons.leaderboard,
      iconColor: Colors.amber,
    ),

    HelpItem(
      id: 'good_deeds',
      title: 'Việc tốt',
      description: '''Ghi nhận và theo dõi các việc tốt bạn đã thực hiện.

✨ Cách thức hoạt động:
• Mỗi việc tốt sẽ được tính điểm tương ứng

📈 Tăng điểm:
• Thực hiện việc tốt thường xuyên
• Tham gia tích cực các hoạt động cộng đồng

🎯 Mục tiêu:
• Khuyến khích làm việc tốt
• Xây dựng cộng đồng tích cực
• Tạo động lực cạnh tranh lành mạnh''',
      icon: Icons.volunteer_activism,
      iconColor: Colors.red,
    ),
  ];
}
