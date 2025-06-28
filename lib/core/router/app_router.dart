import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/core/constants/route_constants.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/utils/route_utils.dart';
import 'package:trao_doi_do_app/presentation/common/screens/not_found_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/forgot_password_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/login_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/register_screen.dart';
import 'package:trao_doi_do_app/presentation/features/auth/screens/reset_password_screen.dart';
import 'package:trao_doi_do_app/presentation/features/home/screens/home_screen.dart';
import 'package:trao_doi_do_app/presentation/features/interests/screens/interest_chat_screen.dart';
import 'package:trao_doi_do_app/presentation/features/interests/screens/interests_screen.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/screens/item_warehouses_screen.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/create_post_screen.dart';
import 'package:trao_doi_do_app/presentation/features/profile/screens/my_posts_screen.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/screens/item_detail_screen.dart';
import 'package:trao_doi_do_app/presentation/features/notification/screens/notification_screen.dart';
import 'package:trao_doi_do_app/presentation/features/onboarding/screens/onboarding_screen.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/post_detail_screen.dart';
import 'package:trao_doi_do_app/presentation/features/post/screens/posts_screen.dart';
import 'package:trao_doi_do_app/presentation/features/profile/screens/change_password_screen.dart';
import 'package:trao_doi_do_app/presentation/features/profile/screens/edit_profile_screen.dart';
import 'package:trao_doi_do_app/presentation/features/profile/screens/profile_screen.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/screens/ranking_screen.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/screens/appointments_screen.dart';
import 'package:trao_doi_do_app/presentation/features/splash/screens/splash_screen.dart';
import 'package:trao_doi_do_app/presentation/widgets/scaffold_with_navbar.dart';

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
    initialLocation: RouteConstants.splash,
    errorBuilder: (context, state) => const NotFoundScreen(),
    refreshListenable: RouterNotifier(ref),
    redirect: (context, state) {
      final routerState = ref.read(_routerStateProvider);
      final currentPath = state.uri.toString();

      // Prevent redirect during loading
      if (routerState.isLoading) return null;

      // Handle splash completion
      if (currentPath == RouteConstants.splash &&
          routerState.isSplashCompleted) {
        if (!routerState.isOnboardingCompleted) {
          return RouteConstants.onboarding;
        }
        // Redirect to home instead of posts after splash
        return RouteConstants.home;
      }

      // Stay on splash while it's active
      if (currentPath == RouteConstants.splash) {
        return null;
      }

      if (RouteUtils.isProtectedRoute(currentPath)) {
        if (!routerState.isLoggedIn) {
          return RouteConstants.login;
        }
      }

      // Auth routes - redirect to home if already logged in
      if (RouteUtils.isAuthRoute(currentPath)) {
        if (routerState.isLoggedIn) {
          return RouteConstants.home; // Redirect to home instead of posts
        }
      }

      return null;
    },
    routes: _buildRoutes(),
  );
});

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

List<RouteBase> _buildRoutes() {
  return [..._buildStandaloneRoutes(), _buildShellRoute()];
}

List<GoRoute> _buildStandaloneRoutes() {
  return [
    GoRoute(
      path: RouteConstants.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteConstants.onboarding,
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: RouteConstants.login,
      name: RouteNames.login,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return LoginScreen(extra: extra);
      },
      
    ),
    GoRoute(
      path: RouteConstants.register,
      name: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RouteConstants.forgotPassword,
      name: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RouteConstants.resetPassword,
      name: RouteNames.resetPassword,
      builder:
          (context, state) =>
              ResetPasswordScreen(email: state.extra as String? ?? ''),
    ),
  ];
}

ShellRoute _buildShellRoute() {
  return ShellRoute(
    builder: (context, state, child) {
      final location = state.uri.toString();
      final currentIndex = RouteUtils.calculateNavigationIndex(location);
      final showNavBar = RouteUtils.shouldShowNavBar(location);

      return ScaffoldWithNavBar(
        currentIndex: currentIndex >= 0 ? currentIndex : 0,
        showNavBar: showNavBar,
        child: child,
      );
    },
    routes: [
      _buildHomeRoute(),
      _buildPostsRoute(),
      _buildWarehouseRoute(),
      _buildInterestsRoute(),
      _buildProfileRoute(),
      _buildNotificationRoute(),
    ],
  );
}

// Thêm Home Route
GoRoute _buildHomeRoute() {
  return GoRoute(
    path: RouteConstants.home,
    name: RouteNames.home,
    builder: (context, state) => const HomeScreen(),
  );
}

GoRoute _buildPostsRoute() {
  return GoRoute(
    path: RouteConstants.posts,
    name: RouteNames.posts,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return PostsScreen(extra: extra);
    },
    routes: [
      GoRoute(
        path: '${RouteConstants.postDetail}/:${RouteConstants.slugParam}',
        name: RouteNames.postDetail,
        builder: (context, state) {
          final postSlug = state.pathParameters[RouteConstants.slugParam]!;
          return PostDetailScreen(postSlug: postSlug);
        },
      ),
      GoRoute(
        path: RouteConstants.createPost,
        name: RouteNames.createPost,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CreatePostScreen(extra: extra);
        },
      ),
    ],
  );
}

GoRoute _buildWarehouseRoute() {
  return GoRoute(
    path: RouteConstants.warehouse,
    name: RouteNames.warehouse,
    builder: (context, state) => const ItemWarehousesScreen(),
    routes: [
      GoRoute(
        path: '${RouteConstants.itemDetail}/:${RouteConstants.idParam}',
        name: RouteNames.itemDetail,
        builder: (context, state) {
          final itemId = state.pathParameters[RouteConstants.idParam]!;
          return ItemDetailScreen(itemId: itemId);
        },
      ),
    ],
  );
}

GoRoute _buildInterestsRoute() {
  return GoRoute(
    path: RouteConstants.interests,
    name: RouteNames.interests,
    builder: (context, state) => const InterestsScreen(),
    routes: [
      GoRoute(
        path:
            '${RouteConstants.interestChat}/:${RouteConstants.interestIdParam}',
        name: RouteNames.interestChat,
        builder: (context, state) {
          final interestId =
              state.pathParameters[RouteConstants.interestIdParam]!;

          return InterestChatScreen(interestId: interestId);
        },
      ),
    ],
  );
}

GoRoute _buildProfileRoute() {
  return GoRoute(
    path: RouteConstants.profile,
    name: RouteNames.profile,
    builder: (context, state) => const ProfileScreen(),
    routes: [
      GoRoute(
        path: RouteConstants.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => EditProfileScreen(),
      ),
      GoRoute(
        path: RouteConstants.changePassword,
        name: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: RouteConstants.myPosts,
        name: RouteNames.myPosts,
        builder: (context, state) => const MyPostsScreen(),
      ),
      // Ranking là con của Profile
      GoRoute(
        path: RouteConstants.ranking,
        name: RouteNames.ranking,
        builder: (context, state) => const RankingScreen(),
      ),
      // Appointments là con của Profile
      GoRoute(
        path: RouteConstants.appointments,
        name: RouteNames.appointments,
        builder: (context, state) => const AppointmentsScreen(),
      ),
    ],
  );
}

GoRoute _buildNotificationRoute() {
  return GoRoute(
    path: RouteConstants.notifications,
    name: RouteNames.notifications,
    builder: (context, state) => const NotificationScreen(),
  );
}
