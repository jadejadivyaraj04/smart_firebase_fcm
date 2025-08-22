#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

Future<void> main(List<String> args) async {
  print('🍎 iOS FCM Setup Helper');
  print('========================\n');

  if (args.contains('--help') || args.contains('-h')) {
    _printHelp();
    return;
  }

  if (args.contains('--check')) {
    await _checkIOSSetup();
    return;
  }

  if (args.contains('--instructions')) {
    _printIOSInstructions();
    return;
  }

  if (args.contains('--generate')) {
    await _generateIOSFiles();
    return;
  }

  // Interactive mode
  await _interactiveSetup();
}

void _printHelp() {
  print('Usage: dart run ios_setup_helper [options]');
  print('');
  print('Options:');
  print('  --check        Check current iOS setup');
  print('  --instructions Show iOS setup instructions');
  print('  --generate     Generate iOS configuration files');
  print('  --help, -h     Show this help message');
  print('');
  print('Examples:');
  print('  dart run ios_setup_helper --check');
  print('  dart run ios_setup_helper --instructions');
  print('  dart run ios_setup_helper --generate');
}

void _printIOSInstructions() {
  print('🍎 iOS FCM Configuration Instructions');
  print('=====================================\n');
  
  print('1. 📱 Add GoogleService-Info.plist');
  print('   - Download from Firebase Console');
  print('   - Add to Xcode project in Runner/');
  print('   - Ensure it\'s included in your target\n');
  
  print('2. 📦 Update ios/Podfile');
  print('   - Ensure platform is at least iOS 12:');
  print('     platform :ios, "12.0"');
  print('   - Run: cd ios && pod install\n');
  
  print('3. ⚙️ Xcode Project Settings');
  print('   - Open ios/Runner.xcworkspace');
  print('   - Select Runner target');
  print('   - Go to Signing & Capabilities');
  print('   - Add capability: Push Notifications');
  print('   - Add capability: Background Modes');
  print('   - Check: Remote notifications\n');
  
  print('4. 📄 Update Info.plist');
  print('   - Add these keys:');
  print('     <key>FirebaseAppDelegateProxyEnabled</key>');
  print('     <false/>');
  print('     <key>NSAppTransportSecurity</key>');
  print('     <dict>');
  print('       <key>NSAllowsArbitraryLoads</key>');
  print('       <true/>');
  print('     </dict>\n');
  
  print('5. 🔑 Entitlements');
  print('   - Ensure push notification entitlements are enabled');
  print('   - Check your provisioning profile supports push notifications\n');
  
  print('6. 🧪 Testing');
  print('   - Test on physical device (not simulator)');
  print('   - Ensure device has internet connection');
  print('   - Check notification permissions in Settings app\n');
  
  print('7. 🐛 Troubleshooting');
  print('   - Check Xcode console for errors');
  print('   - Verify Firebase configuration');
  print('   - Test with simple notification first');
}

Future<void> _checkIOSSetup() async {
  print('🔍 Checking iOS Setup...\n');
  
  // Check if running on macOS
  if (!Platform.isMacOS) {
    print('⚠️  This tool should be run on macOS for iOS development');
    return;
  }
  
  // Check for iOS project directory
  final iosDir = Directory('ios');
  if (!iosDir.existsSync()) {
    print('❌ iOS directory not found');
    print('   Make sure you\'re in a Flutter project root');
    return;
  }
  
  print('✅ iOS directory found');
  
  // Check for Podfile
  final podfile = File('ios/Podfile');
  if (podfile.existsSync()) {
    final content = await podfile.readAsString();
    if (content.contains('platform :ios')) {
      print('✅ Podfile found');
      
      // Simple iOS version check
      if (content.contains('platform :ios, \'12.0\'')) {
        print('✅ iOS platform version: 12.0');
        print('✅ iOS version is sufficient (>= 12.0)');
      } else if (content.contains('platform :ios, "12.0"')) {
        print('✅ iOS platform version: 12.0');
        print('✅ iOS version is sufficient (>= 12.0)');
      } else {
        print('⚠️  iOS version should be >= 12.0');
        print('   Update your Podfile: platform :ios, "12.0"');
      }
    }
  } else {
    print('❌ Podfile not found');
  }
  
  // Check for GoogleService-Info.plist
  final googleServiceFile = File('ios/Runner/GoogleService-Info.plist');
  if (googleServiceFile.existsSync()) {
    print('✅ GoogleService-Info.plist found');
  } else {
    print('❌ GoogleService-Info.plist not found');
    print('   Download from Firebase Console and add to ios/Runner/');
  }
  
  // Check for Runner.xcworkspace
  final workspace = Directory('ios/Runner.xcworkspace');
  if (workspace.existsSync()) {
    print('✅ Runner.xcworkspace found');
  } else {
    print('❌ Runner.xcworkspace not found');
    print('   Run: cd ios && pod install');
  }
  
  print('\n📋 Next Steps:');
  print('1. Open ios/Runner.xcworkspace in Xcode');
  print('2. Add Push Notifications capability');
  print('3. Add Background Modes capability');
  print('4. Test on physical device');
}

Future<void> _generateIOSFiles() async {
  print('🔧 Generating iOS Configuration Files...\n');
  
  // Generate iOS-specific configuration
  await _generateIOSConfig();
  await _generatePodfileTemplate();
  await _generateInfoPlistTemplate();
  
  print('✅ iOS configuration files generated');
  print('📱 Review and customize these files as needed');
}

Future<void> _generateIOSConfig() async {
  final content = '''
// ios/Runner/ios_config.dart
// iOS-specific configuration for FCM

class IOSConfig {
  static const String bundleId = 'com.yourcompany.yourapp';
  static const String teamId = 'YOUR_TEAM_ID';
  static const String provisioningProfile = 'YOUR_PROVISIONING_PROFILE';
  
  // Notification categories
  static const List<String> notificationCategories = [
    'message',
    'order',
    'chat',
    'promotion',
  ];
  
  // Background modes
  static const List<String> backgroundModes = [
    'remote-notification',
    'background-processing',
  ];
}
''';
  
  final file = File('ios/Runner/ios_config.dart');
  await file.create(recursive: true);
  await file.writeAsString(content);
  print('📄 Generated: ios/Runner/ios_config.dart');
}

Future<void> _generatePodfileTemplate() async {
  final content = '''# ios/Podfile
# Uncomment this line to define a global platform for your project
platform :ios, '12.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Firebase pods
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    # iOS deployment target
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
''';
  
  final file = File('ios/Podfile.template');
  await file.create(recursive: true);
  await file.writeAsString(content);
  print('📄 Generated: ios/Podfile.template');
}

Future<void> _generateInfoPlistTemplate() async {
  final content = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- Add these keys to your Info.plist -->
	
	<!-- Firebase Configuration -->
	<key>FirebaseAppDelegateProxyEnabled</key>
	<false/>
	
	<!-- Network Security -->
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
	
	<!-- Notification Permissions -->
	<key>NSUserNotificationUsageDescription</key>
	<string>This app uses notifications to keep you updated with important information.</string>
	
	<!-- Background Modes (if needed) -->
	<key>UIBackgroundModes</key>
	<array>
		<string>remote-notification</string>
		<string>background-processing</string>
	</array>
	
	<!-- Add your existing Info.plist content below -->
	
</dict>
</plist>
''';
  
  final file = File('ios/Info.plist.template');
  await file.create(recursive: true);
  await file.writeAsString(content);
  print('📄 Generated: ios/Info.plist.template');
}

Future<void> _interactiveSetup() async {
  print('🤔 Interactive iOS Setup Mode\n');
  
  print('What would you like to do?');
  print('1. Check current setup');
  print('2. View setup instructions');
  print('3. Generate configuration files');
  print('4. Exit');
  
  stdout.write('\nEnter your choice (1-4): ');
  final choice = stdin.readLineSync();
  
  switch (choice) {
    case '1':
      await _checkIOSSetup();
      break;
    case '2':
      _printIOSInstructions();
      break;
    case '3':
      await _generateIOSFiles();
      break;
    case '4':
      print('👋 Goodbye!');
      break;
    default:
      print('❌ Invalid choice. Please try again.');
      await _interactiveSetup();
  }
}
