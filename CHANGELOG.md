# Changelog

All notable changes to this project will be documented in this file.

## [1.0.11] - 2025-11-26

- 🗑️ **Cleanup**: Removed unnecessary documentation files (`ANDROID_BADGE_GUIDE.md`, `IOS_IMPROVEMENTS_SUMMARY.md`) to keep the package lightweight.
- 📝 **Documentation**: Consolidated important information into `README.md`.
- ⬆️ **Dependencies**: Updated Firebase and local notification packages to latest versions.

## [1.0.10] - 2025-11-20

- 🍎 **iOS Improvements**: Enhanced iOS foreground notification handling.
- 🛠️ **Tools**: Added `ios_setup_helper` for automated iOS configuration.
- 🐛 **Bug Fixes**: Fixed issues with iOS permission requests and token retrieval.

## [1.0.9] - 2025-09-29

### 🎨 Custom Notification Icon Support

- ✅ **Custom Android Notification Icons**: Added support for custom notification icons using drawable/mipmap resources
- ✅ **Dynamic Icon Updates**: Change notification icons at runtime without reinitializing
- ✅ **Multiple Icon Sources**: Support for both `@drawable/` and `@mipmap/` resources
- ✅ **Backward Compatibility**: Existing code continues to work with default `@mipmap/ic_launcher`
- ✅ **Enhanced API**: Added `androidNotificationIcon` parameter to `FCMInitializer.initialize()`
- ✅ **Utility Methods**: Added `setAndroidNotificationIcon()` and `getAndroidNotificationIcon()` methods
- ✅ **Per-Notification Icons**: Support for custom icons in `showCustomNotification()`
- ✅ **Updated Documentation**: Comprehensive guide for Android icon requirements and usage
- ✅ **Example App Enhancement**: Interactive notification icon customization demo

### 🔧 API Changes

#### New Parameters:
- `androidNotificationIcon` in `FCMInitializer.initialize()`
- `androidIcon` in `LocalNotificationService.showCustomNotification()`

#### New Methods:
- `FCMInitializer.setAndroidNotificationIcon(String iconPath)`
- `FCMInitializer.getAndroidNotificationIcon()`
- `LocalNotificationService.setAndroidNotificationIcon(String iconPath)`
- `LocalNotificationService.getAndroidNotificationIcon()`

### 📱 Usage Examples:

```dart
// Initialize with custom icon
await FCMInitializer.initialize(
  onTap: handleNotificationTap,
  androidNotificationIcon: '@drawable/ic_notification',
);

// Change icon dynamically
FCMInitializer.setAndroidNotificationIcon('@mipmap/ic_custom');

// Custom notification with specific icon
await LocalNotificationService.showCustomNotification(
  id: 1,
  title: 'Test',
  body: 'Test notification',
  androidIcon: '@drawable/ic_message',
);
```

## [1.0.3] - 2025-07-01

### 🎉 Initial Release

- ✅ Firebase FCM integration
- ✅ Foreground, background, and terminated state redirection
- ✅ Local notification support using flutter_local_notifications
- ✅ Android channel setup
- ✅ Toggle flags for Firebase Analytics and Crashlytics
- ✅ Single-line initialization with optional message handler
