// ignore_for_file: public_member_api_docs, sort_constructors_first, unnecessary_string_interpolations, unnecessary_brace_in_string_interps
// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:chat_app/app/controller/profile/bloc/profile_bloc.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

class ProfileUpdate extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String id;
  const ProfileUpdate({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.id,
  }) : super(key: key);

  @override
  State<ProfileUpdate> createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  TextEditingController nameEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    nameEditingController.text = widget.name;
  }

  String? userName;
  File? pickedImage;

  @override
  Widget build(BuildContext context) {
    final color = Color.fromRGBO(64, 105, 225, 1);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSavedState) {
          userName = state.name;
          Navigator.pop(context);
        } else if (state is ProfileCancelState) {
          Navigator.pop(context);
        } else if (state is ProfileImagePickedSuccessState) {
          pickedImage = state.image;
        } else if (state is ProfileImageUpdatedSuccessState) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        BlocProvider.of<ProfileBloc>(context)
                            .add(ProfileSaveToDbEvent(image: pickedImage));
                      },
                      child: Text('s a v e'),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    pickedImage != null
                        ? CircleAvatar(
                            backgroundColor: color,
                            radius: 75,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage:
                                  FileImage(File(pickedImage!.path)),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: color,
                            radius: 75,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: NetworkImage(widget.imageUrl),
                            ),
                          ),
                    Positioned(
                      right: 4,
                      top: 10,
                      child: ClipOval(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          color: Color.fromARGB(255, 246, 240, 240),
                          child: GestureDetector(
                            onTap: () {
                              BlocProvider.of<ProfileBloc>(context)
                                  .add(ProfileImageUpdateEvent());
                            },
                            child: Icon(
                              Icons.edit,
                              color: color,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60))),
                    width: double.infinity,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: Icon(Ionicons.person),
                            title: userName != null
                                ? Text(userName!)
                                : Text(widget.name),
                            trailing: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    backgroundColor: Color(0xffADD8E6),
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              const SizedBox(height: 16.0),
                                              const Text(
                                                'Enter Your Name',
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                              TextField(
                                                controller:
                                                    nameEditingController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText:
                                                      'Enter your text...',
                                                ),
                                              ),
                                              const SizedBox(height: 16.0),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    TextButton(
                                                        onPressed: () {
                                                          BlocProvider.of<
                                                                      ProfileBloc>(
                                                                  context)
                                                              .add(
                                                                  ProfileDataCancelEvent());
                                                        },
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )),
                                                    TextButton(
                                                        onPressed: () {
                                                          BlocProvider.of<
                                                                      ProfileBloc>(
                                                                  context)
                                                              .add(ProfileDataSaveEvent(
                                                                  userName:
                                                                      nameEditingController
                                                                          .text));
                                                        },
                                                        child: Text('Save')),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: Icon(EneftyIcons.document_upload_bold)),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: ListTile(
                        //     leading: Icon(Ionicons.person),
                        //     title: Text('p r e m n a d h @ g mail.com'),
                        //     trailing: IconButton(
                        //         onPressed: () {},
                        //         icon: Icon(Icons.update_disabled)),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
