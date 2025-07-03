import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_service.dart';

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
  }) async {
    _onTapCallback = onTap;

    // 🔧 Firebase Core Initialization
    await Firebase.initializeApp(options: firebaseOptions);

    // ✅ Ask Notification Permissions
    await FirebaseMessaging.instance.requestPermission();

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

    // 📤 Show custom local notifications only when in foreground
    FirebaseMessaging.onMessage.listen((message) {
      LocalNotificationService.showNotification(message);
    });

    // 🕹️ Notification tapped when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _onTapCallback?.call(message);
    });

    // 🚀 App launched from terminated state by tapping a notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onTapCallback?.call(initialMessage);
    }

    // 📥 Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  /// 📱 Get current device FCM token
  static Future<String?> getDeviceToken() {
    return FirebaseMessaging.instance.getToken();
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
