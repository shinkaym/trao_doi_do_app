import 'package:flutter/material.dart';
import 'active_filter_chip.dart';

class FilterIndicator extends StatelessWidget {
  final String? selectedType;
  final String? selectedStatus;
  final VoidCallback onRemoveType;
  final VoidCallback onRemoveStatus;

  const FilterIndicator({
    super.key,
    required this.selectedType,
    required this.selectedStatus,
    required this.onRemoveType,
    required this.onRemoveStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedType == null && selectedStatus == null) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            'Đang lọc:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (selectedType != null)
                  ActiveFilterChip(
                    label: selectedType!,
                    onRemove: onRemoveType,
                  ),
                if (selectedStatus != null)
                  ActiveFilterChip(
                    label: selectedStatus!,
                    onRemove: onRemoveStatus,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
