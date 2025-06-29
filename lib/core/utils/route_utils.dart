import 'package:trao_doi_do_app/core/constants/route_constants.dart';

class RouteUtils {
  RouteUtils._();

  /// Check if a route requires authentication
  /// TẤT CẢ các màn hình chính đều yêu cầu đăng nhập
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
  /// Home (index 0) là màn hình mặc định
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

    return 0; // Default to home (index 0)
  }

  /// Utility method to get clean route path (without parameters and query)
  static String getCleanRoutePath(String route) {
    final uri = Uri.parse(route);
    return uri.path;
  }

  /// Check if user needs to be authenticated to access this route
  static bool requiresAuthentication(String route) {
    return isProtectedRoute(route);
  }

  /// Check if route is a main navigation route
  static bool isMainNavigationRoute(String route) {
    final cleanRoute = getCleanRoutePath(route);
    return RouteConstants.navigationRoutes.containsKey(cleanRoute);
  }

  /// Get the main navigation route that corresponds to a sub-route
  static String? getMainNavigationRoute(String route) {
    final cleanRoute = getCleanRoutePath(route);

    // Check if it's already a main route
    if (RouteConstants.navigationRoutes.containsKey(cleanRoute)) {
      return cleanRoute;
    }

    // Find corresponding main route for sub-routes
    for (final entry in RouteConstants.subRouteMapping.entries) {
      if (_routeMatches(cleanRoute, entry.key)) {
        // Find the main route with matching index
        for (final mainEntry in RouteConstants.navigationRoutes.entries) {
          if (mainEntry.value == entry.value) {
            return mainEntry.key;
          }
        }
      }
    }

    return RouteConstants.home; // Default to home
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

  /// Get route hierarchy (useful for breadcrumbs)
  static List<String> getRouteHierarchy(String route) {
    final cleanRoute = getCleanRoutePath(route);
    final segments = cleanRoute.split('/').where((s) => s.isNotEmpty).toList();

    final hierarchy = <String>[];
    String currentPath = '';

    for (final segment in segments) {
      currentPath += '/$segment';
      hierarchy.add(currentPath);
    }

    return hierarchy;
  }

  /// Check if route is a child of another route
  static bool isChildRoute(String childRoute, String parentRoute) {
    final cleanChild = getCleanRoutePath(childRoute);
    final cleanParent = getCleanRoutePath(parentRoute);

    return cleanChild.startsWith(cleanParent) &&
        cleanChild != cleanParent &&
        cleanChild.length > cleanParent.length;
  }

  /// Get parent route path
  static String? getParentRoute(String route) {
    final cleanRoute = getCleanRoutePath(route);
    final lastSlashIndex = cleanRoute.lastIndexOf('/');

    if (lastSlashIndex <= 0) return null;

    return cleanRoute.substring(0, lastSlashIndex);
  }

  /// Extract route parameters from path
  static Map<String, String> extractParameters(String route, String pattern) {
    final parameters = <String, String>{};
    final routeSegments = route.split('/');
    final patternSegments = pattern.split('/');

    if (routeSegments.length != patternSegments.length) {
      return parameters;
    }

    for (int i = 0; i < patternSegments.length; i++) {
      final patternSegment = patternSegments[i];
      if (patternSegment.startsWith(':')) {
        final paramName = patternSegment.substring(1);
        parameters[paramName] = routeSegments[i];
      }
    }

    return parameters;
  }

  /// Check if route contains parameters
  static bool hasParameters(String route) {
    return route.contains(':') || Uri.parse(route).queryParameters.isNotEmpty;
  }

  /// Get route without parameters (clean template)
  static String getRouteTemplate(String route) {
    final uri = Uri.parse(route);
    return uri.path.replaceAllMapped(RegExp(r'/[^/]+'), (match) {
      final segment = match.group(0)!;
      // If segment looks like an ID or parameter, replace with template
      if (RegExp(r'^/[\w-]{8,}$').hasMatch(segment) ||
          RegExp(r'^/\d+$').hasMatch(segment)) {
        return '/:param';
      }
      return segment;
    });
  }

  /// Validate route format
  static bool isValidRoute(String route) {
    try {
      final uri = Uri.parse(route);
      return uri.path.isNotEmpty && uri.path.startsWith('/');
    } catch (e) {
      return false;
    }
  }

  /// Get route depth (number of segments)
  static int getRouteDepth(String route) {
    final cleanRoute = getCleanRoutePath(route);
    return cleanRoute.split('/').where((s) => s.isNotEmpty).length;
  }

  /// Check if route is root level
  static bool isRootRoute(String route) {
    return getRouteDepth(route) <= 1;
  }

  /// Get suggested navigation action for route
  static NavigationAction getSuggestedNavigationAction(
    String currentRoute,
    String targetRoute,
  ) {
    if (isChildRoute(targetRoute, currentRoute)) {
      return NavigationAction.push;
    } else if (isChildRoute(currentRoute, targetRoute)) {
      return NavigationAction.pop;
    } else if (isMainNavigationRoute(targetRoute)) {
      return NavigationAction.pushAndClearStack;
    } else {
      return NavigationAction.pushReplacement;
    }
  }

  /// Convert route to human-readable title
  static String routeToTitle(String route) {
    final cleanRoute = getCleanRoutePath(route);
    final segments = cleanRoute.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return 'Home';

    final lastSegment = segments.last;
    return lastSegment
        .split('-')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  /// Get all possible routes from current route
  static List<String> getPossibleNextRoutes(String currentRoute) {
    final possibleRoutes = <String>[];

    // Add parent route if exists
    final parent = getParentRoute(currentRoute);
    if (parent != null) {
      possibleRoutes.add(parent);
    }

    // Add main navigation routes
    possibleRoutes.addAll(RouteConstants.navigationRoutes.keys);

    // Add common sub-routes based on current route
    if (isMainNavigationRoute(currentRoute)) {
      possibleRoutes.addAll(
        RouteConstants.subRouteMapping.keys.where(
          (route) => route.startsWith(currentRoute),
        ),
      );
    }

    // Remove duplicates and current route
    return possibleRoutes
        .where((route) => route != currentRoute)
        .toSet()
        .toList();
  }
}

enum NavigationAction { push, pop, pushReplacement, pushAndClearStack }
