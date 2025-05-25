import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/core/constants/nav_bar_constants.dart';
import 'package:trao_doi_do_app/presentation/common/screens/not_found_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/forgot_password_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/login_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/otp_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/register_screen.dart';
import 'package:trao_doi_do_app/presentation/features/notification/screens/notification_screen.dart';
import 'package:trao_doi_do_app/presentation/features/posts/screens/posts_screen.dart';
import 'package:trao_doi_do_app/presentation/features/profile/screens/profile_screen.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/screens/ranking_screen.dart';
import 'package:trao_doi_do_app/presentation/features/send_item/screens/send_item_screen.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/screens/warehouse_screen.dart';
import 'package:trao_doi_do_app/presentation/widgets/scaffold_with_navbar.dart';
import 'package:trao_doi_do_app/presentation/features/home/screens/home_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

int _calculateIndex(String location) {
  final index = NavBarConstants.routes.indexWhere(
    (r) => location.startsWith(r),
  );
  return index < 0 ? 0 : index;
}

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationScreen(),
    ),

    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        final currentIndex = _calculateIndex(state.uri.toString());
        return ScaffoldWithNavBar(
          currentIndex: currentIndex,
          onTap: (index) => context.go(NavBarConstants.routes[index]),
          child: child,
        );
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/posts',
          builder: (context, state) => const PostsScreen(),
        ),
        GoRoute(
          path: '/warehouse',
          builder: (context, state) => const WarehouseScreen(),
        ),
        GoRoute(
          path: '/send',
          builder: (context, state) => const SendItemScreen(),
        ),
        GoRoute(
          path: '/ranking',
          builder: (context, state) => const RankingScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // auth
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
  ],
);
