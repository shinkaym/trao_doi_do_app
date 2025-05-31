import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/common/screens/not_found_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/forgot_password_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/login_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/register_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/reset_password_screen.dart';
import 'package:trao_doi_do_app/presentation/features/interests/screens/interest_chat_screen.dart';
import 'package:trao_doi_do_app/presentation/features/interests/screens/interests_screen.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/create_post_screen.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/screens/item_detail_screen.dart';
import 'package:trao_doi_do_app/presentation/features/notification/screens/notification_screen.dart';
import 'package:trao_doi_do_app/presentation/features/onboarding/screens/onboarding_screen.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/post_detail_screen.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/posts_screen.dart';
import 'package:trao_doi_do_app/presentation/features/profile/screens/change_password_screen.dart';
import 'package:trao_doi_do_app/presentation/features/profile/screens/edit_profile_screen.dart';
import 'package:trao_doi_do_app/presentation/features/profile/screens/profile_screen.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/screens/ranking_screen.dart';
import 'package:trao_doi_do_app/presentation/features/splash/screens/splash_screen.dart';
import 'package:trao_doi_do_app/presentation/features/warehouse/screens/warehouse_screen.dart';
import 'package:trao_doi_do_app/presentation/widgets/scaffold_with_navbar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: _buildRoutes(),
  );
});

// Cải thiện hàm tính toán index với logic xử lý sub-routes
int calculateCurrentIndex(String location) {
  // Map các route patterns với index tương ứng
  final routePatterns = <String, int>{
    // '/home': 0,
    '/posts': 0,
    '/warehouse': 1,
    '/interests': 2,
    '/ranking': 3,
    '/profile': 4,
  };

  // Xử lý các sub-routes đặc biệt
  final subRouteMapping = <String, int>{
    // Posts sub-routes
    '/posts/post-detail': 0,

    // Warehouse sub-routes
    '/warehouse/item-detail': 1,

    // Interests sub-routes
    '/interests/chat': 2,

    // Profile sub-routes
    '/profile/edit': 4,
    '/profile/change-password': 4,
    '/profile/requests': 4,
    '/profile/requests/detail': 4,
  };

  // Kiểm tra sub-routes trước
  for (final entry in subRouteMapping.entries) {
    if (location.startsWith(entry.key)) {
      return entry.value;
    }
  }

  // Kiểm tra main routes
  for (final entry in routePatterns.entries) {
    if (location.startsWith(entry.key)) {
      return entry.value;
    }
  }

  // Trường hợp đặc biệt cho notifications (không có trong bottom nav)
  if (location.startsWith('/notifications')) {
    return -1; // Không highlight tab nào
  }

  return 0; // Default về home
}

List<RouteBase> _buildRoutes() {
  return [
    // Standalone routes (không có bottom navigation)
    ..._buildStandaloneRoutes(),

    // Shell route với bottom navigation
    _buildShellRoute(),
  ];
}

List<GoRoute> _buildStandaloneRoutes() {
  return [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder:
          (context, state) =>
              ResetPasswordScreen(email: state.extra as String? ?? ''),
    ),
  ];
}

ShellRoute _buildShellRoute() {
  return ShellRoute(
    builder: (context, state, child) {
      final currentIndex = calculateCurrentIndex(state.uri.toString());

      // Nếu currentIndex = -1, ẩn bottom nav hoặc không highlight tab nào
      return ScaffoldWithNavBar(
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
        // showNavBar: currentIndex >= 0, // Thêm property này nếu cần
        child: child,
      );
    },
    routes: [
      // Main navigation routes
      // _buildHomeRoute(),
      _buildPostsRoute(),
      _buildWarehouseRoute(),
      _buildInterestsRoute(),
      _buildRankingRoute(),
      _buildProfileRoute(),

      // Other routes within shell
      _buildNotificationRoute(),
    ],
  );
}

// GoRoute _buildHomeRoute() {
//   return GoRoute(
//     path: '/home',
//     name: 'home',
//     builder: (context, state) => const HomeScreen(),
//   );
// }

GoRoute _buildPostsRoute() {
  return GoRoute(
    path: '/posts',
    name: 'posts',
    builder: (context, state) => const PostsScreen(),
    routes: [
      GoRoute(
        path: 'post-detail/:id',
        name: 'post-detail',
        builder: (context, state) {
          final postId = state.pathParameters['id']!;
          return PostDetailScreen(postId: postId);
        },
      ),
      GoRoute(
        path: 'create-post',
        name: 'create-post',
        builder: (context, state) {
          return CreatePostScreen();
        },
      ),
    ],
  );
}

GoRoute _buildWarehouseRoute() {
  return GoRoute(
    path: '/warehouse',
    name: 'warehouse',
    builder: (context, state) => const WarehouseScreen(),
    routes: [
      GoRoute(
        path: 'item-detail/:id',
        name: 'item-detail',
        builder: (context, state) {
          final itemId = state.pathParameters['id']!;
          return ItemDetailScreen(itemId: itemId);
        },
      ),
    ],
  );
}

GoRoute _buildInterestsRoute() {
  return GoRoute(
    path: '/interests',
    name: 'interests',
    builder: (context, state) => const InterestsScreen(),
    routes: [
      GoRoute(
        path: '/interests/:interestId/chat',
        name: 'interest-chat',
        builder: (context, state) {
          final interestId = state.pathParameters['interestId']!;
          return InterestChatScreen(interestId: interestId);
        },
      ),
    ],
  );
}

GoRoute _buildRankingRoute() {
  return GoRoute(
    path: '/ranking',
    name: 'ranking',
    builder: (context, state) => const RankingScreen(),
  );
}

GoRoute _buildProfileRoute() {
  return GoRoute(
    path: '/profile',
    name: 'profile',
    builder: (context, state) => const ProfileScreen(),
    routes: [
      GoRoute(
        path: 'edit',
        name: 'edit-profile',
        builder: (context, state) => EditProfileScreen(),
      ),
      GoRoute(
        path: 'change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
}

GoRoute _buildNotificationRoute() {
  return GoRoute(
    path: '/notifications',
    name: 'notifications',
    builder: (context, state) => const NotificationScreen(),
  );
}
