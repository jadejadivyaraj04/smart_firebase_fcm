import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'feature_flags.dart';
import 'local_notification_service.dart';
import 'fcm_handler.dart';

class FCMInitializer {
  static Future<void> initialize({
    required void Function(RemoteMessage message) onTap,
  }) async {
    await Firebase.initializeApp();

    if (FirebaseFeatureFlags.enableAnalytics) {
      FirebaseAnalytics.instance.logAppOpen();
    }

    if (FirebaseFeatureFlags.enableCrashlytics && !kDebugMode) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }

    if (FirebaseFeatureFlags.enableFCM) {
      await _initFCM(onTap);
    }
  }

  static Future<void> _initFCM(void Function(RemoteMessage) onTap) async {
    await FirebaseMessaging.instance.requestPermission();
    await LocalNotificationService.initialize();

    FirebaseMessaging.onMessage.listen((message) {
      LocalNotificationService.showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(onTap);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      onTap(initialMessage);
    }
  }

  static Future<String?> getDeviceToken() {
    return FirebaseMessaging.instance.getToken();
  }
}
