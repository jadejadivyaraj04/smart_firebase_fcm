import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;

class FCMHandler {
  static void handleMessage(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'order':
          developer.log("➡ Redirect to Order: ${data['order_id']}");
          break;
        case 'chat':
          developer.log("➡ Redirect to Chat: ${data['chat_id']}");
          break;
        default:
          developer.log("🔁 Unknown redirection type.");
      }
    } else {
      developer.log("ℹ️ No redirection type found in message.");
    }
  }
}
