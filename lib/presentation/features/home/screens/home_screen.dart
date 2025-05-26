import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/banner_address.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/item_list_view.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/item_page_view.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/lost_found_card.dart';
import 'package:trao_doi_do_app/presentation/features/home/widgets/send_item_card.dart';
import 'package:trao_doi_do_app/presentation/widgets/item_single.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<Map<String, dynamic>> get _mockItems => [
        {
          'id': '1',
          'description': 'Máy tính xách tay đã qua sử dụng',
          'sender': 'Mike',
          'time': '5 giờ trước',
          'quantity': '1',
          'name': 'Laptop Dell',
          'imageUrl': 'https://picsum.photos/250?image=9',
          'address': 'Tòa F, Lầu 5, Phòng F512',
        },
        {
          'id': '2',
          'description': 'Ô dù còn mới',
          'sender': 'Anna',
          'time': '3 giờ trước',
          'quantity': '2',
          'name': 'Ô dù',
          'imageUrl': 'https://picsum.photos/250?image=10',
          'address': 'Tòa A, Lầu 3, Phòng A301',
        },
        {
          'id': '3',
          'description': 'Sách lập trình Python cơ bản',
          'sender': 'John',
          'time': '1 giờ trước',
          'quantity': '1',
          'name': 'Sách lập trình',
          'imageUrl': 'https://picsum.photos/250?image=11',
          'address': 'Thư viện trường, tầng 2',
        },
      ];

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
                decoration: TextDecoration.underline, // Gạch chân
                decorationThickness: 0.5, // Độ dày gạch chân
                decorationColor: ext.secondaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            ItemPageView(items: _mockItems),
            SizedBox(height: 8),
            Text(
              'Mới nhất',
              style: TextStyle(
                color: ext.secondaryTextColor, // Màu chữ phụ
                fontSize: 14,
                decoration: TextDecoration.underline, // Gạch chân
                decorationThickness: 0.5,
                decorationColor: ext.secondaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            ItemListView(items: _mockItems),
            SizedBox(height: 8),
            Text(
              'Phổ biến nhất',
              style: TextStyle(
                color: ext.secondaryTextColor, // Màu chữ phụ
                fontSize: 14,
                decoration: TextDecoration.underline, // Gạch chân
                decorationThickness: 0.5,
                decorationColor: ext.secondaryTextColor,
              ),
            ),
            SizedBox(height: 8),
            ItemListView(items: _mockItems),
            SizedBox(height: 16),
            BannerAddress(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Đồ cũ",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ext.primaryTextColor,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/warehouse'),
                  child: Text(
                    "Xem tất cả",
                    style: TextStyle(
                      color: ext.secondaryTextColor, // Màu chữ phụ
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationThickness: 0.5,
                      decorationColor: ext.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ItemSingle(
              description:
                  'Hôm nay trời đẹp, tôi muốn đi dạo nhưng lại không có ai đi cùng nên tôi quyết định tìm một chiếc ô để che nắng...',
              sender: 'Anna',
              time: '3 giờ trước',
              quantity: '2',
              name: 'Ô dù',
              imageUrl: 'https://picsum.photos/250?image=10',
              address: 'Tòa A, Lầu 3, Phòng A301',
            ),
            SizedBox(height: 8,),
            ItemSingle(
              description:
                  'Hôm nay trời đẹp, tôi muốn đi dạo nhưng lại không có ai đi cùng nên tôi quyết định tìm một chiếc ô để che nắng...',
              sender: 'Anna',
              time: '3 giờ trước',
              quantity: '2',
              name: 'Ô dù',
              imageUrl: 'https://picsum.photos/250?image=10',
              address: 'Tòa A, Lầu 3, Phòng A301',
            ),
            SizedBox(height: 8),
            ItemSingle(
              description:
                  'Hôm nay trời đẹp, tôi muốn đi dạo nhưng lại không có ai đi cùng nên tôi quyết định tìm một chiếc ô để che nắng...',
              sender: 'Anna',
              time: '3 giờ trước',
              quantity: '2',
              name: 'Ô dù',
              imageUrl: 'https://picsum.photos/250?image=10',
              address: 'Tòa A, Lầu 3, Phòng A301',
            ),
          ],
        ),
      ),
    );
  }
}
