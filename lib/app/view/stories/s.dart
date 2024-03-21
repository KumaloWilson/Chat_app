// ignore_for_file: prefer_const_constructors, deprecated_member_use, sized_box_for_whitespace, avoid_unnecessary_containers, avoid_print
import 'package:chat_app/app/view/home/home.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:page_transition/page_transition.dart';

class StoriesView extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;
  const StoriesView({super.key, required this.documentSnapshot});

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  User? user = FirebaseAuth.instance.currentUser;

  // @override
  // void initState() {
  //   super.initState();
  //   Timer(const Duration(seconds: 15), () {
  //     Navigator.pushReplacement(
  //       context,
  //       PageTransition(child: Home(), type: PageTransitionType.bottomToTop),
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx > 0) {
            print(details);
            Navigator.pushReplacement(
              context,
              PageTransition(
                  child: Home(), type: PageTransitionType.bottomToTop),
            );
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Image.network(
                        widget.documentSnapshot['image'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 30,
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            widget.documentSnapshot['userimage'],
                          ),
                          radius: 25,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.52,
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.9),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.documentSnapshot['username'],
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const Text(
                            '2 hours ago',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    user!.uid == widget.documentSnapshot['useruid']
                        ? GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 30,
                              width: 50,
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.solidEye,
                                    color: Colors.yellow,
                                    size: 16,
                                  ),
                                  Text(
                                    '0',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            width: 0.0,
                            height: 0.0,
                          ),
                    const SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularCountDownTimer(
                          isTimerTextShown: false,
                          width: 20,
                          height: 20,
                          duration: 15,
                          fillColor: Colors.blue,
                          ringColor: Colors.lime),
                    ),
                    IconButton(
                        onPressed: () {
                          showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(300, 70, 0, 0),
                              items: [
                                PopupMenuItem(
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Icon(FontAwesomeIcons.deleteLeft),
                                  ),
                                ),
                                PopupMenuItem(
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Icon(FontAwesomeIcons.archive),
                                  ),
                                )
                              ]);
                        },
                        icon: const Icon(
                          EvaIcons.moreVertical,
                          color: Colors.black,
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
