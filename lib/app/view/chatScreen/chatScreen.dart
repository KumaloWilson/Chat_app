// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app/utils/components/message_textfield.dart';
import 'package:chat_app/app/utils/components/single_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        actions: [
          IconButton(onPressed: () {
            
          }, icon: const Icon(Icons.more_vert)),
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
                        bool isMe =
                            snapshot.data.docs[index]['senderId'] == user!.uid;
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
                              currentTime: snapshot.data.docs[index]['date'],
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
  }
}
