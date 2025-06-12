import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/presentation/common/screens/not_found_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/forgot_password_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/login_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/register_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/reset_password_screen.dart';
import 'package:trao_doi_do_app/presentation/features/interests/screens/interest_chat_screen.dart';
import 'package:trao_doi_do_app/presentation/features/interests/screens/interests_screen.dart';
import 'package:trao_doi_do_app/presentation/features/onboarding/providers/onboarding_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/create_post_screen.dart';
import 'package:trao_doi_do_app/presentation/features/splash/providers/splash_provider.dart';
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
import 'package:trao_doi_do_app/presentation/models/interest_chat_transaction_data.dart';
import 'package:trao_doi_do_app/presentation/widgets/scaffold_with_navbar.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';

// Create a separate provider for router state to prevent circular dependencies
final _routerStateProvider = Provider<RouterState>((ref) {
  final authState = ref.watch(authProvider);
  final isOnboardingCompleted = ref.watch(isOnboardingCompletedProvider);
  final isSplashCompleted = ref.watch(isSplashCompletedProvider);

  return RouterState(
    isLoggedIn: authState.isLoggedIn,
    isLoading: authState.isLoading,
    isOnboardingCompleted: isOnboardingCompleted,
    isSplashCompleted: isSplashCompleted,
  );
});

class RouterState {
  final bool isLoggedIn;
  final bool isLoading;
  final bool isOnboardingCompleted;
  final bool isSplashCompleted;

  const RouterState({
    required this.isLoggedIn,
    required this.isLoading,
    required this.isOnboardingCompleted,
    required this.isSplashCompleted,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouterState &&
          runtimeType == other.runtimeType &&
          isLoggedIn == other.isLoggedIn &&
          isLoading == other.isLoading &&
          isOnboardingCompleted == other.isOnboardingCompleted &&
          isSplashCompleted == other.isSplashCompleted;

  @override
  int get hashCode =>
      isLoggedIn.hashCode ^
      isLoading.hashCode ^
      isOnboardingCompleted.hashCode ^
      isSplashCompleted.hashCode;
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/interests/chat/1',
    errorBuilder: (context, state) => const NotFoundScreen(),
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      final routerState = ref.read(_routerStateProvider);
      final currentPath = state.uri.toString();

      // Prevent redirect during loading
      if (routerState.isLoading) return null;

      // Handle splash completion
      if (currentPath == '/splash' && routerState.isSplashCompleted) {
        if (!routerState.isOnboardingCompleted) {
          return '/onboarding';
        }
        return '/posts';
      }

      // Stay on splash while it's active
      if (currentPath == '/splash') {
        return null;
      }

      // Protected routes
      final protectedRoutes = [
        '/profile/edit',
        '/profile/change-password',
        // '/interests/chat',
      ];

      for (final route in protectedRoutes) {
        if (currentPath.startsWith(route)) {
          if (!routerState.isLoggedIn) {
            return '/login';
          }
        }
      }

      // Auth routes - redirect if already logged in
      final authRoutes = [
        '/login',
        '/register',
        '/forgot-password',
        '/reset-password',
        '/onboarding',
      ];

      if (authRoutes.any((route) => currentPath.startsWith(route))) {
        if (routerState.isLoggedIn) {
          return '/posts';
        }
      }

      return null;
    },
    routes: _buildRoutes(),
  );
});

// Custom RouterNotifier to handle state changes properly
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterState? _lastState;

  RouterNotifier(this._ref) {
    _ref.listen<RouterState>(_routerStateProvider, (previous, next) {
      if (_lastState != next) {
        _lastState = next;
        notifyListeners();
      }
    });
  }
}

// Improved index calculation
int calculateCurrentIndex(String location) {
  final routePatterns = <String, int>{
    '/posts': 0,
    '/warehouse': 1,
    '/interests': 2,
    '/ranking': 3,
    '/profile': 4,
  };

  final subRouteMapping = <String, int>{
    '/posts/post-detail': 0,
    '/posts/create-post': 0,
    '/warehouse/item-detail': 1,
    '/interests/chat': 2,
    '/profile/edit': 4,
    '/profile/change-password': 4,
  };

  // Check sub-routes first
  for (final entry in subRouteMapping.entries) {
    if (location.startsWith(entry.key)) {
      return entry.value;
    }
  }

  // Check main routes
  for (final entry in routePatterns.entries) {
    if (location.startsWith(entry.key)) {
      return entry.value;
    }
  }

  // Special case for notifications
  if (location.startsWith('/notifications')) {
    return -1;
  }

  return 0;
}

List<RouteBase> _buildRoutes() {
  return [..._buildStandaloneRoutes(), _buildShellRoute()];
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
      return ScaffoldWithNavBar(
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
        child: child,
      );
    },
    routes: [
      _buildPostsRoute(),
      _buildWarehouseRoute(),
      _buildInterestsRoute(),
      _buildRankingRoute(),
      _buildProfileRoute(),
      _buildNotificationRoute(),
    ],
  );
}

GoRoute _buildPostsRoute() {
  return GoRoute(
    path: '/posts',
    name: 'posts',
    builder: (context, state) => const PostsScreen(),
    routes: [
      GoRoute(
        path: 'post-detail/:slug',
        name: 'post-detail',
        builder: (context, state) {
          final postSlug = state.pathParameters['slug']!;
          return PostDetailScreen(postSlug: postSlug);
        },
      ),
      GoRoute(
        path: 'create-post',
        name: 'create-post',
        builder: (context, state) => const CreatePostScreen(),
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
        path: 'chat/:interestId',
        name: 'interest-chat',
        builder: (context, state) {
          final interestId = state.pathParameters['interestId']!;
          final extraData = state.extra as InterestChatTransactionData?;
          
          return InterestChatScreen(
            interestId: interestId,
            // transactionData: extraData,
          );
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
