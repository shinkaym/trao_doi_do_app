import 'package:flutter/material.dart';

class FullWidthImages extends StatelessWidget {
  final List<String> images;
  final bool isTablet;

  const FullWidthImages({
    super.key,
    required this.images,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          images.map((imageUrl) {
            return _FullWidthImageItem(imageUrl: imageUrl, isTablet: isTablet);
          }).toList(),
    );
  }
}

class _FullWidthImageItem extends StatelessWidget {
  final String imageUrl;
  final bool isTablet;

  const _FullWidthImageItem({required this.imageUrl, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: isTablet ? 200 : 250,
      child: ClipRRect(
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: isTablet ? 50 : 40,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    Text(
                      'Không thể tải ảnh',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isTablet ? 12 : 10,
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
