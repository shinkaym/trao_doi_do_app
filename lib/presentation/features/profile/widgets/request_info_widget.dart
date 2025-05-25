import 'package:flutter/material.dart';

class RequestInfoWidget extends StatelessWidget {
  final String title;
  final String type;
  final String location;
  final String date;

  const RequestInfoWidget({
    super.key,
    required this.title,
    required this.type,
    required this.location,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              Text('Ngày yêu cầu: $date'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Địa điểm: $location')),
            ],
          ),
        ],
      ),
    );
  }
}
