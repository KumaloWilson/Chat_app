import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LouOutEvent>(louOutEvent);
    on<FetchingUserDataEvent>(fetchingUserDataEvent);
    on<ProfileDataSaveEvent>(profileDataSaveEvent);
    on<NavigateToprofileUpdatePageEvent>(navigateToprofileUpdatePageEvent);
    on<ProfileDataCancelEvent>(profileDataCancelEvent);
    on<ProfileImageUpdateEvent>(profileImageUpdateEvent);
    on<ProfileSaveToDbEvent>(profileSaveToDbEvent);
    on<DeleteButtonClickedEvent>(deleteButtonClickedEvent);
  }

  FutureOr<void> louOutEvent(LouOutEvent event, Emitter<ProfileState> emit) {
    FirebaseAuth.instance.signOut();
    emit(LogoutDoneState());
  }

  FutureOr<void> fetchingUserDataEvent(
      FetchingUserDataEvent event, Emitter<ProfileState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        final name = value.docs.first['name'];
        final id = value.docs.first.id;
        final imageUrl = value.docs.first['image'];
        emit(UserDataFectchedDone(name: name, imageUrl: imageUrl, id: id));
      });
    } catch (e) {
      print(e.toString());
    }
  }

  FutureOr<void> navigateToprofileUpdatePageEvent(
      NavigateToprofileUpdatePageEvent event, Emitter<ProfileState> emit) {
    emit(NavigationDoneToProfileUpdatePageState());
  }

  FutureOr<void> profileDataSaveEvent(
      ProfileDataSaveEvent event, Emitter<ProfileState> emit) async {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .update({'name': event.userName});
    emit(ProfileSavedState(name: event.userName));
  }

  FutureOr<void> profileDataCancelEvent(
      ProfileDataCancelEvent event, Emitter<ProfileState> emit) {
    emit(ProfileCancelState());
  }

  FutureOr<void> profileImageUpdateEvent(
      ProfileImageUpdateEvent event, Emitter<ProfileState> emit) async {
    final imagePicker = ImagePicker();
    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        emit(ProfileImagePickedSuccessState(image: File(pickedFile.path)));
      } else {
        emit(ProfileImagePickedErrorState());
      }
    } catch (e) {
      print(e.toString());
    }
  }

  FutureOr<void> profileSaveToDbEvent(
      ProfileSaveToDbEvent event, Emitter<ProfileState> emit) async {
    final storageRef = FirebaseStorage.instance.ref();
    User? user = FirebaseAuth.instance.currentUser;
    try {
      TaskSnapshot uploadTask = await storageRef
          .child('profile_images')
          .child(user!.uid)
          .putFile(event.image);
      String imageUrl = await uploadTask.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .update({
        'image': imageUrl,
      });
      emit(ProfileImageUpdatedSuccessState());
    } catch (e) {
      print(e.toString());
    }
  }

  FutureOr<void> deleteButtonClickedEvent(
      DeleteButtonClickedEvent event, Emitter<ProfileState> emit) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        user.delete();
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .delete();
        emit(UserDeletedState());
      }
    } catch (e) {
      print(e);
    }
  }
}
