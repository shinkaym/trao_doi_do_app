import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class RequestItemCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final VoidCallback onTap;

  const RequestItemCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ext.accentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request['type'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(request['status'], style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request['title'],
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Địa điểm: ${request['location']}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(request['date'], style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onTap, child: const Text('Chi tiết')),
          ),
        ],
      ),
    );
  }
}
