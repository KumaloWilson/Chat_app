// ignore_for_file: sort_child_properties_last, use_build_context_synchronously, avoid_print, sized_box_for_whitespace, deprecated_member_use, avoid_unnecessary_containers

import 'dart:io';

import 'package:chat_app/app/view/stories/s.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class Stories extends StatefulWidget {
  const Stories({Key? key}) : super(key: key);

  @override
  State<Stories> createState() => _StoriesState();
}

class _StoriesState extends State<Stories> {
  late File image;

  void selectImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
      previewStoryImage(context, pickedImage.path);
    } else {
      print('No image selected.');
    }
  }

  Future<String?> uploadImageToStorage(File imageFile) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child("stories/${Timestamp.now()}");
      final TaskSnapshot result = await storageRef.putFile(imageFile);
      return await result.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> addStoryToFirestore(String imageUrl) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('stories')
            .doc(user.uid)
            .set({
          'image': imageUrl,
          'username': user.displayName,
          'userimage': user.photoURL,
          'time': Timestamp.now(),
          'useruid': user.uid,
        });
      } else {
        print('User not authenticated.');
      }
    } catch (e) {
      print('Error adding story to Firestore: $e');
    }
  }

  Future<void> uploadImageAndAddStory(
      BuildContext context, File imageFile) async {
    try {
      final imageUrl = await uploadImageToStorage(imageFile);
      if (imageUrl != null) {
        await addStoryToFirestore(imageUrl);
        Navigator.pop(context);
      } else {
        // Handle case where image upload failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to upload image. Please try again later.')),
        );
      }
    } catch (e) {
      print('Error uploading image and adding story: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: GestureDetector(
                  onTap: selectImage,
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                      ),
                      Positioned(
                        top: 55,
                        left: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.plus,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('stories')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot documentSnapshot) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      child: StoriesView(
                                          documentSnapshot: documentSnapshot),
                                      type: PageTransitionType.leftToRight));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Image.network(
                                    documentSnapshot['userimage']),
                                height: 40,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future previewStoryImage(BuildContext context, String imagePath) {
    return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.amber,
          ),
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.file(File(imagePath)),
              ),
              Positioned(
                top: 700.0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        heroTag: 'Reselect image',
                        child: const Icon(
                          FontAwesomeIcons.backspace,
                          color: Colors.green,
                        ),
                        backgroundColor: Colors.red,
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          uploadImageAndAddStory(context, image);
                        },
                        heroTag: 'Confirm image',
                        child: const Icon(
                          FontAwesomeIcons.check,
                          color: Colors.blue,
                        ),
                        backgroundColor: Colors.red,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
