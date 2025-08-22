# 🔔 smart_firebase_fcm

A lightweight, plug-and-play Firebase FCM (Push Notification) package for Flutter, offering seamless support for foreground, background, and terminated notifications, deep link redirection, local notifications, and customizable Firebase Analytics and Crashlytics integration.

**🍎 NEW: Enhanced iOS Support with Automated Setup Tools!**

---

## ✨ Features

- **One-line Setup**: Initialize Firebase and FCM with a single call.
- **Notification Handling**: Supports foreground, background, and terminated state notifications.
- **Local Notifications**: Integrates `flutter_local_notifications` for foreground notifications.
- **Android Notification Channels**: Pre-configured for consistent Android notification delivery.
- **🍎 Enhanced iOS Support**: Automated iOS configuration with foreground notification display.
- **Feature Toggles**: Enable or disable Firebase Analytics, Crashlytics, and FCM via flags.
- **Deep Link Redirection**: Easily handle notification taps with customizable navigation logic.
- **Clean & Modular**: Well-structured, extensible code for easy customization.
- **🚀 CLI Generator**: Generate notification handler files with a single command.
- **🍎 iOS Setup Helper**: Automated iOS configuration and setup assistance.

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

  // Initialize FCM with iOS configuration enabled
  await FCMInitializer.initialize(
    onTap: FCMHandler.handleMessage,
    enableIOSConfig: true, // Enable iOS-specific configuration
    showLocalNotificationsInForeground: false, // Let Firebase handle foreground notifications automatically
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

// iOS-specific token retrieval
if (Platform.isIOS) {
  final iosToken = await FCMInitializer.getIOSDeviceToken();
  print('iOS Token: $iosToken');
}
```

---

## 🍎 iOS Configuration

### Automated iOS Setup

Use the iOS setup helper to automate iOS configuration:

```bash
# Check current iOS setup
dart run ios_setup_helper --check

# View iOS setup instructions
dart run ios_setup_helper --instructions

# Generate iOS configuration files
dart run ios_setup_helper --generate

# Interactive setup mode
dart run ios_setup_helper
```

### iOS-specific Features

```dart
// Check iOS notification settings
await FCMInitializer.checkIOSNotificationSettings();

// Print iOS configuration instructions
FCMInitializer.printIOSConfigurationInstructions();

// Get iOS-specific device token
final iosToken = await FCMInitializer.getIOSDeviceToken();
```

### iOS Foreground Notifications

The package now automatically handles iOS foreground notification display:

- ✅ Shows notification banners when app is in foreground
- ✅ Plays notification sounds
- ✅ Handles notification taps properly
- ✅ **Prevents duplicate notifications** by controlling Firebase vs local notification display

#### Duplicate Notification Prevention

To avoid duplicate notifications on iOS, the package provides a `showLocalNotificationsInForeground` flag:

```dart
await FCMInitializer.initialize(
  onTap: handleNotificationTap,
  enableIOSConfig: true,
  showLocalNotificationsInForeground: false, // Let Firebase handle automatically
);
```

- **`false` (default)**: Firebase shows notifications automatically, no local notifications
- **`true`**: Firebase automatic display disabled, local notifications shown instead

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

### Quick Setup with iOS Helper

```bash
# Run the iOS setup helper
dart run ios_setup_helper

# This will guide you through the entire iOS setup process
```

### Manual Setup

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