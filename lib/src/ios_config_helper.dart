import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

/// 🍎 iOS Configuration Helper
/// Provides utilities for iOS-specific FCM setup and configuration
class IOSConfigHelper {
  static const String _tag = '🍎 IOSConfigHelper';

  /// Check if running on iOS
  static bool get isIOS => Platform.isIOS;

  /// Initialize iOS-specific FCM settings
  static Future<void> initializeIOS({bool enableForegroundNotifications = true}) async {
    if (!isIOS) return;

    try {
      print('$_tag Initializing iOS-specific FCM settings...');

      // Request iOS notification permissions
      await _requestIOSPermissions();

      // Configure iOS-specific FCM settings
      await _configureIOSFCM(enableForegroundNotifications);

      // Set up iOS notification categories (optional)
      await _setupNotificationCategories();

      print('$_tag iOS FCM initialization completed successfully');
    } catch (e) {
      print('$_tag Error initializing iOS FCM: $e');
    }
  }

  /// Request iOS notification permissions
  static Future<void> _requestIOSPermissions() async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Request permission for iOS
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: false, // Disable badge permissions
        carPlay: false,
        criticalAlert: false,
        sound: true,
      );

      print('$_tag iOS Notification permission status: ${settings.authorizationStatus}');
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('$_tag ✅ iOS notifications authorized');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('$_tag ⚠️ iOS notifications provisionally authorized');
      } else {
        print('$_tag ❌ iOS notifications not authorized');
      }
    } catch (e) {
      print('$_tag Error requesting iOS permissions: $e');
    }
  }

  /// Configure iOS-specific FCM settings
  static Future<void> _configureIOSFCM(bool enableForegroundNotifications) async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Enable iOS-specific features
      if (enableForegroundNotifications) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,    // Show alert banner
          badge: false,   // Disable badge display
          sound: true,    // Play sound
        );
        print('$_tag iOS foreground notification options configured');
      } else {
        print('$_tag iOS foreground notification options disabled');
      }
    } catch (e) {
      print('$_tag Error configuring iOS FCM: $e');
    }
  }

  /// Set up iOS notification categories for actions
  static Future<void> _setupNotificationCategories() async {
    try {
      // This would typically be done in native iOS code
      // For now, we'll just log that it should be configured
      print('$_tag ℹ️ Configure notification categories in iOS native code if needed');
      print('$_tag Example categories: reply, accept, decline, etc.');
    } catch (e) {
      print('$_tag Error setting up notification categories: $e');
    }
  }

  /// Get iOS-specific device token
  static Future<String?> getIOSDeviceToken() async {
    if (!isIOS) return null;

    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      
      if (token != null) {
        print('$_tag iOS Device Token: $token');
      }
      
      return token;
    } catch (e) {
      print('$_tag Error getting iOS device token: $e');
      return null;
    }
  }

  /// Subscribe to iOS-specific topics
  static Future<void> subscribeToTopic(String topic) async {
    if (!isIOS) return;

    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('$_tag ✅ Subscribed to iOS topic: $topic');
    } catch (e) {
      print('$_tag Error subscribing to iOS topic $topic: $e');
    }
  }

  /// Unsubscribe from iOS-specific topics
  static Future<void> unsubscribeFromTopic(String topic) async {
    if (!isIOS) return;

    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print('$_tag ✅ Unsubscribed from iOS topic: $topic');
    } catch (e) {
      print('$_tag Error unsubscribing from iOS topic $topic: $e');
    }
  }

  /// Check iOS notification settings
  static Future<void> checkIOSNotificationSettings() async {
    if (!isIOS) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.getNotificationSettings();
      
      print('$_tag iOS Notification Settings:');
      print('$_tag - Authorization Status: ${settings.authorizationStatus}');
      print('$_tag - Alert: ${settings.alert}');
      print('$_tag - Badge: ${settings.badge}');
      print('$_tag - Sound: ${settings.sound}');
      print('$_tag - Announcement: ${settings.announcement}');
      print('$_tag - Car Play: ${settings.carPlay}');
      print('$_tag - Critical Alert: ${settings.criticalAlert}');
    } catch (e) {
      print('$_tag Error checking iOS notification settings: $e');
    }
  }

  /// Generate iOS configuration instructions
  static List<String> getIOSConfigurationInstructions() {
    return [
      '🍎 iOS Configuration Instructions:',
      '',
      '1. Add GoogleService-Info.plist to your Xcode project in Runner/',
      '2. In ios/Podfile, ensure platform is at least iOS 12:',
      '   platform :ios, "12.0"',
      '',
      '3. In Xcode, add required capabilities:',
      '   - Enable Push Notifications',
      '   - Enable Background Modes → Check Remote notifications',
      '',
      '4. Add to Info.plist:',
      '   <key>FirebaseAppDelegateProxyEnabled</key>',
      '   <false/>',
      '   <key>NSAppTransportSecurity</key>',
      '   <dict>',
      '     <key>NSAllowsArbitraryLoads</key>',
      '     <true/>',
      '   </dict>',
      '',
      '5. Ensure your app has proper entitlements for push notifications',
      '',
      '6. Test on a physical device (not simulator)',
    ];
  }

  /// Print iOS configuration instructions
  static void printIOSConfigurationInstructions() {
    print('\n${getIOSConfigurationInstructions().join('\n')}\n');
  }
}
