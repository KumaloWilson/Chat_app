// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: sort_child_properties_last, avoid_unnecessary_containers, unnecessary_overrides
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/app/utils/components/skelton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/app/controller/chat/bloc/chat_bloc.dart';
import 'package:chat_app/app/view/chatScreen/chatScreen.dart';
import 'package:chat_app/app/view/search/Search.dart';
import 'package:timeago/timeago.dart' as timeago;

class Chats extends StatefulWidget {
  const Chats({Key? key}) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  User? user = FirebaseAuth.instance.currentUser;
  String? lastMessageTime;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is NavigatedSearchPageDoneState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Search(),
            ),
          );
        } else if (state is ChattedUserDeletedState) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(user!.uid)
              .collection("messages")
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.docs.length < 1) {
                return const Center(
                  child: Text('No Chats Available !'),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  var friendId = snapshot.data.docs[index].id;
                  var lastMsg = snapshot.data.docs[index]['last_msg'];
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(friendId)
                        .get(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        var friend = snapshot.data;
                        return ListTile(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Chat'),
                                  content: const Text(
                                      'Are you sure you want to delete this Chat?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        BlocProvider.of<ChatBloc>(context).add(
                                            ChattedFriendDeleteEvent(
                                                currentUid: user!.uid,
                                                friendId: friendId));
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          trailing: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('Users')
                                .doc(user!.uid)
                                .collection('messages')
                                .doc(friendId)
                                .collection('chats')
                                .orderBy('date', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final docs = snapshot.data!.docs;
                                if (docs.isNotEmpty) {
                                  final currentTime = docs[index]['date'];
                                  lastMessageTime =
                                      timeago.format(currentTime.toDate());
                                  return Text(
                                    lastMessageTime!,
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 10),
                                  );
                                } else {
                                  return const SizedBox();
                                }
                              }
                              return const CircularProgressIndicator();
                            },
                          ),
                          leading: Container(
                            width: 50,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CachedNetworkImage(
                                imageUrl: friend['image'],
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
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
                          title: Text(friend['name']),
                          subtitle: Container(
                            child: Text(
                              '$lastMsg',
                              style: const TextStyle(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      friendId: friend['uid'],
                                      friendName: friend['name'],
                                      friendImage: friend['image']),
                                ));
                          },
                        );
                      }
                      return const SkeltonLoadingIndicator();
                    },
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            BlocProvider.of<ChatBloc>(context).add(NavigateToSearchPageEvent());
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
