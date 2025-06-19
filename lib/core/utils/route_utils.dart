import 'package:trao_doi_do_app/core/constants/route_constants.dart';

class RouteUtils {
  RouteUtils._();

  /// Check if a route requires authentication
  static bool isProtectedRoute(String route) {
    return _matchesAnyRoute(route, RouteConstants.protectedRoutes);
  }

  /// Check if a route is an auth route
  static bool isAuthRoute(String route) {
    return _matchesAnyRoute(route, RouteConstants.authRoutes);
  }

  /// Check if navigation bar should be shown for a route
  static bool shouldShowNavBar(String route) {
    return !_matchesAnyRoute(route, RouteConstants.routesWithoutNavBar);
  }

  /// Calculate navigation index for a route
  static int calculateNavigationIndex(String route) {
    final cleanRoute = getCleanRoutePath(route);

    // Check sub-routes first (more specific)
    for (final entry in RouteConstants.subRouteMapping.entries) {
      if (_routeMatches(cleanRoute, entry.key)) {
        return entry.value;
      }
    }

    // Check main routes
    for (final entry in RouteConstants.navigationRoutes.entries) {
      if (_routeMatches(cleanRoute, entry.key)) {
        return entry.value;
      }
    }

    // Special case for notifications
    if (_routeMatches(cleanRoute, RouteConstants.notifications)) {
      return -1;
    }

    return 0; // Default to posts
  }

  /// Utility method to get clean route path (without parameters and query)
  static String getCleanRoutePath(String route) {
    final uri = Uri.parse(route);
    return uri.path;
  }

  /// Private method to check if route matches any pattern in a set
  static bool _matchesAnyRoute(String route, Set<String> patterns) {
    final cleanRoute = getCleanRoutePath(route);

    return patterns.any((pattern) => _routeMatches(cleanRoute, pattern));
  }

  /// Private method to check if a route matches a specific pattern
  static bool _routeMatches(String route, String pattern) {
    // Exact match
    if (route == pattern) return true;

    // Check if route starts with pattern and is followed by a path separator
    if (route.startsWith(pattern)) {
      final remaining = route.substring(pattern.length);
      // Ensure it's a proper sub-route (starts with / or is empty)
      return remaining.isEmpty || remaining.startsWith('/');
    }

    return false;
  }

  /// Debug helper to log route matching
  static void debugRouteMatching(String route) {
    print('🔍 Debug route matching for: $route');
    print('  - Clean path: ${getCleanRoutePath(route)}');
    print('  - Is protected: ${isProtectedRoute(route)}');
    print('  - Is auth route: ${isAuthRoute(route)}');
    print('  - Show nav bar: ${shouldShowNavBar(route)}');
    print('  - Navigation index: ${calculateNavigationIndex(route)}');
  }

  /// Get the parent route for a nested route
  static String? getParentRoute(String route) {
    final cleanRoute = getCleanRoutePath(route);

    // Check if it's a sub-route
    for (final entry in RouteConstants.subRouteMapping.entries) {
      if (_routeMatches(cleanRoute, entry.key)) {
        // Find the corresponding main route
        for (final mainEntry in RouteConstants.navigationRoutes.entries) {
          if (mainEntry.value == entry.value) {
            return mainEntry.key;
          }
        }
      }
    }

    return null;
  }

  /// Check if current route is a sub-route of a main navigation route
  static bool isSubRoute(String route) {
    return getParentRoute(route) != null;
  }
}
