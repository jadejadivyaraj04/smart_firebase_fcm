import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

/// Local Notification Service for handling FCM notifications
/// 
/// Badge Control:
/// - iOS: Badges are controlled via presentBadge parameter in DarwinNotificationDetails
/// - Android: Badges are controlled at the system level and cannot be disabled per notification
///   through flutter_local_notifications. Users can disable badges in system settings.
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static String _androidNotificationIcon = '@mipmap/ic_launcher';

  static Future<void> initialize({
    Function(String?)? onTap,
    String? androidNotificationIcon,
    bool enableBadges = false, // Control notification badges
  }) async {
    // Set custom notification icon if provided
    if (androidNotificationIcon != null) {
      _androidNotificationIcon = androidNotificationIcon;
    }
    
    // Create Android notification channels with badge control
    await _createNotificationChannels(enableBadges);
    
    final AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(_androidNotificationIcon);

    // iOS-specific initialization settings
    DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: enableBadges, // Control badge permissions
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
      await _requestIOSPermissions(enableBadges);
    }

    // Clear any existing badge (iOS)
    await clearBadge();
  }

  /// Clear notification badge (iOS and Android)
  /// 
  /// iOS: Clears the app icon badge number by canceling all notifications
  /// Android: Clears badges by canceling all notifications (badges are tied to active notifications)
  /// Note: Android badge behavior varies by launcher and Android version
  static Future<void> clearBadge() async {
    try {
      // Cancel all notifications - this clears badges on both platforms
      await _notificationsPlugin.cancelAll();
      
      if (Platform.isIOS) {
        print('✅ iOS badges cleared');
      } else if (Platform.isAndroid) {
        print('✅ Android badges cleared (via notification cancellation)');
        print('ℹ️ Note: Android badges are controlled by notification channels');
      }
    } catch (e) {
      print('⚠️ Error clearing badge: $e');
    }
  }
  
  /// Cancel a specific notification by ID
  /// This will also remove any associated badge on that notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      print('✅ Notification $id cancelled');
    } catch (e) {
      print('⚠️ Error cancelling notification: $e');
    }
  }
  
  /// Get pending notifications
  /// Useful to check if there are active notifications that might show badges
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      print('⚠️ Error getting pending notifications: $e');
      return [];
    }
  }
  
  /// Create notification channels with badge control (Android)
  static Future<void> _createNotificationChannels(bool enableBadges) async {
    if (!Platform.isAndroid) return;
    
    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        // High importance channel
        const AndroidNotificationChannel highImportanceChannel =
            AndroidNotificationChannel(
          'high_importance_channel',
          'High Importance Notifications',
          description: 'This channel is used for important notifications',
          importance: Importance.high,
          showBadge: false, // Disable badges by default
        );
        
        // Custom channel
        const AndroidNotificationChannel customChannel =
            AndroidNotificationChannel(
          'custom_channel',
          'Custom Notifications',
          description: 'This channel is used for custom notifications',
          importance: Importance.high,
          showBadge: false, // Disable badges by default
        );
        
        // Create the channels
        await androidPlugin.createNotificationChannel(highImportanceChannel);
        await androidPlugin.createNotificationChannel(customChannel);
        
        print('✅ Android notification channels created with badges disabled');
      }
    } catch (e) {
      print('⚠️ Error creating notification channels: $e');
    }
  }

  static Future<void> _requestIOSPermissions(bool enableBadges) async {
    try {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: enableBadges, // Control badge permissions
            sound: true,
            critical: false,
          );

      print('📱 iOS Notification permissions granted: $result');
    } catch (e) {
      print('⚠️ Error requesting iOS permissions: $e');
    }
  }

  /// Update the Android notification icon
  static void setAndroidNotificationIcon(String iconPath) {
    _androidNotificationIcon = iconPath;
  }

  /// Get the current Android notification icon
  static String getAndroidNotificationIcon() {
    return _androidNotificationIcon;
  }

  static void showNotification(RemoteMessage message, {bool enableBadges = false}) {
    // Android notification details with custom icon
    // Note: Android notification badges are controlled at the system level
    // and cannot be disabled per notification in flutter_local_notifications
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: _androidNotificationIcon,
        );

    // iOS notification details
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true, // Show alert even when app is in foreground
      presentBadge: enableBadges, // Control badge display
      presentSound: true, // Play sound
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
    String? androidIcon,
    bool enableBadges = false, // Control notification badges
  }) async {
    // Note: Android notification badges are controlled at the system level
    // and cannot be disabled per notification in flutter_local_notifications
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'custom_channel',
          'Custom Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: androidIcon ?? _androidNotificationIcon,
        );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: enableBadges, // Control badge display
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

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
