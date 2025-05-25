import 'package:flutter/material.dart';

class RankingList extends StatelessWidget {
  const RankingList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rankings = [
      {
        'name': 'Nguyễn Văn A',
        'score': 150,
        'goodDeeds': 12,
        'rank': 1,
        'icon': Icons.emoji_events,
      },
      {
        'name': 'Trần Thị B',
        'score': 120,
        'goodDeeds': 10,
        'rank': 2,
        'icon': Icons.military_tech,
      },
      {
        'name': 'Lê Văn C',
        'score': 100,
        'goodDeeds': 8,
        'rank': 3,
        'icon': Icons.workspace_premium,
      },
      {
        'name': 'Phạm Thị D',
        'score': 80,
        'goodDeeds': 6,
        'rank': 4,
        'icon': Icons.person,
      },
      {
        'name': 'Hoàng Văn E',
        'score': 60,
        'goodDeeds': 5,
        'rank': 5,
        'icon': Icons.person,
      },
    ];

    return Column(
      children:
          rankings.map((user) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(user['icon'] as IconData),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${user['goodDeeds']} việc tốt - ${user['score']} điểm',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '#${user['rank']}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
