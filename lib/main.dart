// ignore_for_file: avoid_print

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/app/controller/auth/bloc/auth_bloc.dart';
import 'package:chat_app/app/controller/chat/bloc/chat_bloc.dart';
import 'package:chat_app/app/controller/home/bloc/home_bloc.dart';
import 'package:chat_app/app/controller/profile/bloc/profile_bloc.dart';
import 'package:chat_app/app/controller/search/bloc/search_bloc.dart';
import 'package:chat_app/app/utils/agora/callpage.dart';
import 'package:chat_app/app/utils/constants/app_theme.dart';
import 'package:chat_app/app/utils/constants/notification.dart';
import 'package:chat_app/app/view/home/home.dart';
import 'package:chat_app/app/view/onboard/onboard.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> backgroundHandler(
  RemoteMessage message,
) async {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  String? body = message.notification!.body;
  String? title = message.notification!.title!.split('1a2b3c4d5e').first;
  String? channelName = message.notification!.title!.split('1a2b3c4d5e').last;
  if (notification != null && android != null) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 123,
          channelKey: "call_channel",
          color: Colors.white,
          title: title,
          body: body,
          category: NotificationCategory.Call,
          wakeUpScreen: true,
          autoDismissible: false,
          backgroundColor: Colors.orange,
        ),
        actionButtons: [
          NotificationActionButton(
            key: "ACCEPT",
            label: 'Accept Call',
            color: Colors.green,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: "REJECT",
            label: 'Reject Call',
            color: Colors.red,
            autoDismissible: true,
          ),
        ]);
  }

  @pragma("vm:entry-point")
  Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'ACCEPT') {
      await [Permission.camera, Permission.microphone].request().then((value) {
        Get.offAll(() => Call(channelName: channelName));
      });
    } else if (receivedAction.buttonKeyPressed == 'REJECT') {
      Get.snackbar("Rejected", "Call from $body is rejected",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent);
    } else {
      print("Clicked on notification");
    }
  }

  AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
    onNotificationCreatedMethod:
        NotificationController.onNotificationCreatedMethod,
    onDismissActionReceivedMethod:
        NotificationController.onDismissActionRecievedMethod,
    onNotificationDisplayedMethod:
        NotificationController.onNotificationDisplayMethod,
  );
}

void main() async {
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: "call_channel",
      channelName: "call Channel",
      channelDescription: "channel of calling",
      defaultColor: Colors.redAccent,
      ledColor: Colors.white,
      importance: NotificationImportance.Max,
      channelShowBadge: true,
      locked: true,
      defaultRingtoneType: DefaultRingtoneType.Ringtone,
    )
  ]);
  bool permissons = await AwesomeNotifications().isNotificationAllowed();
  if (!permissons) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => SearchBloc(),
        ),
        BlocProvider(
          create: (context) => HomeBloc(),
        ),
        BlocProvider(
          create: (context) => ChatBloc(),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Home();
          } else {
            return OnBoardScreen();
          }
        },
      ),
      theme: lightMode,
    );
  }
}
