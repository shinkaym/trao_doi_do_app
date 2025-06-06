import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/post/widgets/create_post/image_section.dart';
import 'package:trao_doi_do_app/presentation/models/post_image.dart';

class CommonFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<PostImage> images;
  final VoidCallback onPickImages;
  final Function(String) onRemoveImage;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const CommonFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
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
        // Title
        TextFormField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Tiêu đề bài đăng *',
            hintText: 'Nhập tiêu đề mô tả ngắn gọn...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.title),
          ),
          maxLength: 100,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tiêu đề bài đăng';
            }
            if (value.trim().length < 10) {
              return 'Tiêu đề phải có ít nhất 10 ký tự';
            }
            return null;
          },
        ),
        SizedBox(height: isTablet ? 20 : 16),

        // Description
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: 'Mô tả chi tiết *',
            hintText: 'Mô tả chi tiết về bài đăng của bạn...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          maxLength: 1000,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập mô tả chi tiết';
            }
            if (value.trim().length < 20) {
              return 'Mô tả phải có ít nhất 20 ký tự';
            }
            return null;
          },
        ),
        SizedBox(height: isTablet ? 20 : 16),

        // Images
        ImageSection(
          images: images,
          onPickImages: onPickImages,
          onRemoveImage: onRemoveImage,
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
        ),
        SizedBox(height: isTablet ? 20 : 16),
      ],
    );
  }
}