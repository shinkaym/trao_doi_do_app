import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class SendItemCard extends StatelessWidget {
  const SendItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Card(
      color: ext.surfaceContainer,
      // Sử dụng màu từ theme
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Bo góc
      ),
      elevation: 4,
      // Thêm bóng đổ nhẹ
      child: Container(
        width: double.infinity, // Chiếm hết chiều rộng
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
          children: [
            Text(
              'Bạn muốn gửi đồ cũ?',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: ext.primaryTextColor, // Màu chữ chính từ theme
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy chia sẻ những món đồ không còn dùng đến.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ext.primaryTextColor, // Màu chữ phụ từ theme
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn có thể bảo vệ tài nguyên và giúp người khác.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ext.secondaryTextColor, // Màu chữ phụ từ theme
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Điều hướng đến SendItemScreen khi nhấn nút
                context.go('/send');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ext.primary,
                // Màu nút từ theme
                minimumSize: const Size(double.infinity, 40),
                // Chiều rộng toàn phần
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Gửi đồ',
                style: TextStyle(
                  color: ext.onPrimary, // Màu chữ trên nút từ theme
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
