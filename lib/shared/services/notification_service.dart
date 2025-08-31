import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:task_flow/core/utils/logger.dart';

class NotificationService {
  final FirebaseMessaging _messaging;

  NotificationService({required FirebaseMessaging messaging})
      : _messaging = messaging;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      Logger.info('Notification permission status: ${settings.authorizationStatus}');

      // Get the token
      final token = await _messaging.getToken();
      Logger.info('FCM registration token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        Logger.info('Received a message in foreground: ${message.messageId}');
        _handleMessage(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle when app is opened from terminated state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Logger.info('App opened from terminated state: ${message.messageId}');
        _handleMessage(message);
      });
    } catch (e) {
      Logger.error('Failed to initialize notification service: $e');
    }
  }

  /// Handle incoming messages
  void _handleMessage(RemoteMessage message) {
    Logger.info('Handling message with data: ${message.data}');
    
    // Extract notification data
    final title = message.notification?.title ?? 'TaskFlow Notification';
    final body = message.notification?.body ?? '';
    
    // Show local notification or update UI
    // This would typically integrate with a local notification package
    Logger.info('Notification: $title - $body');
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      Logger.error('Failed to get FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      Logger.info('Subscribed to topic: $topic');
    } catch (e) {
      Logger.error('Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      Logger.info('Unsubscribed from topic: $topic');
    } catch (e) {
      Logger.error('Failed to unsubscribe from topic $topic: $e');
    }
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This method will be called when app is in background or terminated
  Logger.info('Handling a background message: ${message.messageId}');
  
  // Handle the background message
  // Note: This method must be a top-level function or static method
  // and must be annotated with @pragma('vm:entry-point')
}