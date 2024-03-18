// ignore_for_file: unnecessary_string_interpolations, prefer_typing_uninitialized_variables

import 'package:chat_app/app/utils/components/showimage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class SingleMessage extends StatefulWidget {
  final type;
  final currentTime;
  final String message;
  final bool isMe;
  SingleMessage(
      {required this.message,
      required this.isMe,
      required this.currentTime,
      required this.type});

  @override
  State<SingleMessage> createState() => _SingleMessageState();
}

class _SingleMessageState extends State<SingleMessage> {
  String? lastMessageTime;
  @override
  Widget build(BuildContext context) {
    lastMessageTime = timeago.format(widget.currentTime.toDate());
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.type == 'text'
                    ? Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(
                            top: 10, bottom: 2, left: 10, right: 10),
                        constraints: const BoxConstraints(maxWidth: 200),
                        decoration: BoxDecoration(
                            color: widget.isMe
                                ? const Color(0xFF20A090)
                                : const Color.fromARGB(255, 234, 242, 248),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(15),
                            )),
                        child: Text(
                          widget.message,
                          style: TextStyle(
                              fontSize: 17,
                              color: widget.isMe ? Colors.white : Colors.black),
                        ))
                    : Container(
                        margin: const EdgeInsets.only(right: 20, top: 10),
                        child: widget.type == "link"
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.all(16),
                                constraints:
                                    const BoxConstraints(maxWidth: 200),
                                decoration: BoxDecoration(
                                    color: widget.isMe
                                        ? Colors.black
                                        : Colors.grey,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(12))),
                                child: GestureDetector(
                                  onTap: () async {
                                    await launchUrl(
                                        Uri.parse('${widget.message}'));
                                  },
                                  child: Text(
                                    widget.message,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : widget.type == "sticker"
                                ? Container(
                                    height: 100,
                                    width: 100,
                                    child: Image.network(widget.message),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ShowImage(
                                                            imageUrl:
                                                                widget.message),
                                                  ));
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.42,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.30,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(18),
                                                    topLeft:
                                                        Radius.circular(18),
                                                    bottomLeft:
                                                        Radius.circular(18),
                                                  ),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                          widget.message),
                                                      fit: BoxFit.fill)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(right: 17),
                  child: Text(
                    lastMessageTime!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
