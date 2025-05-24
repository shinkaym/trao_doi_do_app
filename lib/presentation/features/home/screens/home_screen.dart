import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Trang chủ',
      notificationCount: 3,
      child: SizedBox.shrink(),
    );
  }
}
