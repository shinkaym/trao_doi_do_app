import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';

class WarehouseScreen extends StatelessWidget {
  const WarehouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Kho đồ cũ',
      notificationCount: 3,
      child: SizedBox.shrink(),
    );
  }
}
