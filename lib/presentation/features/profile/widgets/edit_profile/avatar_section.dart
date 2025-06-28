import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'dart:io';

class AvatarSection extends StatelessWidget {
  final File? selectedImage;
  final String currentAvatarUrl;
  final VoidCallback onPickImage;

  const AvatarSection({
    super.key,
    required this.selectedImage,
    required this.currentAvatarUrl,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 40 : 30,
          horizontal: 24,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 120 : 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: _buildAvatarImage(isTablet),
                ),
                _buildEditButton(context, isTablet, colorScheme),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              'Cập nhật ảnh đại diện',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (selectedImage != null) ...[
              SizedBox(height: isTablet ? 8 : 6),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : 10,
                  vertical: isTablet ? 6 : 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ảnh mới đã được chọn',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isTablet ? 12 : 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage(bool isTablet) {
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(57),
        child: Image.file(
          selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    if (currentAvatarUrl.isNotEmpty) {
      // Kiểm tra nếu là base64 data URI
      if (currentAvatarUrl.startsWith('data:')) {
        final imageBytes = Base64Utils.decodeImageFromBase64(currentAvatarUrl);
        if (imageBytes != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(57),
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder:
                  (context, error, stackTrace) => _buildDefaultAvatar(isTablet),
            ),
          );
        }
      }

      // Nếu là URL thông thường
      return ClipRRect(
        borderRadius: BorderRadius.circular(57),
        child: Image.network(
          currentAvatarUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder:
              (context, error, stackTrace) => _buildDefaultAvatar(isTablet),
        ),
      );
    }

    return _buildDefaultAvatar(isTablet);
  }

  Widget _buildDefaultAvatar(bool isTablet) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(57),
      ),
      child: Icon(
        Icons.person,
        size: isTablet ? 60 : 50,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPickImage,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: isTablet ? 40 : 36,
            height: isTablet ? 40 : 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              Icons.camera_alt,
              size: isTablet ? 20 : 18,
              color: colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
