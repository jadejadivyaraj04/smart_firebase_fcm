import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize({Function(String?)? onTap}) async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS-specific initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false, // Disable badge permissions
      requestSoundPermission: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Set up the tap handler
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (onTap != null) {
          onTap(response.payload);
        }
      },
    );

    // Request iOS permissions explicitly
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }
  }

  static Future<void> _requestIOSPermissions() async {
    try {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: false,
          );
      
      print('📱 iOS Notification permissions granted: $result');
    } catch (e) {
      print('⚠️ Error requesting iOS permissions: $e');
    }
  }

  static void showNotification(RemoteMessage message) {
    // Android notification details
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,      // Show alert even when app is in foreground
      presentBadge: false,     // Disable badge display
      presentSound: true,      // Play sound
      categoryIdentifier: 'message', // Category for actions
      threadIdentifier: 'fcm', // Group notifications by thread
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    _notificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      platformDetails,
      payload: message.data.toString(),
    );
  }

  /// Show a custom notification with more control
  static Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? categoryIdentifier,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'custom_channel',
      'Custom Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false, // Disable badge display
      presentSound: true,
      categoryIdentifier: categoryIdentifier ?? 'default',
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
