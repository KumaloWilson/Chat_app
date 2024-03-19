// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_constructors, unnecessary_string_interpolations, unnecessary_brace_in_string_interps
// ignore_for_file: unrelated_type_equality_checks, camel_case_types
import 'package:chat_app/app/controller/profile/bloc/profile_bloc.dart';
import 'package:chat_app/app/utils/components/profilepageshimmer.dart';
import 'package:chat_app/app/view/login/login.dart';
import 'package:chat_app/app/view/profileupdate/profileupdate.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
  }

  String? imageUrl;
  String? name;
  String? id;

  @override
  Widget build(BuildContext context) {
    final color = Color.fromRGBO(64, 105, 225, 1);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is LogoutDoneState) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
        } else if (state is NavigationDoneToProfileUpdatePageState) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProfileUpdate(imageUrl: imageUrl!, name: name!, id: id!),
              ));
        } else if (state is UserDeletedState) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
        }
      },
      builder: (context, state) {
        BlocProvider.of<ProfileBloc>(context).add(FetchingUserDataEvent());
        if (state is UserDataFectchedDone) {
          name = state.name;
          imageUrl = state.imageUrl;
          id = state.id;
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () {
                    BlocProvider.of<ProfileBloc>(context)
                        .add(NavigateToprofileUpdatePageEvent());
                  },
                  icon: const Icon(EneftyIcons.gallery_edit_outline),
                ),
              ],
            ),
            body: Column(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 75,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(imageUrl!),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${name}',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        )),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        ProfileMenuWidget(
                          title: 'D e l e t e  a c c o u n t',
                          onpress: () {
                            BlocProvider.of<ProfileBloc>(context)
                                .add(DeleteButtonClickedEvent());
                          },
                          icon: Ionicons.trash_bin_outline,
                        ),
                        ProfileMenuWidget(
                          title: 'L o g o u t',
                          onpress: () {
                            BlocProvider.of<ProfileBloc>(context)
                                .add(LouOutEvent());
                          },
                          icon: Ionicons.log_out_outline,
                        ),
                        ProfileMenuWidget(
                          title: 'I n v i t e  a  f r i e n d',
                          onpress: () {},
                          icon: Ionicons.share_outline,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        }
        return ProfileSkeletonLoadingIndicator();
      },
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onpress;

  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onpress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onpress,
      leading: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon),
      ),
      title: Text(
        title,
      ),
      trailing: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100), color: Colors.grey[100]),
        child: const Icon(Ionicons.arrow_forward_circle_outline),
      ),
    );
  }
}
