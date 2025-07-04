// ignore_for_file: avoid_print

import 'dart:io';

/// ---------- NOTIFICATION HANDLER GENERATOR ----------
Future<void> generateNotificationHandler({
  required String outputPath,
  String? exportFilePath, // optional
}) async {
  final file = File(outputPath);
  final project = getProjectName();

  final content = '''
import 'package:$project/exports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

/// 📲 Notification Handler
/// This class handles all notification-related functionality
class NotificationHandler {
  static const String _tag = '🔔 NotificationHandler';

  /// Initialize Firebase Cloud Messaging
  static Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Request permissions
      await requestPermissions();
      
      // Setup message listeners
      setupMessageListeners();

      final token = await getDeviceToken();
      print('\$_tag Device token: \$token');
    } catch (e) {
      print('\$_tag Error initializing FCM: \$e');
    }
  }

  static Future<String?> getDeviceToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      print('\$_tag Error getting device token: \$e');
      return null;
    }
  }

  static void handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final route = data['route'];

    print('\$_tag Notification tapped: \$data');

    if (route != null) {
      print('\$_tag Navigating to \$route');
      _navigateToRoute(route);
    }
  }

  static void _navigateToRoute(String route) {
    try {
      // Using Get.toNamed - make sure GetX is properly imported in exports.dart
      // Get.toNamed(route);
      
      // Alternative: Use Navigator if not using GetX
      // NavigatorKey.currentState?.pushNamed(route);
      
      print('\$_tag Would navigate to: \$route');
    } catch (e) {
      print('\$_tag Error navigating to route \$route: \$e');
    }
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('\$_tag Background message received: \${message.messageId}');
    print('\$_tag Title: \${message.notification?.title}');
    print('\$_tag Body: \${message.notification?.body}');
    print('\$_tag Data: \${message.data}');
  }

  static void handleForegroundMessage(RemoteMessage message) {
    print('\$_tag Foreground message received: \${message.messageId}');
    print('\$_tag Title: \${message.notification?.title}');
    print('\$_tag Body: \${message.notification?.body}');
    print('\$_tag Data: \${message.data}');
    
    // Show local notification if needed
    _showLocalNotification(message);
  }

  static void _showLocalNotification(RemoteMessage message) {
    print('\$_tag Showing local notification: \${message.notification?.title}');
    // Implement local notification display logic here
    // You might want to use flutter_local_notifications package
  }

  static Future<bool> requestPermissions() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('\$_tag Permission granted: \${settings.authorizationStatus}');
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('\$_tag Error requesting permissions: \$e');
      return false;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      print('\$_tag Subscribed to topic: \$topic');
    } catch (e) {
      print('\$_tag Error subscribing to topic \$topic: \$e');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      print('\$_tag Unsubscribed from topic: \$topic');
    } catch (e) {
      print('\$_tag Error unsubscribing from topic \$topic: \$e');
    }
  }

  static void setupMessageListeners() {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
    
    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  /// Check if there's an initial message when app is opened from terminated state
  static Future<void> checkInitialMessage() async {
    try {
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print('\$_tag App opened from terminated state with message: \${initialMessage.messageId}');
        handleNotificationTap(initialMessage);
      }
    } catch (e) {
      print('\$_tag Error checking initial message: \$e');
    }
  }
}
''';

  await file.create(recursive: true);
  await file.writeAsString(content);
  print('✅ NotificationHandler file created at: $outputPath');

  // ✅ Auto-add to export file if provided
  if (exportFilePath != null) {
    final exportFile = File(exportFilePath);
    final exists = exportFile.existsSync();
    final current = exists ? await exportFile.readAsString() : '';

    // Compute relative path (strip "lib/")
    String relativePath = outputPath.startsWith('lib/') ? outputPath.substring(4) : outputPath;
    final exportLine = "export 'package:$project/$relativePath';";

    if (!current.contains(exportLine)) {
      final buffer = StringBuffer(current.trim());
      if (current.isNotEmpty) {
        buffer.writeln();
      }
      buffer.writeln(exportLine);
      await exportFile.create(recursive: true);
      await exportFile.writeAsString('${buffer.toString().trim()}\n');
      print('📦 Export added to $exportFilePath');
    } else {
      print('ℹ️ Export already exists in $exportFilePath');
    }
  }
}

/// ---------- HELPERS ----------
String getProjectName() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) return 'your_project';
  final lines = pubspec.readAsLinesSync();
  for (final line in lines) {
    if (line.trim().startsWith('name:')) {
      return line.split(':').last.trim();
    }
  }
  return 'your_project';
}

extension SnakeCaseExtension on String {
  String toSnakeCase() {
    return replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'), (match) => '_${match.group(0)!.toLowerCase()}').toLowerCase();
  }

  String toPascalCase() {
    return split('_').map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '').join();
  }
}