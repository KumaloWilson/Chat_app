// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app/controller/chat/bloc/chat_bloc.dart';
import 'package:chat_app/app/utils/agora/callpage.dart';
import 'package:chat_app/app/utils/components/message_textfield.dart';
import 'package:chat_app/app/utils/components/single_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  final String friendId;
  final String friendName;
  final String friendImage;

  const ChatScreen({
    Key? key,
    required this.friendId,
    required this.friendName,
    required this.friendImage,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is VideoCallWorkingState) {
          sendPushNotification(state.token, state.name);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: const Icon(Icons.video_call),
                onPressed: () {
                  BlocProvider.of<ChatBloc>(context).add(
                      VideoCallButtonClickedEvent(friendId: widget.friendId));
                },
              ),
            ],
            title: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: CachedNetworkImage(
                    imageUrl: widget.friendImage,
                    placeholder: (conteext, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                    ),
                    height: 50,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.friendName,
                  style: const TextStyle(fontSize: 20),
                )
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user!.uid)
                        .collection('messages')
                        .doc(widget.friendId)
                        .collection('chats')
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.docs.length < 1) {
                          return const Center(
                            child: Text('say Hii'),
                          );
                        }
                        return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          reverse: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            bool isMe = snapshot.data.docs[index]['senderId'] ==
                                user!.uid;
                            final data = snapshot.data.docs[index];
                            return Dismissible(
                              key: UniqueKey(),
                              onDismissed: (direction) async {
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(user?.uid)
                                    .collection('messages')
                                    .doc(widget.friendId)
                                    .collection('chats')
                                    .doc(data.id)
                                    .delete();
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(widget.friendId)
                                    .collection('messages')
                                    .doc(user?.uid)
                                    .collection('chats')
                                    .doc(data.id)
                                    .delete();
                              },
                              child: SingleMessage(
                                  currentTime: snapshot.data.docs[index]
                                      ['date'],
                                  type: snapshot.data.docs[index]['type'],
                                  message: snapshot.data.docs[index]['message'],
                                  isMe: isMe),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
              MessageTextField(user!.uid, widget.friendId)
            ],
          ),
        );
      },
    );
  }

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
        await [Permission.camera, Permission.microphone]
            .request()
            .then((value) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Call(channelName: channelName),
              ));
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
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }
}
