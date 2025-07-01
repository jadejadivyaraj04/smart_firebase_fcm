import 'package:flutter/material.dart';
import 'package:smart_firebase_fcm/smart_firebase_fcm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseFeatureFlags.enableAnalytics = false;
  FirebaseFeatureFlags.enableFCM = true;
  FirebaseFeatureFlags.enableCrashlytics = true;

  await FCMInitializer.initialize(
    onTap: FCMHandler.handleMessage,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text("FCM Example App"))),
    );
  }
}
