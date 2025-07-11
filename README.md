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
- **🚀 CLI Generator**: Generate notification handler files with a single command.

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
      navigatorKey.currentState?.pushNamed('/order', arguments: message.data['order_id']);
      break;
    case 'chat':
      navigatorKey.currentState?.pushNamed('/chat');
      break;
    default:
      print('Unknown notification type: $type');
      break;
  }
}
```

### 3. Retrieve FCM Device Token

```dart
final token = await FCMInitializer.getDeviceToken();
print('FCM Token: $token');
```

---

## 🛠️ CLI Generator

Generate a complete notification handler file with a single command:

```bash
dart run smart_firebase_fcm:smart_firebase_fcm_generator notification path=lib/services/notification_handler.dart export=lib/exports.dart
```

### CLI Options:

- `path`: Output path for the notification handler file
- `export`: (Optional) Export file path to automatically add the import

### Example Generated File:

The CLI will create a complete `NotificationHandler` class with:

- Firebase initialization
- Foreground, background, and terminated state handling
- Permission requests
- Topic subscription/unsubscription
- Device token retrieval
- Automatic routing and navigation handling

```dart
// Generated: lib/services/notification_handler.dart
import 'package:your_project/exports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationHandler {
  static Future<void> initialize() async {
    // Complete implementation generated automatically
  }
  
  static Future<String?> getDeviceToken() async {
    // Device token retrieval logic
  }
  
  static void handleNotificationTap(RemoteMessage message) {
    // Notification tap handling with routing
  }
  
  // ... and more methods
}
```

### Usage After Generation:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the generated notification handler
  await NotificationHandler.initialize();
  
  runApp(MyApp());
}
```

---

## 📱 Android Configuration

1. Add the `google-services.json` file to your Android project at:

   ```
   android/app/google-services.json
   ```

2. Update your `android/build.gradle`:

```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

3. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
  implementation 'com.google.firebase:firebase-messaging:23.0.8'
}
```

4. Ensure these permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

5. Add FCM service inside `<application>` tag:

```xml
<service
        android:name="com.google.firebase.messaging.FirebaseMessagingService"
        android:exported="true">
  <intent-filter>
    <action android:name="com.google.firebase.MESSAGING_EVENT"/>
  </intent-filter>
</service>
```

---

## 🍎 iOS Configuration

1. Add the `GoogleService-Info.plist` file to your Xcode project in `Runner/`.

2. In `ios/Podfile`, ensure platform is at least iOS 12:

```ruby
platform :ios, '12.0'
```

3. Add required capabilities:

* Enable **Push Notifications**
* Enable **Background Modes** → Check **Remote notifications**

4. Add notification permission request in `Info.plist`:

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<true/>
</dict>
```

---

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  smart_firebase_fcm: ^1.0.3
```

Install with:

```bash
flutter pub get
```

> **Note**: Ensure Firebase is set up for your Flutter project. Follow the [official Firebase setup guide](https://firebase.google.com/docs/flutter/setup).

---

## 🔧 Notification Payload Structure

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

* **Firebase Initialization**: Handles `Firebase.initializeApp()` and permissions.
* **FCM Listeners**:

    * `onMessage` (Foreground)
    * `onMessageOpenedApp` (Background)
    * `getInitialMessage` (Terminated)
* **Local Notifications**: Uses `flutter_local_notifications`.
* **Notification Channels**: Preconfigured for Android.
* **Feature Flags**: Control Analytics, Crashlytics, and FCM independently.
* **CLI Generator**: Automatically generates notification handler boilerplate code.

---

## 🧪 Example App

To test the full flow:

```bash
cd example/
flutter run
```

---

## ❓ FAQ

**Q: Can I use this package without Firebase Analytics or Crashlytics?**
✅ Yes — just toggle the flags in `FirebaseFeatureFlags`.

**Q: How do I customize notification navigation?**
🛠️ Implement your redirection logic inside `FCMHandler.handleMessage` or use the CLI generator to create a custom handler.

**Q: iOS not receiving notifications?**
📲 Ensure permissions and capabilities are properly set in Xcode.

**Q: How do I use the CLI generator?**
🚀 Run `dart run smart_firebase_fcm:smart_firebase_fcm_generator notification path=lib/services/notification_handler.dart export=lib/exports.dart` in your project directory.

**Q: Can I customize the generated notification handler?**
✅ Yes — the generated code is fully customizable and serves as a starting point for your notification implementation.

---

## 📄 License

MIT License © 2025 [Divyaraj Jadeja](https://github.com/jadejadivyaraj04)

---

## 💬 Support

Please report bugs or contribute at [GitHub Repository](https://github.com/jadejadivyaraj04/smart_firebase_fcm)