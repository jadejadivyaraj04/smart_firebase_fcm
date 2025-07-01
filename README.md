```markdown
# 🔔 smart_firebase_fcm

A lightweight, plug-and-play Firebase FCM (Push Notification) package for Flutter, offering seamless support for foreground, background, and terminated notifications, deep link redirection, local notifications, and customizable Firebase Analytics and Crashlytics integration.

---

## ✨ Features

- **One-line Setup**: Initialize Firebase and FCM with a single call.
- **Notification Handling**: Supports foreground, background, and terminated state notifications.
- **Local Notifications**: Integrates `flutter_local_notifications` for foreground notifications.
- **Android Notification Channels**: Pre-configured for consistent Android notification delivery.
- **Feature Toggles**: Enable or disable Firebase Analytics, Crashlytics, and FCM via flags.
- **Deep Link Redirection**: Easily handle notification taps with customizable navigation logic.
- **Clean & Modular**: Well-structured, extensible code for easy customization.

---

## 🚀 Quick Start

### 1. Configure Firebase Features

Set up Firebase and FCM in your app with customizable feature flags.

```dart
import 'package:smart_firebase_fcm/smart_firebase_fcm.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Firebase feature flags
  FirebaseFeatureFlags.enableAnalytics = false;
  FirebaseFeatureFlags.enableCrashlytics = true;
  FirebaseFeatureFlags.enableFCM = true;

  // Initialize FCM with a callback for notification taps
  await FCMInitializer.initialize(
    onTap: FCMHandler.handleMessage,
  );

  runApp(const MyApp());
}
```

### 2. Handle Notification Taps

Implement custom navigation logic for notification taps using the `handleMessage` callback.

```dart
void handleMessage(RemoteMessage message) {
  final type = message.data['type'];

  switch (type) {
    case 'order':
      // Navigate to order screen
      navigatorKey.currentState?.pushNamed('/order', arguments: message.data['order_id']);
      break;
    case 'chat':
      // Navigate to chat screen
      navigatorKey.currentState?.pushNamed('/chat');
      break;
    default:
      // Handle unknown notification types
      print('Unknown notification type: $type');
      break;
  }
}
```

### 3. Retrieve FCM Device Token

Get the FCM device token for sending targeted notifications.

```dart
final token = await FCMInitializer.getDeviceToken();
print('FCM Token: $token');
```

---

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  smart_firebase_fcm: ^1.0.1
```

Run the following command to install:

```bash
flutter pub get
```

> **Note**: Ensure Firebase is set up in your Flutter project. Follow the [official Firebase setup guide](https://firebase.google.com/docs/flutter/setup) for iOS and Android.

---

## 🔧 Notification Payload Structure

For proper redirection, your backend should send a `data` payload with the notification. Example:

```json
{
  "notification": {
    "title": "New Order!",
    "body": "You have a new order."
  },
  "data": {
    "type": "order",
    "order_id": "12345"
  }
}
```

---

## 🧱 Under the Hood

- **Firebase Initialization**: Automatically handles `Firebase.initializeApp()` and permission requests.
- **FCM Listeners**:
  - `onMessage`: Handles foreground notifications.
  - `onMessageOpenedApp`: Processes taps on background notifications.
  - `getInitialMessage`: Manages notifications from terminated state.
- **Local Notifications**: Uses `flutter_local_notifications` for foreground notifications on Android and iOS.
- **Android Notification Channels**: Pre-configured for reliable notification delivery.
- **Feature Flags**: Enable or disable Firebase Analytics, Crashlytics, or FCM independently.

---

## 🧪 Example App

A fully functional example is available in the [`example/`](example/) directory.

To run the example:

```bash
cd example/
flutter run
```

---

## ❓ FAQ

**Q: Can I use this package without Firebase Analytics or Crashlytics?**  
A: Yes! Use `FirebaseFeatureFlags` to enable or disable specific features as needed.

**Q: How do I customize notification redirection?**  
A: Implement your navigation logic in the `FCMHandler.handleMessage` function.

**Q: Is this package compatible with iOS and Android?**  
A: Yes, it supports both platforms. Ensure proper notification permissions are configured for iOS.

**Q: What if I encounter issues with FCM setup?**  
A: Verify your Firebase configuration and ensure the correct Google Services file (`google-services.json` for Android, `GoogleService-Info.plist` for iOS) is included in your project.

---

## 📄 License

MIT License © 2025 [Divyaraj Jadeja](https://github.com/jadejadivyaraj04)

---

## 💬 Support

For issues, feature requests, or contributions, visit the [GitHub repository](https://github.com/jadejadivyaraj04/smart_firebase_fcm).
```