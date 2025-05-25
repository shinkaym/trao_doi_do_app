import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Bảng xếp hạng',
      notificationCount: 3,
      child: SizedBox.shrink(),
    );
  }
}
