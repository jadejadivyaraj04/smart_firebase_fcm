import 'package:flutter/material.dart';
import 'package:smart_firebase_fcm/smart_firebase_fcm.dart';
import 'dart:io' show Platform;
import 'test_notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Firebase feature flags
  FirebaseFeatureFlags.enableAnalytics = false;
  FirebaseFeatureFlags.enableFCM = true;
  FirebaseFeatureFlags.enableCrashlytics = true;

  // Initialize FCM with iOS configuration enabled
  await FCMInitializer.initialize(
    onTap: FCMHandler.handleMessage,
    enableIOSConfig: true, // Enable iOS-specific configuration
    showLocalNotificationsInForeground: false, // Let Firebase handle foreground notifications automatically
  );

  // Check iOS notification settings (iOS only)
  if (Platform.isIOS) {
    await FCMInitializer.checkIOSNotificationSettings();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Example App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _deviceToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getDeviceToken();
  }

  Future<void> _getDeviceToken() async {
    setState(() => _isLoading = true);
    
    try {
      final token = await FCMInitializer.getDeviceToken();
      setState(() {
        _deviceToken = token;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error getting device token: $e');
    }
  }

  Future<void> _checkIOSSettings() async {
    if (Platform.isIOS) {
      await FCMInitializer.checkIOSNotificationSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This feature is iOS-only')),
      );
    }
  }

  void _showIOSInstructions() {
    FCMInitializer.printIOSConfigurationInstructions();
  }

  void _navigateToTestNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TestNotificationWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Example App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Cloud Messaging Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Device Token Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device FCM Token:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_deviceToken != null)
                      SelectableText(
                        _deviceToken!,
                        style: const TextStyle(fontFamily: 'monospace'),
                      )
                    else
                      const Text('No token available'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _getDeviceToken,
                      child: const Text('Refresh Token'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Test Notifications Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧪 Test Notifications',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _navigateToTestNotifications,
                      child: const Text('Open Test Notifications'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Test local notifications and iOS-specific features',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // iOS-specific features
            if (Platform.isIOS) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🍎 iOS Features',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _checkIOSSettings,
                        child: const Text('Check iOS Notification Settings'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showIOSInstructions,
                        child: const Text('Show iOS Setup Instructions'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Testing Notifications:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Send a test notification from Firebase Console\n'
                      '2. App should show local notification when in foreground\n'
                      '3. Tapping notification should trigger navigation\n'
                      '4. Check console for detailed logs\n'
                      '5. Use Test Notifications page for local testing',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
