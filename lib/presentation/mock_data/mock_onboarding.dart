import 'package:flutter/material.dart';

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}

final mockOnboardingPages = [
  OnboardingData(
    title: 'Đồ cũ, giá trị mới',
    subtitle: 'Kết nối & Trao đổi đồ cũ',
    description:
        'Dễ dàng tặng, nhận hoặc trao đổi đồ dùng cũ với cộng đồng quanh bạn.',
    icon: Icons.recycling,
    color: Colors.green,
  ),
  OnboardingData(
    title: 'Mất đồ? Đừng lo!',
    subtitle: 'Tìm lại đồ thất lạc',
    description:
        'Đăng thông tin hoặc tìm kiếm trong kho đồ thất lạc – có thể ai đó đã nhặt được món đồ của bạn.',
    icon: Icons.search,
    color: Colors.blue,
  ),
  OnboardingData(
    title: 'Đăng bài trong vài giây',
    subtitle: 'Đăng bài & Quản lý dễ dàng',
    description:
        'Chia sẻ món đồ bạn muốn tặng hoặc tìm kiếm – quản lý mọi thứ ngay trên ứng dụng.',
    icon: Icons.add_circle_outline,
    color: Colors.orange,
  ),
  OnboardingData(
    title: 'Cộng đồng giúp đỡ lẫn nhau',
    subtitle: 'Hỗ trợ từ cộng đồng',
    description:
        'Mỗi hành động nhỏ đều mang lại giá trị – hãy là một phần của cộng đồng chia sẻ.',
    icon: Icons.people,
    color: Colors.purple,
  ),
  OnboardingData(
    title: 'Sẵn sàng chưa?',
    subtitle: 'Bắt đầu sử dụng',
    description:
        'Tạo tài khoản và bắt đầu hành trình chia sẻ hoặc tìm lại món đồ yêu thích của bạn.',
    icon: Icons.rocket_launch,
    color: Colors.teal,
  ),
];
