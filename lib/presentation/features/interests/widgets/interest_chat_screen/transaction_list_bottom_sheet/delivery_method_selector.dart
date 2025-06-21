import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';

class DeliveryMethodSelector extends StatelessWidget {
  final DeliveryMethod selectedMethod;
  final ValueChanged<DeliveryMethod> onMethodChanged;
  final bool isEditing;
  final bool isLoading;

  const DeliveryMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    this.isEditing = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isTablet = context.isTablet;

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: colorScheme.primary,
                size: isTablet ? 20 : 18,
              ),
              SizedBox(width: isTablet ? 8 : 6),
              Text(
                'Phương thức giao dịch',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),

          // Current method display (when not editing)
          if (!isEditing) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.primary, width: 2),
              ),
              child: Row(
                children: [
                  Icon(
                    selectedMethod == DeliveryMethod.meetInPerson
                        ? Icons.handshake
                        : Icons.delivery_dining,
                    color: colorScheme.primary,
                    size: isTablet ? 18 : 16,
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                  Text(
                    selectedMethod == DeliveryMethod.delivery
                        ? 'Giao hàng'
                        : 'Gặp trực tiếp',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Method selection (when editing)
            Row(
              children: [
                Expanded(
                  child: _buildMethodOption(
                    context: context,
                    method: DeliveryMethod.meetInPerson,
                    icon: Icons.handshake,
                    label: 'Gặp trực tiếp',
                    isSelected: selectedMethod == DeliveryMethod.meetInPerson,
                    onTap:
                        isLoading
                            ? null
                            : () =>
                                onMethodChanged(DeliveryMethod.meetInPerson),
                    isTablet: isTablet,
                    colorScheme: colorScheme,
                  ),
                ),
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: _buildMethodOption(
                    context: context,
                    method: DeliveryMethod.delivery,
                    icon: Icons.delivery_dining,
                    label: 'Giao hàng',
                    isSelected: selectedMethod == DeliveryMethod.delivery,
                    onTap:
                        isLoading
                            ? null
                            : () => onMethodChanged(DeliveryMethod.delivery),
                    isTablet: isTablet,
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodOption({
    required BuildContext context,
    required DeliveryMethod method,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
    required bool isTablet,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              size: isTablet ? 18 : 16,
            ),
            SizedBox(width: isTablet ? 8 : 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
