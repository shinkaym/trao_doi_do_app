import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/core/utils/base64_utils.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String displayName;
  final String displayAvatar;
  final bool isPostOwner;
  final bool isTablet;
  final VoidCallback onBackPressed;

  const ChatAppBar({
    super.key,
    required this.displayName,
    required this.displayAvatar,
    required this.isPostOwner,
    required this.isTablet,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: onBackPressed,
        icon: const Icon(Icons.arrow_back),
      ),
      title: InkWell(
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              _buildDisplayAvatar(displayAvatar, isTablet, colorScheme),

              SizedBox(width: isTablet ? 12 : 8),

              // User info
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildDisplayAvatar(
    String displayAvatar,
    bool isTablet,
    ColorScheme colorScheme,
  ) {
    final radius = isTablet ? 12.0 : 10.0;

    if (displayAvatar.isNotEmpty) {
      final imageBytes = Base64Utils.decodeImageFromBase64(displayAvatar);

      if (imageBytes != null) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: MemoryImage(imageBytes),
          child: null,
        );
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        size: isTablet ? 14 : 12,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
