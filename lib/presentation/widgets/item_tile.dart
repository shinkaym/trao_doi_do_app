import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/item_detail/screens/item_detail_screen.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class ItemTile extends StatelessWidget {
  final String time;
  final String quantity;
  final String name;
  final String imageUrl;
  final String address;

  const ItemTile({
    super.key,
    required this.time,
    required this.quantity,
    required this.name,
    required this.imageUrl,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return GestureDetector(
      onTap: () {
        // Hành động khi tap: Chuyển sang
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ItemDetailScreen(
                  description: 'Mô tả chi tiết về $name',
                  sender: 'Người gửi',
                  time: time,
                  quantity: quantity,
                  name: name,
                  imageUrl: imageUrl,
                  address: address,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: ext.surfaceContainer,
          borderRadius: BorderRadius.circular(10), // Bo tròn rõ ràng hơn
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Bo tròn cho ListTile
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minLeadingWidth: 0,
          horizontalTitleGap: 16, // Khoảng cách giữa leading và title/subtitle
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: FadeInImage.assetNetwork(
              placeholder: "assets/images/image_error.png",
              image: imageUrl,
              width: 60, // Điều chỉnh kích thước hình ảnh cho ListTile
              height: 60,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/image_error.png",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ext.primaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ext.secondaryTextColor,
                      fontSize: 10, // Giảm fontSize cho thời gian để cân đối
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8), // Thêm khoảng cách giữa title và subtitle
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Tìm thấy tại: $address",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ext.secondaryTextColor,
                    fontSize: 10,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ext.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "SL:$quantity",
                  style: TextStyle(
                    color: ext.onPrimary,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          tileColor: ext.surfaceContainer, // Đặt màu nền cho ListTile
        ),
      ),
    );
  }
}
