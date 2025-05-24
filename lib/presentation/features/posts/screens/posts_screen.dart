import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      title: 'Bài đăng',
      notificationCount: 3,
      child: Placeholder(child:Text("data"),)
    );
  }
}
