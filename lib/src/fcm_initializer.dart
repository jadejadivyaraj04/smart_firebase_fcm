import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_service.dart';
import 'ios_config_helper.dart';
import 'dart:io';

/// 🔁 Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // ❌ Don't show local notifications here for background/terminated
  // If message has a 'notification' block, Firebase automatically shows it
  print('🔕 Background message received: ${message.messageId}');
}

/// 📦 FCM Initialization Utility
class FCMInitializer {
  static void Function(RemoteMessage message)? _onTapCallback;

  /// 🚀 Initialize Firebase Messaging and Notification Handling
  static Future<void> initialize({
    required void Function(RemoteMessage message) onTap,
    FirebaseOptions? firebaseOptions,
    bool enableIOSConfig = true,
    bool showLocalNotificationsInForeground =
        false, // Control local notification display
  }) async {
    _onTapCallback = onTap;

    // 🔧 Firebase Core Initialization
    await Firebase.initializeApp(options: firebaseOptions);

    // ✅ Ask Notification Permissions
    await FirebaseMessaging.instance.requestPermission();

    // 🍎 Initialize iOS-specific configuration
    if (enableIOSConfig && Platform.isIOS) {
      // Disable Firebase automatic foreground notifications to avoid duplicates
      // We'll handle them manually if showLocalNotificationsInForeground is true
      await IOSConfigHelper.initializeIOS(
        enableForegroundNotifications: !showLocalNotificationsInForeground,
      );
    }

    // 🔔 Setup Local Notification Service
    await LocalNotificationService.initialize(
      onTap: (payload) {
        try {
          final message = _parseRemoteMessageFromPayload(payload ?? '');
          if (message != null) {
            _onTapCallback?.call(message);
          }
        } catch (e) {
          print('⚠️ Failed to parse tapped payload: $payload\nError: $e');
        }
      },
    );

    // 📤 Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print('📱 Foreground message received: ${message.messageId}');
      print('📱 Title: ${message.notification?.title}');
      print('📱 Body: ${message.notification?.body}');

      // Only show local notification if explicitly requested
      // Firebase will automatically show notifications on iOS when configured
      if (showLocalNotificationsInForeground) {
        LocalNotificationService.showNotification(message);
      }
    });

    // 🕹️ Notification tapped when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('🕹️ Background notification tapped: ${message.messageId}');
      _onTapCallback?.call(message);
    });

    // 🚀 App launched from terminated state by tapping a notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print(
        '🚀 App launched from terminated state with message: ${initialMessage.messageId}',
      );
      _onTapCallback?.call(initialMessage);
    }

    // 📥 Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 🍎 Additional iOS-specific setup
    if (enableIOSConfig && Platform.isIOS) {
      await _setupIOSForegroundNotifications();
    }
  }

  /// 🍎 Setup iOS foreground notification display
  static Future<void> _setupIOSForegroundNotifications() async {
    if (!Platform.isIOS) return;

    try {
      // Enable iOS-specific features
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true, // Show alert banner
            badge: false, // Disable badge display
            sound: true, // Play sound
          );

      print('🍎 iOS foreground notification presentation enabled');
    } catch (e) {
      print('⚠️ Error setting up iOS foreground notifications: $e');
    }
  }

  /// 📱 Get current device FCM token
  static Future<String?> getDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        print('📱 Device FCM Token: $token');

        // Log iOS-specific token info
        if (Platform.isIOS) {
          print('🍎 iOS Device Token retrieved successfully');
        }
      }

      return token;
    } catch (e) {
      print('⚠️ Error getting device token: $e');
      return null;
    }
  }

  /// 🍎 Get iOS-specific device token with additional logging
  static Future<String?> getIOSDeviceToken() async {
    if (!Platform.isIOS) {
      print('⚠️ This method is iOS-specific');
      return null;
    }

    return await IOSConfigHelper.getIOSDeviceToken();
  }

  /// 🍎 Check iOS notification settings
  static Future<void> checkIOSNotificationSettings() async {
    if (!Platform.isIOS) {
      print('⚠️ This method is iOS-specific');
      return;
    }

    await IOSConfigHelper.checkIOSNotificationSettings();
  }

  /// 🍎 Print iOS configuration instructions
  static void printIOSConfigurationInstructions() {
    IOSConfigHelper.printIOSConfigurationInstructions();
  }

  /// 🔄 Utility to parse RemoteMessage from payload string (if needed)
  static RemoteMessage? _parseRemoteMessageFromPayload(String payload) {
    try {
      // You can design a structured payload and decode it here
      final Map<String, dynamic> data = {'customPayload': payload};
      return RemoteMessage(data: data);
    } catch (_) {
      return null;
    }
  }
}
