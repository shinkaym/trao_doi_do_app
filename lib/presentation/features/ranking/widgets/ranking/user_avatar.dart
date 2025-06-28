import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';

class UserAvatar extends StatelessWidget {
  final String avatarBase64;
  final double size;
  final bool isTablet;
  final Color iconColor;

  const UserAvatar({
    super.key,
    required this.avatarBase64,
    required this.size,
    required this.isTablet,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarBase64.isEmpty) {
      return Icon(Icons.person, size: isTablet ? 35 : 30, color: iconColor);
    }

    final imageBytes = Base64Utils.decodeImageFromBase64(avatarBase64);
    if (imageBytes == null) {
      return Icon(Icons.person, size: isTablet ? 35 : 30, color: iconColor);
    }

    return Image.memory(
      imageBytes,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) =>
              Icon(Icons.person, size: isTablet ? 35 : 30, color: iconColor),
    );
  }
}
