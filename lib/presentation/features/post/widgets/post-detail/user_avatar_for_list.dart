import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';
import 'package:trao_doi_do_app/domain/entities/post.dart';

class UserAvatarForList extends StatelessWidget {
  final PostInterest interest;
  final bool isTablet;
  final ColorScheme colorScheme;

  const UserAvatarForList({
    super.key,
    required this.interest,
    required this.isTablet,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final radius = isTablet ? 22.0 : 18.0;

    if (interest.userAvatar.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(interest.userAvatar);

      if (imageBytes != null) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(imageBytes),
          backgroundColor: Colors.grey[200],
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        interest.userName.isNotEmpty ? interest.userName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
