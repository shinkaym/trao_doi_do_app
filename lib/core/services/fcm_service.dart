import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:trao_doi_do_app/core/services/fcm_navigation_service.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static ILogger? _logger;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static Future<void> initialize([ProviderContainer? container]) async {
    // Initialize logger if container is provided
    if (container != null) {
      try {
        _logger = container.read(loggerProvider);
      } catch (e) {
        // Fallback if logger is not available
        _logger = null;
      }
    }

    // Check current permission status (don't request, just check)
    NotificationSettings settings = await _messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger?.i('✅ FCM: Notification permission is granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      _logger?.i('⚠️ FCM: Notification permission is provisional');
    } else {
      _logger?.w('❌ FCM: Notification permission is not granted');
      // Don't return early - still initialize FCM for when permission is granted later
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle initial message if app was opened from notification
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false, // Don't request here
          requestBadgePermission: false, // Don't request here
          requestSoundPermission: false, // Don't request here
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  static Future<String?> getFcmToken() async {
    try {
      String? token = await _messaging.getToken();
      _logger?.i('✅ FCM Token obtained', {
        'token': token!.substring(0, 20) + '...',
      });
      return token;
    } catch (e) {
      _logger?.e('❌ Error getting FCM token', e);
      return null;
    }
  }

  static void onTokenRefresh(Function(String) onTokenReceived) {
    _messaging.onTokenRefresh.listen((token) {
      _logger?.i('🔄 FCM Token refreshed', {
        'token': token.substring(0, 20) + '...',
      });
      onTokenReceived(token);
    });
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger?.i('📱 Received foreground message', {
      'messageId': message.messageId,
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    });

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: _createPayload(message),
      );

      _logger?.i('🔔 Local notification shown', {
        'title': notification.title,
        'body': notification.body,
        'messageId': message.messageId,
      });
    }
  }

  static String _createPayload(RemoteMessage message) {
    // Convert message data to JSON string for payload
    Map<String, dynamic> payload = {
      'data': message.data,
      'messageId': message.messageId,
    };
    return jsonEncode(payload);
  }

  static void _handleNotificationTap(RemoteMessage message) {
    _logger?.logUserAction('notification_tapped', {
      'messageId': message.messageId,
      'data': message.data,
    });

    // Use navigation service to handle navigation
    FcmNavigationService.handleNotificationNavigation(message.data);
  }

  static void _onNotificationTap(NotificationResponse response) {
    _logger?.logUserAction('local_notification_tapped', {
      'payload': response.payload,
    });

    if (response.payload != null) {
      try {
        Map<String, dynamic> payload = jsonDecode(response.payload!);
        Map<String, dynamic> data = payload['data'] ?? {};

        // Use navigation service to handle navigation
        FcmNavigationService.handleNotificationNavigation(data);
      } catch (e) {
        _logger?.e('❌ Error parsing notification payload', e);
        // Fallback to notifications screen
        FcmNavigationService.navigateToNotifications();
      }
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger?.i('✅ Subscribed to topic', {'topic': topic});
    } catch (e) {
      _logger?.e('❌ Failed to subscribe to topic', e);
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger?.i('✅ Unsubscribed from topic', {'topic': topic});
    } catch (e) {
      _logger?.e('❌ Failed to unsubscribe from topic', e);
    }
  }

  /// Method to refresh FCM setup after permission is granted
  /// Call this after user grants notification permission
  static Future<void> refreshAfterPermissionGranted() async {
    _logger?.i('🔄 Refreshing FCM after permission granted');

    // Re-check permission status
    NotificationSettings settings = await _messaging.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get fresh token after permission is granted
      await getFcmToken();

      _logger?.i('✅ FCM refreshed successfully after permission granted');
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: Logger might not be available in background handler
  // Using print as fallback for background messages
  print('📧 Handling background message: ${message.messageId}');
  print('📧 Background message data: ${message.data}');

  // You can process the message here
  // For example, update local database, show notification, etc.
  // But avoid navigation here as the app might not be fully initialized
}
