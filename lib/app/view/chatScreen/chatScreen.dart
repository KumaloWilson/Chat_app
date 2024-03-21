// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app/controller/chat/bloc/chat_bloc.dart';
import 'package:chat_app/app/utils/components/message_textfield.dart';
import 'package:chat_app/app/utils/components/single_message.dart';
import 'package:chat_app/app/utils/services/sentpushnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is VideoCallWorkingState) {
          sendPushNotification(state.token, state.name);
        } else if (state is AudioCallWorkingState) {}
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 24,
                )),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.grey[100],
            actions: [
              IconButton(
                icon: const Icon(Ionicons.videocam_outline),
                onPressed: () {
                  BlocProvider.of<ChatBloc>(context).add(
                      VideoCallButtonClickedEvent(friendId: widget.friendId));
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Conversation'),
                          content: const Text(
                              'Are you sure you want to delete this conversation?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                deleteConversation();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Ionicons.trash_bin_outline),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              )
            ],
            title: Row(
              children: [
                Container(
                  width: 50,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: widget.friendImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: imageProvider,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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

  void deleteConversation() async {
    try {
      // Get a reference to the collection
      CollectionReference<Map<String, dynamic>> collectionReference =
          FirebaseFirestore.instance
              .collection('Users')
              .doc(user!.uid)
              .collection('messages')
              .doc(widget.friendId)
              .collection('chats');

      // Fetch the documents within the collection
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await collectionReference.get();

      // Delete each document one by one
      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in querySnapshot.docs) {
        await doc.reference.delete();
      }
      print('Documents deleted successfully.');
    } catch (e) {
      print('Error deleting documents: $e');
    }
  }
}
