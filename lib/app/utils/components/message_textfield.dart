// ignore_for_file: sort_child_properties_last

import 'package:chat_app/app/controller/chat/bloc/chat_bloc.dart';
import 'package:chat_app/app/utils/components/bottomsheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

class MessageTextField extends StatefulWidget {
  final String currentId;
  final String friendId;

  MessageTextField(this.currentId, this.friendId);

  @override
  _MessageTextFieldState createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is BottomSheetSuccessState) {
          showModalBottomSheet(
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) =>
                bottomSheet(context, widget.currentId, widget.friendId),
          );
        }
      },
      builder: (context, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsetsDirectional.all(8),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                controller: controller,
                decoration: InputDecoration(
                    labelText: "Type your Message",
                    fillColor: Colors.grey[100],
                    filled: true,
                    prefixIcon: IconButton(
                        onPressed: () {
                          showSticker(context);
                        },
                        icon: const Icon(EneftyIcons.emoji_happy_outline)),
                    suffixIcon: IconButton(
                        onPressed: () {
                          BlocProvider.of<ChatBloc>(context)
                              .add(BottomSheetEvent());
                        },
                        icon: const Icon(Ionicons.attach)),
                    border: OutlineInputBorder(
                        borderSide: const BorderSide(width: 0),
                        gapPadding: 10,
                        borderRadius: BorderRadius.circular(25))),
              )),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  String message = controller.text;
                  controller.clear();
                  if (message.isNotEmpty) {
                    BlocProvider.of<ChatBloc>(context).add(ChatShareEvent(
                        currentId: widget.currentId,
                        friendId: widget.friendId,
                        message: message));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  showSticker(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.ease,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 105.0,
                ),
                child: Divider(
                  thickness: 4,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: Colors.blue),
                        ),
                        height: 30,
                        width: 30,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(EneftyIcons.add_circle_bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('stickers')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return GridView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot documentSnapshot) {
                          return GestureDetector(
                            onTap: () async {
                              BlocProvider.of<ChatBloc>(context).add(
                                  StickerSentEvent(
                                      message: documentSnapshot['sticker'],
                                      currentId: widget.currentId,
                                      friendId: widget.friendId));
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              child: Image.network(documentSnapshot['sticker']),
                            ),
                          );
                        }).toList(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
