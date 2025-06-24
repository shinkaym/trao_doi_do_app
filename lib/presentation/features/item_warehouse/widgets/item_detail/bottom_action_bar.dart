import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isLostItem;
  final bool isRegistered;
  final bool isLoading;
  final VoidCallback onContact;
  final VoidCallback onRegister;

  const BottomActionBar({
    super.key,
    required this.item,
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.isLostItem,
    required this.isRegistered,
    required this.isLoading,
    required this.onContact,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final registeredUsers = item['registeredUsers'];
    final maxRegistrations = item['maxRegistrations'];
    final isFull = registeredUsers >= maxRegistrations;
    final deadline = item['registrationDeadline'];
    final isExpired = DateTime.now().isAfter(deadline);

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            OutlinedButton.icon(
              onPressed: onContact,
              icon: Icon(Icons.message_outlined, size: isTablet ? 18 : 16),
              label: Text(
                'Liên hệ',
                style: TextStyle(fontSize: isTablet ? 14 : 12),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 12 : 10,
                ),
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    (isRegistered || isFull || isExpired || isLoading)
                        ? null
                        : onRegister,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 12),
                  backgroundColor:
                      isRegistered
                          ? Colors.green
                          : (isFull || isExpired)
                          ? theme.disabledColor
                          : colorScheme.primary,
                ),
                child:
                    isLoading
                        ? SizedBox(
                          width: isTablet ? 20 : 16,
                          height: isTablet ? 20 : 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isRegistered
                                  ? Icons.check_circle
                                  : isFull
                                  ? Icons.close
                                  : isExpired
                                  ? Icons.schedule
                                  : Icons.how_to_reg,
                              size: isTablet ? 18 : 16,
                            ),
                            SizedBox(width: isTablet ? 8 : 6),
                            Text(
                              isRegistered
                                  ? 'Đã đăng ký'
                                  : isFull
                                  ? 'Đã đủ người'
                                  : isExpired
                                  ? 'Hết hạn'
                                  : 'Đăng ký nhận',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
