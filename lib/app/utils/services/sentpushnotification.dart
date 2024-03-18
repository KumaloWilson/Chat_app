import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/app/utils/agora/callpage.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> sendPushNotification(String token, String name) async {
  String channelName = generateRandomString(8);
  String title = "Incoming Call1a2b3c4d5e$channelName";
  try {
    http.Response response = await http
        .post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'key=AAAA5XyTTng:APA91bHpzK2s_wbp6vhJQQ4z7pPmkiFxRViQarMoB7Ujjai_bSfMZ1eZ1v6Ad9smPPoeHylP3bFG7gwwlDhznN9hW47Uiz4e7hxrm03EQcTz2XtA4ZrhMc-jr4rYvtnFRp6n8ZImSGz2',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': name,
            'title': title,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token,
        },
      ),
    )
        .whenComplete(() async {
      await [Permission.camera, Permission.microphone].request().then((value) {
        Get.offAll(() => Call(channelName: channelName));
      });
    });

    response;
  } catch (e) {
    print("Error: ${e.toString()}");
  }
}

String generateRandomString(int len) {
  var r = Random();
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
}
