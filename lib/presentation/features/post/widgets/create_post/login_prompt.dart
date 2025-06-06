import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/widgets/auth_link.dart';

class LoginPrompt extends StatelessWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const LoginPrompt({
    super.key,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  Icons.edit_note_outlined,
                  size: isTablet ? 80 : 64,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
                SizedBox(height: isTablet ? 24 : 20),

                // Title
                Text(
                  'Đăng nhập để tạo bài đăng',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 24 : 20,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isTablet ? 16 : 12),

                // Description
                Text(
                  'Bạn cần đăng nhập để có thể tạo và đăng bài. Đăng nhập ngay để trải nghiệm đầy đủ tính năng.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isTablet ? 16 : 14,
                    color: theme.hintColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isTablet ? 40 : 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 56 : 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.pushNamed('login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.login),
                    label: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: isTablet ? 16 : 12),

                AuthLink(
                  question: 'Chưa có tài khoản? ',
                  linkText: 'Đăng ký ngay',
                  onTap: () => context.pushNamed('register'),
                ),
                SizedBox(height: isTablet ? 32 : 24),

                // Optional: Guest browsing info
                Container(
                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: isTablet ? 20 : 16,
                        color: colorScheme.primary,
                      ),
                      SizedBox(width: isTablet ? 12 : 8),
                      Expanded(
                        child: Text(
                          'Bạn có thể xem các bài đăng khác mà không cần đăng nhập',
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 12,
                            color: theme.hintColor,
                          ),
                        ),
                      ),
                    ],
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
