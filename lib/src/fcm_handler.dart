import 'package:firebase_messaging/firebase_messaging.dart';

class FCMHandler {
  static void handleMessage(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('type')) {
      switch (data['type']) {
        case 'order':
          print("➡ Redirect to Order: ${data['order_id']}");
          break;
        case 'chat':
          print("➡ Redirect to Chat: ${data['chat_id']}");
          break;
        default:
          print("🔁 Unknown redirection type.");
      }
    } else {
      print("ℹ️ No redirection type found in message.");
    }
  }
}
