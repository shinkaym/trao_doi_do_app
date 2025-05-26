import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class LostFoundCard extends StatelessWidget {
  const LostFoundCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Card(
      color: ext.card, // Màu nền từ theme
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Bo góc
      ),
      elevation: 4, // Thêm bóng đổ nhẹ
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              'Về chúng tôi?',
              style: TextStyle(
                color: ext.primaryTextColor, // Màu chữ chính
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Mô tả
            Text(
              'Lost & Found là nơi tập hợp các thông tin về các món đồ thất lạc, mất hoặc tìm thấy. Nếu bạn đã làm mất hoặc tìm thấy một món đồ nào đó, hãy liên hệ ngay với chúng tôi để được hỗ trợ.',
              style: TextStyle(
                color: ext.secondaryTextColor, // Màu chữ phụ
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            // Câu hỏi
            Text(
              'Bạn có thể làm gì ở đây?',
              style: TextStyle(
                color: ext.primaryTextColor, // Màu chữ chính
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Danh sách tùy chọn
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• Tìm kiếm thông tin về món đồ thất lạc của bạn',
                  style: TextStyle(
                    color: ext.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Gửi đồ của bạn',
                  style: TextStyle(
                    color: ext.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Đăng ký nhận đồ thất lạc về đồ của bạn',
                  style: TextStyle(
                    color: ext.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Xếp hạng sinh viên viêc tốt',
                  style: TextStyle(
                    color: ext.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Thông tin bổ sung
            Text(
              'Lưu ý: Đồ thất lạc sẽ được giữ trong vòng 3 tháng. Nếu sau 3 tháng không có ai nhận, đồ sẽ được xử lý.',
              style: TextStyle(
                color: ext.secondaryTextColor,
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}