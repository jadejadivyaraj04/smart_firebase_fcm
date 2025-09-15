#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'package:smart_firebase_fcm/src/generator.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Missing arguments.\nUsage:');
    print(
      '  dart run smart_firebase_fcm_generator notification path=<output_path> [export=<export_file_path>]',
    );
    print('');
    print('Example:');
    print(
      '  dart run smart_firebase_fcm_generator notification path=lib/services/notification_handler.dart export=lib/exports.dart',
    );
    return;
  }

  final command = args.first;
  final rest = args.sublist(1);

  if (command == 'notification') {
    final argsMap = <String, String>{};

    for (var arg in rest) {
      if (arg.contains('=')) {
        final parts = arg.split('=');
        if (parts.length == 2) {
          argsMap[parts.first] = parts.last;
        }
      }
    }

    final outputPath = argsMap['path'];
    final exportPath = argsMap['export'];

    if (outputPath == null) {
      print(
        '❌ Usage: dart run smart_firebase_fcm_generator notification path=lib/services/notification_handler.dart [export=lib/exports.dart]',
      );
      return;
    }

    await generateNotificationHandler(
      outputPath: outputPath,
      exportFilePath: exportPath,
    );
  } else {
    print('❌ Unknown command: $command');
    print('Available commands:');
    print('  notification - Generate notification handler file');
  }
}
