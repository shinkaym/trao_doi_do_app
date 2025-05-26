import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class ItemSingle extends StatelessWidget {
  final String description;
  final String sender;
  final String time;
  final String quantity;
  final String name;
  final String imageUrl;
  final String address;

  const ItemSingle({
    super.key,
    required this.description,
    required this.sender,
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
        context.pushNamed(
          'item_detail',
          pathParameters: {'id': '1'}, // Thêm id nếu cần
          extra: {
            'description': description,
            'sender': sender,
            'time': time,
            'quantity': quantity,
            'name': name,
            'imageUrl': imageUrl,
            'address': address,
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // Bo tròn 4 góc toàn bộ
        child: Card(
          color: ext.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Đảm bảo Card bo tròn
          ),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh với bo tròn 4 góc
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: FadeInImage.assetNetwork(
                  placeholder: "assets/images/image_error.png",
                  image: imageUrl,
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
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                child: Container(
                  color: ext.surfaceContainer,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: ext.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ext.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "SL:$quantity",
                              style: TextStyle(
                                color: ext.onPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tìm thấy tại: $address",
                        style: TextStyle(
                          color: ext.secondaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Builder(
                        builder: (context) {
                          const maxLines = 2;
                          final textSpan = TextSpan(
                            text: description,
                            style: TextStyle(
                              color: ext.secondaryTextColor,
                              fontSize: 12,
                            ),
                          );
                          final textPainter = TextPainter(
                            text: textSpan,
                            maxLines: maxLines,
                            textDirection: TextDirection.ltr,
                          )..layout(
                            maxWidth: MediaQuery.of(context).size.width - 48,
                          );
                          final isOverflow = textPainter.didExceedMaxLines;
                          if (!isOverflow) {
                            return Text(
                              description,
                              style: TextStyle(
                                color: ext.secondaryTextColor,
                                fontSize: 12,
                              ),
                              maxLines: maxLines,
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                          return GestureDetector(
                            onTap: () {
                              // Hành động khi nhấn "Xem thêm" (có thể giữ nguyên hoặc tùy chỉnh)
                            },
                            child: RichText(
                              text: TextSpan(
                                text: description,
                                style: TextStyle(
                                  color: ext.secondaryTextColor,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: '...Xem thêm',
                                    style: TextStyle(
                                      color: ext.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: maxLines,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Người đăng: $sender',
                            style: TextStyle(
                              color: ext.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              color: ext.secondaryTextColor,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
    ));
  }
}