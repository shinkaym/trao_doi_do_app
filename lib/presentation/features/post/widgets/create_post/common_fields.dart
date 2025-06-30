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
  // Thêm parameters để kiểm soát auto validation
  final AutovalidateMode titleAutovalidateMode;
  final AutovalidateMode descriptionAutovalidateMode;
  // Thêm parameter cho image validation error
  final String? imageValidationError;

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
    this.titleAutovalidateMode = AutovalidateMode.disabled,
    this.descriptionAutovalidateMode = AutovalidateMode.disabled,
    this.imageValidationError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Field
        _buildTitleField(),
        SizedBox(height: isTablet ? 20 : 16),

        // Description Field
        _buildDescriptionField(),
        SizedBox(height: isTablet ? 20 : 16),

        // Images Section với validation error
        _buildImageSectionWithValidation(),
        SizedBox(height: isTablet ? 20 : 16),
      ],
    );
  }

  Widget _buildImageSectionWithValidation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ImageSection(
          images: images,
          onPickImages: onPickImages,
          onRemoveImage: onRemoveImage,
          isTablet: isTablet,
          theme: theme,
          colorScheme: colorScheme,
        ),
        if (imageValidationError != null) ...[
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            imageValidationError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: titleController,
        style: theme.textTheme.bodyLarge,
        autovalidateMode: titleAutovalidateMode,
        decoration: InputDecoration(
          labelText: 'Tiêu đề bài đăng *',
          labelStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Nhập tiêu đề mô tả ngắn gọn...',
          hintStyle: TextStyle(
            color: theme.hintColor.withOpacity(0.7),
            fontSize: isTablet ? 16 : 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.error, width: 1),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.title_rounded,
              color: Colors.purple.shade600,
              size: isTablet ? 22 : 20,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 20 : 16,
          ),
          counterStyle: TextStyle(
            color: theme.hintColor,
            fontSize: isTablet ? 13 : 12,
          ),
        ),
        maxLength: 100,
        textCapitalization: TextCapitalization.sentences,
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
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: descriptionController,
        style: theme.textTheme.bodyLarge,
        maxLines: 4,
        autovalidateMode: descriptionAutovalidateMode,
        decoration: InputDecoration(
          labelText: 'Mô tả chi tiết *',
          labelStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          hintText: 'Mô tả chi tiết về bài đăng của bạn...',
          hintStyle: TextStyle(
            color: theme.hintColor.withOpacity(0.7),
            fontSize: isTablet ? 16 : 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.error, width: 1),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_rounded,
              color: Colors.teal.shade600,
              size: isTablet ? 22 : 20,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 16,
            vertical: isTablet ? 20 : 16,
          ),
          alignLabelWithHint: true,
          counterStyle: TextStyle(
            color: theme.hintColor,
            fontSize: isTablet ? 13 : 12,
          ),
        ),
        maxLength: 1000,
        textCapitalization: TextCapitalization.sentences,
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
    );
  }
}
