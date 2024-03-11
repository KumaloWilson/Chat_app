// ignore_for_file: must_be_immutable
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/app/controller/home/bloc/home_bloc.dart';
import 'package:chat_app/app/utils/constants/notification.dart';
import 'package:chat_app/app/view/callLog/calls.dart';
import 'package:chat_app/app/view/chat/chat.dart';
import 'package:chat_app/app/view/profile/profile.dart';
import 'package:chat_app/app/view/status/status.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> screens = <Widget>[
    const Chats(),
    const CallLog(),
    const Status(),
    const Profile(),
  ];
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
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
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionRecievedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayMethod,
      );
    });
  }

  HomeBloc homeBloc = HomeBloc();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: homeBloc,
      builder: (context, state) {
        return Scaffold(
          body: screens.elementAt(state.tabIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Ionicons.chatbox_ellipses_outline),
                  label: 'chats'),
              BottomNavigationBarItem(
                  icon: Icon(Ionicons.call_outline), label: 'calls'),
              BottomNavigationBarItem(
                  icon: Icon(Ionicons.people_circle_outline),
                  label: 'contacts'),
              BottomNavigationBarItem(
                  icon: Icon(Ionicons.person_outline), label: 'profile')
            ],
            currentIndex: state.tabIndex,
            fixedColor: Colors.black,
            unselectedItemColor: const Color.fromARGB(255, 207, 205, 205),
            onTap: (value) {
              homeBloc.add(
                TabChangeEvent(tabIndex: value),
              );
            },
          ),
        );
      },
    );
  }
}
