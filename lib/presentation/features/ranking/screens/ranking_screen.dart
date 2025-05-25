import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/ranking_list.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/your_info_card.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MainLayout(
      title: 'Bảng Xếp Hạng',
      notificationCount: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const YourInfoCard(),
          const SizedBox(height: 20),
          Text(
            'Bảng xếp hạng',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const RankingList(),
        ],
      ),
    );
  }
}
