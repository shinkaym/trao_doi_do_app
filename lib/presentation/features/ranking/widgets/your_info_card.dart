import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/widgets/info_column.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class YourInfoCard extends StatelessWidget {
  const YourInfoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InfoColumn(label: 'Xếp hạng hiện tại', value: '#4'),
          InfoColumn(label: 'Điểm tích lũy', value: '80'),
          InfoColumn(label: 'Việc tốt', value: '6'),
        ],
      ),
    );
  }
}
