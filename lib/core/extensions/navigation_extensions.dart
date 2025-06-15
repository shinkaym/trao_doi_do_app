import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';

extension NavigationExtensions on BuildContext {
  void pushNamed(
    String name, {
    Object? extra,
    Map<String, String>? pathParameters,
  }) {
    final currentLocation = GoRouter.of(this).routerDelegate.currentConfiguration.uri.toString();
    final targetRoute = _buildRouteFromName(name, pathParameters);
    
    // Log navigation
    _logNavigation(currentLocation, targetRoute, 'pushNamed', {
      'name': name,
      'pathParameters': pathParameters,
      'hasExtra': extra != null,
    });
    
    GoRouter.of(this).pushNamed(
      name, 
      extra: extra, 
      pathParameters: pathParameters ?? {},
    );
  }

  void goNamed(
    String name, {
    Object? extra,
    Map<String, String>? pathParameters,
  }) {
    final currentLocation = GoRouter.of(this).routerDelegate.currentConfiguration.uri.toString();
    final targetRoute = _buildRouteFromName(name, pathParameters);
    
    // Log navigation
    _logNavigation(currentLocation, targetRoute, 'goNamed', {
      'name': name,
      'pathParameters': pathParameters,
      'hasExtra': extra != null,
    });
    
    GoRouter.of(this).goNamed(
      name, 
      extra: extra, 
      pathParameters: pathParameters ?? {},
    );
  }

  void pushReplacement(String location, {Object? extra}) {
    final currentLocation = GoRouter.of(this).routerDelegate.currentConfiguration.uri.toString();
    
    // Log navigation
    _logNavigation(currentLocation, location, 'pushReplacement', {
      'hasExtra': extra != null,
    });
    
    GoRouter.of(this).pushReplacement(location, extra: extra);
  }

  void go(String location, {Object? extra}) {
    final currentLocation = GoRouter.of(this).routerDelegate.currentConfiguration.uri.toString();
    
    // Log navigation
    _logNavigation(currentLocation, location, 'go', {
      'hasExtra': extra != null,
    });
    
    GoRouter.of(this).go(location, extra: extra);
  }

  void pop([Object? result]) {
    final currentLocation = GoRouter.of(this).routerDelegate.currentConfiguration.uri.toString();
    
    // Log navigation
    _logNavigation(currentLocation, '[BACK]', 'pop', {
      'hasResult': result != null,
      'canPop': canPop,
    });
    
    GoRouter.of(this).pop(result);
  }

  bool get canPop => Navigator.of(this).canPop();

  void push(String location, {Object? extra}) {
    final currentLocation = GoRouter.of(this).routerDelegate.currentConfiguration.uri.toString();
    
    // Log navigation
    _logNavigation(currentLocation, location, 'push', {
      'hasExtra': extra != null,
    });
    
    GoRouter.of(this).push(location, extra: extra);
  }

  // Private method để log navigation
  void _logNavigation(
    String from, 
    String to, 
    String method, 
    Map<String, dynamic> additionalData,
  ) {
    // Sử dụng ProviderScope để access logger
    if (this is Element) {
      final element = this as Element;
      final container = ProviderScope.containerOf(element);
      final logger = container.read(loggerProvider);
      
      // Enhanced logging với thêm thông tin context
      final logData = {
        'method': method,
        'timestamp': DateTime.now().toIso8601String(),
        'route_stack_depth': _getRouteStackDepth(),
        ...additionalData,
      };
      
      logger.logUserAction('Navigation: $method', logData);
      logger.i('🧭 Navigation [$method]: $from → $to');
    }
  }

  // Helper method để build route từ name và parameters
  String _buildRouteFromName(String name, Map<String, String>? pathParameters) {
    if (pathParameters == null || pathParameters.isEmpty) {
      return name;
    }
    
    // Simple route building - có thể enhance thêm nếu cần
    final params = pathParameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$name?$params';
  }

  // Helper method để lấy độ sâu của route stack
  int _getRouteStackDepth() {
    try {
      // Sử dụng GoRouter để lấy thông tin route stack
      final goRouter = GoRouter.of(this);
      final currentLocation = goRouter.routerDelegate.currentConfiguration.uri.toString();
      
      // Đếm số segment trong path để estimate depth
      final segments = currentLocation.split('/').where((s) => s.isNotEmpty).length;
      
      // Thêm depth từ Navigator nếu có thể
      if (Navigator.canPop(this)) {
        return segments + 1;
      }
      
      return segments > 0 ? segments : 1;
    } catch (e) {
      return 1; // Default depth
    }
  }
}

// Extension thêm cho advanced navigation logging
extension NavigationLoggingExtensions on BuildContext {
  /// Log custom navigation events
  void logCustomNavigation(String event, Map<String, dynamic>? data) {
    if (this is Element) {
      final element = this as Element;
      final container = ProviderScope.containerOf(element);
      final logger = container.read(loggerProvider);
      
      logger.logUserAction('Custom Navigation: $event', data);
    }
  }
  
  /// Log navigation với performance tracking
  Future<T?> pushNamedWithTracking<T extends Object?>(
    String name, {
    Object? extra,
    Map<String, String>? pathParameters,
  }) async {
    final stopwatch = Stopwatch()..start();
    final currentLocation = GoRouter.of(this).routerDelegate.currentConfiguration.uri.toString();
    
    try {
      final result = await GoRouter.of(this).pushNamed<T>(
        name,
        extra: extra,
        pathParameters: pathParameters ?? {},
      );
      
      stopwatch.stop();
      
      // Log với performance data
      if (this is Element) {
        final element = this as Element;
        final container = ProviderScope.containerOf(element);
        final logger = container.read(loggerProvider);
        
        logger.logUserAction('Navigation Performance', {
          'method': 'pushNamedWithTracking',
          'from': currentLocation,
          'to': name,
          'duration_ms': stopwatch.elapsedMilliseconds,
          'success': true,
          'result_type': result.runtimeType.toString(),
        });
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      
      // Log error
      if (this is Element) {
        final element = this as Element;
        final container = ProviderScope.containerOf(element);
        final logger = container.read(loggerProvider);
        
        logger.e('Navigation Error', e);
        logger.logUserAction('Navigation Performance', {
          'method': 'pushNamedWithTracking',
          'from': currentLocation,
          'to': name,
          'duration_ms': stopwatch.elapsedMilliseconds,
          'success': false,
          'error': e.toString(),
        });
      }
      
      rethrow;
    }
  }
  
  /// Log navigation với performance tracking cho push method
  Future<T?> pushWithTracking<T extends Object?>(
    String location, {
    Object? extra,
  }) async {
    final stopwatch = Stopwatch()..start();
    final currentLocation = GoRouter.of(this).routerDelegate.currentConfiguration.uri.toString();
    
    try {
      final result = await GoRouter.of(this).push<T>(location, extra: extra);
      
      stopwatch.stop();
      
      // Log với performance data
      if (this is Element) {
        final element = this as Element;
        final container = ProviderScope.containerOf(element);
        final logger = container.read(loggerProvider);
        
        logger.logUserAction('Navigation Performance', {
          'method': 'pushWithTracking',
          'from': currentLocation,
          'to': location,
          'duration_ms': stopwatch.elapsedMilliseconds,
          'success': true,
          'result_type': result.runtimeType.toString(),
        });
      }
      
      return result;
    } catch (e) {
      stopwatch.stop();
      
      // Log error
      if (this is Element) {
        final element = this as Element;
        final container = ProviderScope.containerOf(element);
        final logger = container.read(loggerProvider);
        
        logger.e('Navigation Error', e);
        logger.logUserAction('Navigation Performance', {
          'method': 'pushWithTracking',
          'from': currentLocation,
          'to': location,
          'duration_ms': stopwatch.elapsedMilliseconds,
          'success': false,
          'error': e.toString(),
        });
      }
      
      rethrow;
    }
  }
}