import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';

class SendItemScreen extends StatelessWidget {
  const SendItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Gửi đồ',
      notificationCount: 3,
      child: SizedBox.shrink(),
    );
  }
}
