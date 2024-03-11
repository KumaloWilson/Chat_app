import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification notification) async {
    print('It works');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayMethod(
      ReceivedNotification notification) async {
    print('It works');
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionRecievedMethod(
      ReceivedAction receivedAction) async {
    print('It works');
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'ACCEPT') {
      print("call accepted");
    } else if (receivedAction.buttonKeyPressed == 'REJECT') {
      print("call rejected");
    } else {
      print("Clicked on notification");
    }
  }
}
