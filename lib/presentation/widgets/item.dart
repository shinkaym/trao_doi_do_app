import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class Item extends StatelessWidget {
  final String message;
  final String sender;
  final String time;
  final String badge;

  const Item({
    super.key,
    required this.message,
    required this.sender,
    required this.time,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10), // Bo tròn 4 góc toàn bộ
      child: Card(
        color: ext.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Đảm bảo Card bo tròn
        ),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh với bo tròn 4 góc
            ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:Radius.circular(10) ), // Bo tròn cả 4 góc
              child: FadeInImage.assetNetwork(
                placeholder: "assets/images/image_error.png",
                image: "https://picsum.photos/250?image=9",
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/images/image_error.png",
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            // Phần thân với nội dung
            ClipRRect(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight:Radius.circular(10) ),
              child: Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mật khẩu đã bị ẩn',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bản gốc: $sender',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ext.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: ext.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}