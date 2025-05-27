import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class CustomDateTimePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;
  final bool withTime;

  const CustomDateTimePickerField({
    super.key,
    required this.label,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
    this.withTime = false,
  });

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      if (withTime) {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? now),
        );

        if (pickedTime != null) {
          final combined = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          onDateTimeChanged(combined);
        }
      } else {
        onDateTimeChanged(pickedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final formatted = selectedDateTime != null
        ? DateFormat(withTime ? 'dd/MM/yyyy HH:mm' : 'dd/MM/yyyy').format(selectedDateTime!)
        : 'Chọn ngày${withTime ? ' và giờ' : ''}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDateTime(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: ext.primaryTextColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatted, style: TextStyle(color: ext.primaryTextColor)),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
