import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/logged_in_profile.dart';
import 'package:trao_doi_do_app/presentation/features/profile/widgets/logged_out_profile.dart';
import 'package:trao_doi_do_app/presentation/widgets/main_layout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = true;

    return MainLayout(
      title: 'Hồ sơ',
      notificationCount: isLoggedIn ? 2 : 0,
      child: isLoggedIn
          ? const LoggedInProfile()
          : const LoggedOutProfile(),
    );
  }
}
