# 🔔 smart_firebase_fcm

A lightweight, plug-and-play modular Firebase FCM (Push Notification) package for Flutter. It offers seamless support for foreground, background, and terminated notifications, deep link redirection, local notifications, and manual feature toggles for Analytics and Crashlytics.

**🍎 NEW: Enhanced iOS Support with Automated Setup Tools and Foreground Notification Handling!**

---

## ✨ Features

- **🚀 One-line Initialization**: Initialize Firebase, FCM, and Local Notifications with a single method call.
- **📱 Platform Support**: flawless support for **Android** and **iOS**.
- **🔔 Notification States**: Handle notifications in all states: **Foreground**, **Background**, and **Terminated**.
- **💬 Local Notifications**: Built-in support for `flutter_local_notifications` to show alerts while the app is open.
- **🍎 Enhanced iOS Support**: 
  - Automated configuration helper.
  - Native-like foreground notification presentation options (Alert, Badge, Sound).
  - Prevention of duplicate notifications.
- **🎨 Custom Android Icons**: complete control over notification icons (drawable/mipmap).
- **🛤️ Deep Linking**: Easy redirection logic for notification taps.
- **🔧 Feature Flags**: Manually toggle Firebase Analytics, Crashlytics, and FCM at runtime.
- **⚡ CLI Generators**: specific tools to generate boilerplate code and configure iOS.

---

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  smart_firebase_fcm: ^1.0.12
```

Or run:

```bash
flutter pub add smart_firebase_fcm
```

---

## ⚙️ Platform Setup

### 📱 Android Setup

1.  **Google Services File**: Download `google-services.json` from the Firebase Console and place it in `android/app/`.
2.  **Gradle Configuration**:
    *   **`android/build.gradle`**:
        ```gradle
        dependencies {
            classpath 'com.google.gms:google-services:4.4.0' // Use latest version
        }
        ```
    *   **`android/app/build.gradle`**:
        ```gradle
        apply plugin: 'com.google.gms.google-services'
        ```
3.  **Manifest Configuration** (`android/app/src/main/AndroidManifest.xml`):
    Add the `INTERNET` permission and the metadata for the notification channel (optional but recommended for custom defaults).

    ```xml
    <manifest ...>
        <uses-permission android:name="android.permission.INTERNET"/>
        <uses-permission android:name="android.permission.VIBRATE"/>

        <application ...>
            <!-- ... -->
            
            <!-- Default Notification Channel -->
            <meta-data
                android:name="com.google.firebase.messaging.default_notification_channel_id"
                android:value="high_importance_channel" />
        </application>
    </manifest>
    ```

### 🍎 iOS Setup

You can use our **automated tool** or set it up manually.

#### Option A: Automated Setup (Recommended)
Run the built-in helper tool to check your configuration and generate necessary files.

```bash
# Check current setup
dart run smart_firebase_fcm:ios_setup_helper --check

# Generate configuration files (Podfile, Info.plist entries)
dart run smart_firebase_fcm:ios_setup_helper --generate
```

#### Option B: Manual Setup
1.  **Google Service File**: Download `GoogleService-Info.plist` from Firebase Console and add it to `ios/Runner/` using Xcode. **Make sure to select "Copy items if needed" and add to targets.**
2.  **Capabilities**: Open Xcode (`ios/Runner.xcworkspace`) -> Select Runner Target -> "Signing & Capabilities":
    *   Add **Push Notifications**.
    *   Add **Background Modes** and check **Remote notifications**.
3.  **Podfile**: Ensure your `ios/Podfile` platform is set to at least 12.0.
    ```ruby
    platform :ios, '12.0'
    ```
4.  **Info.plist**: Disable method swizzling if you want full control (optional, but handled by the package).
    ```xml
    <key>FirebaseAppDelegateProxyEnabled</key>
    <false/>
    ```

---

## 🚀 Usage

### 1. Initialization

Initialize the package in your `main.dart`. You can also configure Feature Flags here.

```dart
import 'package:smart_firebase_fcm/smart_firebase_fcm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Configure Feature Flags (Optional)
  // Control which Firebase features are enabled at startup
  FirebaseFeatureFlags.enableAnalytics = true;
  FirebaseFeatureFlags.enableCrashlytics = true;
  FirebaseFeatureFlags.enableFCM = true;

  // 2. Initialize FCM
  await FCMInitializer.initialize(
    // Handle notification taps
    onTap: (message) {
      print('Notification Tapped: ${message.data}');
      // Navigate to screen based on message.data
    },
    
    // iOS Specifics
    enableIOSConfig: true,
    showLocalNotificationsInForeground: false, // Set true to enforce local notifications on iOS instead of native banners
    
    // Android Specifics
    androidNotificationIcon: '@mipmap/ic_launcher', // Custom icon name
    enableBadges: true,
  );

  runApp(const MyApp());
}
```

### 2. Handling Taps (Navigation)

The `onTap` callback in `initialize` handles taps from **all states** (Background, Terminated, Foreground (if using local notifications)).

```dart
void handleNotificationTap(RemoteMessage message) {
  final String? screen = message.data['screen'];
  final String? id = message.data['id'];

  if (screen == 'chat') {
    navigatorKey.currentState?.pushNamed('/chat', arguments: id);
  } else if (screen == 'profile') {
    navigatorKey.currentState?.pushNamed('/profile');
  }
}
```

### 3. Feature Flags

You can enable or disable Firebase features dynamically. Note that these should usually be set *before* calling `initialize()` or can be useful for debugging.

| Flag | Description | Default |
|------|-------------|---------|
| `FirebaseFeatureFlags.enableFCM` | Controls if FCM setup runs at all. | `true` |
| `FirebaseFeatureFlags.enableAnalytics` | Enables/Disables `firebase_analytics`. | `true` |
| `FirebaseFeatureFlags.enableCrashlytics` | Enables/Disables `firebase_crashlytics`. | `true` |

### 4. Customizing Android Icons

You can use different icons for your Android notifications.

**Requirements**:
*   Icon must be in `android/app/src/main/res/drawable` or `mipmap` folders.
*   Transparent background (white content) strongly recommended for Android 5.0+.

```dart
// Set during init
await FCMInitializer.initialize(
  onTap: (msg) {},
  androidNotificationIcon: '@drawable/ic_stat_notification',
);

// OR Change dynamically later
FCMInitializer.setAndroidNotificationIcon('@mipmap/ic_new_icon');
```

### 5. Using Analytics & Crashlytics

Since this package manages the initialization of Firebase Analytics and Crashlytics, it also exports their classes for your convenience. You don't need to add separate dependencies for them.

#### 📊 Firebase Analytics Example

Make sure `FirebaseFeatureFlags.enableAnalytics = true` (default).

```dart
// Log a custom event
await FirebaseAnalytics.instance.logEvent(
  name: 'purchase_complete',
  parameters: {
    'item_id': 'p_123',
    'value': 29.99,
    'currency': 'USD',
  },
);

// Set user property
await FirebaseAnalytics.instance.setUserProperty(
  name: 'favorite_food', 
  value: 'pizza'
);

// Log screen view
await FirebaseAnalytics.instance.logScreenView(
  screenName: 'HomeScreen',
  screenClass: 'Home',
);
```

#### 💥 Firebase Crashlytics Example

Make sure `FirebaseFeatureFlags.enableCrashlytics = true` (default).

```dart
// Manually record a non-fatal error
try {
  throw Exception('Something went wrong!');
} catch (e, stack) {
  FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Manual error check');
}

// Add custom logs to Crashlytics (shows up in crash reports)
FirebaseCrashlytics.instance.log('User tapped the broken button');

// Set a custom key for context
FirebaseCrashlytics.instance.setCustomKey('app_mode', 'dark');

// Force a test crash (Do not use in production!)
// FirebaseCrashlytics.instance.crash();
```

---

## 🛠️ CLI Tools

The package comes with powerful CLI tools to speed up development.

### 1. Notification Handler Generator

Generate a full `NotificationHandler` service file implementation for your project.

```bash
dart run smart_firebase_fcm:smart_firebase_fcm_generator notification path=lib/core/services/notification_service.dart export=lib/shared/exports.dart
```

*   `path`: Where to create the file.
*   `export` (optional): Adds `export '...';` to the specified file.

### 2. iOS Setup Helper

A utility to check and fix iOS configuration.

```bash
# Interactive Mode
dart run smart_firebase_fcm:ios_setup_helper

# CLI Arguments
dart run smart_firebase_fcm:ios_setup_helper --check
dart run smart_firebase_fcm:ios_setup_helper --instructions
```

---

## ❓ Troubleshooting

### ❌ Notification not showing in Foreground (iOS)
*   **Cause**: `showLocalNotificationsInForeground` is false, and iOS native presentation options might be disabled.
*   **Fix**: The package enables native presentation (Alert/Sound) by default if `enableIOSConfig` is true. Ensure your phone is not in "Do Not Disturb" mode.

### ❌ "APNS device token not set" (iOS)
*   **Cause**: Running on Simulator or Push Capabilities missing.
*   **Fix**:
    1.  **Must test on a Real Device**. Push notifications do not work mainly on Simulators (though Xcode 11.4+ supports it with specific setup files, real device is recommended).
    2.  Verify "Push Notifications" capability in Xcode.
    3.  Verify `GoogleService-Info.plist` is valid.

### ❌ Android Build Failures
*   **Cause**: Missing `google-services.json` or incorrect Gradle setup.
*   **Fix**: Ensure `google-services.json` is in `android/app/` and you have applied the google-services plugin in `android/app/build.gradle`.

### ❌ Custom Icon showing as White Block (Android)
*   **Cause**: The icon has a background color. Android requires transparent backgrounds for notification icons (small icons).
*   **Fix**: Use an asset generator to create a transparent white-only version of your logo and put it in `res/drawable`.

---

## 📄 License

This package is open-source and available under the MIT License.