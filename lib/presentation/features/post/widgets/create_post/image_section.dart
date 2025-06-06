import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/models/post_image.dart';

class ImageSection extends StatelessWidget {
  final List<PostImage> images;
  final VoidCallback onPickImages;
  final Function(String) onRemoveImage;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const ImageSection({
    super.key,
    required this.images,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hình ảnh',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              ' (tối đa 4 ảnh, mỗi ảnh ≤ 5MB)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 12 : 8),
        SizedBox(
          height: isTablet ? 120 : 100,
          child: Row(
            children: [
              // Add image button
              if (images.length < 4)
                Container(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 120 : 100,
                  margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: InkWell(
                      onTap: onPickImages,
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: isTablet ? 32 : 24,
                            color: colorScheme.primary,
                          ),
                          SizedBox(height: isTablet ? 8 : 4),
                          Text(
                            'Thêm ảnh',
                            style: TextStyle(
                              fontSize: isTablet ? 12 : 10,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Selected images
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return Container(
                      width: isTablet ? 120 : 100,
                      height: isTablet ? 120 : 100,
                      margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                      child: Stack(
                        children: [
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  image.imageData != null
                                      ? Image.memory(
                                        image.imageData!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                      : Icon(
                                        Icons.image,
                                        size: isTablet ? 32 : 24,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () => onRemoveImage(image.id),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
