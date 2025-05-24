import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/item_slider.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/lost_found_card.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/send_item_card.dart';
import 'package:trao_doi_do_app/presentation/widgets/item.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return MainLayout(
      title: 'Trang chủ',
      notificationCount: 3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SendItemCard(),
            SizedBox(height: 16),
            const LostFoundCard(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bài đăng",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ext.primaryTextColor,
                  ),
                ),
                IconButton(
                  onPressed: () => context.go('/posts'),
                  icon: Icon(
                    Icons.search,
                    color: ext.primaryTextColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Đã tìm thấy',
              style: TextStyle(
                color: ext.secondaryTextColor, // Màu chữ phụ
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Item(
              message: 'Vì đâu mà mưa, bên trong có gì để tôi tìm mà trong mưa tôi tìm...',
              sender: 'Mike',
              time: '5 giờ trước',
              badge: 'SL1',
            )
            // ItemSlider(),
          ],
        ),
      ),
    );
  }
}
