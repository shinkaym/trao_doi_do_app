import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class ImagePickerBottomSheet extends StatelessWidget {
  final ImagePicker picker;
  final Function(File image) onImageSelected;
  final String title;

  const ImagePickerBottomSheet({
    super.key,
    required this.picker,
    required this.onImageSelected,
    this.title = 'Chọn ảnh',
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isTablet ? 24 : 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImageSourceOption(
                context,
                icon: Icons.camera_alt,
                label: 'Máy ảnh',
                onTap: () async {
                  context.pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    onImageSelected(File(image.path));
                  }
                },
              ),
              _buildImageSourceOption(
                context,
                icon: Icons.photo_library,
                label: 'Thư viện',
                onTap: () async {
                  context.pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    onImageSelected(File(image.path));
                  }
                },
              ),
            ],
          ),
          SizedBox(height: isTablet ? 32 : 24),
        ],
      ),
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(icon, size: 28, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}
