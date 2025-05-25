import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';
import 'filter_chip_widget.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> typeOptions;
  final List<String> statusOptions;
  final String? selectedType;
  final String? selectedStatus;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onStatusChanged;

  const FilterBottomSheet({
    super.key,
    required this.typeOptions,
    required this.statusOptions,
    required this.selectedType,
    required this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? tempSelectedType;
  late String? tempSelectedStatus;

  @override
  void initState() {
    super.initState();
    tempSelectedType = widget.selectedType;
    tempSelectedStatus = widget.selectedStatus;
  }

  void _applyFilters() {
    widget.onTypeChanged(tempSelectedType);
    widget.onStatusChanged(tempSelectedStatus);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Bộ lọc',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Type filter
          Text(
            'Loại yêu cầu',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChipWidget(
                label: 'Tất cả',
                isSelected: tempSelectedType == null,
                onTap: () => setState(() => tempSelectedType = null),
              ),
              ...widget.typeOptions.map(
                (type) => FilterChipWidget(
                  label: type,
                  isSelected: tempSelectedType == type,
                  onTap: () => setState(() => tempSelectedType = type),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status filter
          Text(
            'Trạng thái',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChipWidget(
                label: 'Tất cả',
                isSelected: tempSelectedStatus == null,
                onTap: () => setState(() => tempSelectedStatus = null),
              ),
              ...widget.statusOptions.map(
                (status) => FilterChipWidget(
                  label: status,
                  isSelected: tempSelectedStatus == status,
                  onTap: () => setState(() => tempSelectedStatus = status),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
