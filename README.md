````markdown
# 🔔 smart_firebase_fcm

A plug-and-play Firebase FCM (Push Notification) package for Flutter — with full support for foreground/background notifications, deep link redirection, local notifications, and manual toggles for Firebase Analytics and Crashlytics.

---

## ✨ Features

- ✅ One-line Firebase + FCM initialization
- ✅ Foreground + background + terminated notification redirection
- ✅ Foreground local notifications via `flutter_local_notifications`
- ✅ Android notification channel configuration
- ✅ Optional: Firebase Analytics and Crashlytics (enabled/disabled via flags)
- ✅ Clean, modular code — easy to extend

---

## 🚀 Quick Start

### 1. Enable or disable Firebase features

```dart
import 'package:smart_firebase_fcm/smart_firebase_fcm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseFeatureFlags.enableAnalytics = false;
  FirebaseFeatureFlags.enableCrashlytics = true;
  FirebaseFeatureFlags.enableFCM = true;

  await FCMInitializer.initialize(
    onTap: FCMHandler.handleMessage,
  );

  runApp(const MyApp());
}
````

---

### 2. Handle redirection from notification tap

```dart
void handleMessage(RemoteMessage message) {
  final type = message.data['type'];

  switch (type) {
    case 'order':
      // Navigate to order screen
      break;
    case 'chat':
      // Navigate to chat screen
      break;
    default:
      // Fallback or log unknown type
      break;
  }
}
```

---

### 3. Get the FCM device token

```dart
final token = await FCMInitializer.getDeviceToken();
print("FCM Token: $token");
```

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_firebase_fcm: ^1.0.0
```

---

## 🔧 Notification Payload Structure (Recommended)

Make sure your backend sends `data` payload for redirection:

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

* ✅ `Firebase.initializeApp()` + permission handling
* ✅ FCM listeners for:

    * `onMessage` (foreground)
    * `onMessageOpenedApp` (background)
    * `getInitialMessage()` (terminated)
* ✅ Local notifications via `flutter_local_notifications`
* ✅ Android notification channel setup
* ✅ Feature flags to disable/enable:

    * Firebase Analytics
    * Firebase Crashlytics
    * Firebase Messaging

---

## 🧪 Example App

A working example is provided in the [`example/`](example/) folder.

```bash
cd example/
flutter run
```

---

## ❓ FAQ

**Q: Will it work without Firebase Analytics or Crashlytics?**
A: Yes! You can disable them individually using `FirebaseFeatureFlags`.

**Q: Can I customize redirection behavior?**
A: Absolutely. Modify the `FCMHandler.handleMessage()` function with your own navigation logic.

**Q: Does this support iOS and Android?**
A: Yes, both are supported. Make sure you configure notification permissions on iOS correctly.

---

## 📄 License

MIT License © 2025 [Divyaraj Jadeja](https://github.com/jadejadivyaraj04)

