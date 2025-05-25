import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class BannerAddress extends StatefulWidget {
  const BannerAddress({super.key});

  @override
  BannerAddressState createState() => BannerAddressState();
}

class BannerAddressState extends State<BannerAddress> {
  bool _isVisible = true; // Trạng thái hiển thị của banner

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    if (!_isVisible) {
      return const SizedBox.shrink(); // Ẩn widget nếu bị đóng
    }

    return Container(
      decoration: BoxDecoration(
        color: ext.surfaceContainer, // Màu nền từ theme
        borderRadius: BorderRadius.circular(10), // Bo góc
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề và nút đóng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Địa điểm nhận đồ',
                  style: TextStyle(
                    color: ext.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: ext.secondaryTextColor,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isVisible = false; // Ẩn banner khi nhấn nút đóng
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tòa F, Lầu 5, Phòng F512',
                        style: TextStyle(
                          color: ext.primaryTextColor,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thời gian mở cửa: 8:00 - 17:00',
                        style: TextStyle(
                          color: ext.secondaryTextColor,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // Bo tròn hoàn toàn
                    child: Image.asset(
                      'assets/images/warehouse.jpg',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
