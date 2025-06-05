import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
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
          colors: [colorScheme.primary, colorScheme.primary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage(bool isTablet) {
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(57),
        child: Image.file(selectedImage!, fit: BoxFit.cover),
      );
    }

    if (currentAvatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(57),
        child: Image.network(
          currentAvatarUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Icon(
                Icons.person,
                size: isTablet ? 60 : 50,
                color: Colors.white,
              ),
        ),
      );
    }

    return Icon(Icons.person, size: isTablet ? 60 : 50, color: Colors.white);
  }

  Widget _buildEditButton(
    BuildContext context,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    return Positioned(
      bottom: 0,
      right: 0,
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
          ),
          child: Icon(
            Icons.camera_alt,
            size: isTablet ? 20 : 18,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
