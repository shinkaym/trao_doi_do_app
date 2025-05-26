// filter_sheet.dart
import 'package:flutter/material.dart';

class FilterSheet extends StatelessWidget {
  final String initialStatus;
  final String initialSort;
  final List<String> statusOptions;
  final List<String> sortOptions;
  final void Function(String status, String sort) onApply;

  const FilterSheet({
    super.key,
    required this.initialStatus,
    required this.initialSort,
    required this.onApply,
    this.statusOptions = const ['Tất cả', 'Đã tìm thấy', 'Chưa tìm thấy'],
    this.sortOptions = const ['Mới nhất', 'Cũ nhất'],
  });

  @override
  Widget build(BuildContext context) {
    String tempStatus = initialStatus;
    String tempSort = initialSort;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tempStatus,
                items: statusOptions
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) => setModalState(() => tempStatus = value!),
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tempSort,
                items: sortOptions
                    .map((sort) => DropdownMenuItem(
                          value: sort,
                          child: Text(sort),
                        ))
                    .toList(),
                onChanged: (value) => setModalState(() => tempSort = value!),
                decoration: const InputDecoration(
                  labelText: 'Thời gian',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onApply(tempStatus, tempSort);
                },
                child: const Text('Áp dụng'),
              ),
            ],
          ),
        );
      },
    );
  }
}
