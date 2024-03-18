// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatShareEvent>(chatShareEvent);
    on<NavigateToSearchPageEvent>(navigateToSearchPage);
    on<BottomSheetEvent>(bottomSheetEvent);
    on<GalleryImagesSentEvent>(galleryImagesSentEvent);
    on<LocationSentEvent>(locationSentEvent);
    on<CameraImagesSentEvent>(cameraImagesSentEvent);
    on<VideoCallButtonClickedEvent>(videoCallButtonClickedEvent);
    on<AudioCallButtonClickedEvent>(audioCallButtonClickedEvent);
    on<StickerSentEvent>(stickerSentEvent);
  }

  FutureOr<void> chatShareEvent(
      ChatShareEvent event, Emitter<ChatState> emit) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(event.currentId)
        .collection('messages')
        .doc(event.friendId)
        .collection('chats')
        .add({
      "senderId": event.currentId,
      "receiverId": event.friendId,
      "message": event.message,
      "type": "text",
      "date": DateTime.now(),
    }).then((value) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(event.currentId)
          .collection('messages')
          .doc(event.friendId)
          .set({'last_msg': event.message});
    });
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(event.friendId)
        .collection('messages')
        .doc(event.currentId)
        .collection('chats')
        .add({
      "senderId": event.currentId,
      "receiverId": event.friendId,
      "message": event.message,
      "type": "text",
      "date": DateTime.now(),
    }).then((value) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(event.friendId)
          .collection('messages')
          .doc(event.currentId)
          .set({'last_msg': event.message});
    });
  }

  FutureOr<void> navigateToSearchPage(
      NavigateToSearchPageEvent event, Emitter<ChatState> emit) {
    emit(NavigatedSearchPageDoneState());
  }

  FutureOr<void> bottomSheetEvent(
      BottomSheetEvent event, Emitter<ChatState> emit) {
    emit(BottomSheetSuccessState());
  }

  FutureOr<void> galleryImagesSentEvent(
      GalleryImagesSentEvent event, Emitter<ChatState> emit) async {
    final imagePicker = ImagePicker();
    String fileName = const Uuid().v1();

    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      emit(GalleryImageSentSuccessState());

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        var ref = FirebaseStorage.instance
            .ref()
            .child('images')
            .child("$fileName.jpg");
        var uploadTask = await ref.putFile(imageFile);
        String imageUrl = await uploadTask.ref.getDownloadURL();

        // Save the image URL to Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(event.currentId)
            .collection('messages')
            .doc(event.friendId)
            .collection('chats')
            .add({
          "senderId": event.currentId,
          "receiverId": event.friendId,
          "message": imageUrl,
          "type": "img",
          "date": DateTime.now(),
        });

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(event.friendId)
            .collection('messages')
            .doc(event.currentId)
            .collection('chats')
            .add({
          "senderId": event.currentId,
          "receiverId": event.friendId,
          "message": imageUrl,
          "type": "img",
          "date": DateTime.now(),
        });

        // Update last message
        FirebaseFirestore.instance
            .collection('Users')
            .doc(event.currentId)
            .collection('messages')
            .doc(event.friendId)
            .set({'last_msg': imageUrl});

        FirebaseFirestore.instance
            .collection('Users')
            .doc(event.friendId)
            .collection('messages')
            .doc(event.currentId)
            .set({'last_msg': imageUrl});
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  FutureOr<void> locationSentEvent(
      LocationSentEvent event, Emitter<ChatState> emit) async {
    Position? currentPosition;
    String? currentAddress;
    String? message;
    LocationPermission? permission;

    try {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('location permission are denied');

        if (permission == LocationPermission.deniedForever) {
          print('location permition are denied forever');
        }
      }
      // Fetch the current position asynchronously and wait for it
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
      );

      print(currentPosition.latitude);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);

      Placemark place = placemarks[0];

      currentAddress = "${place.locality},${place.postalCode},${place.street}";
      String latitude = currentPosition.latitude.toString();
      String longitude = currentPosition.longitude.toString();

      message =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.currentId)
          .collection('messages')
          .doc(event.friendId)
          .collection('chats')
          .add({
        "senderId": event.currentId,
        "receiverId": event.friendId,
        "message": message,
        "type": "link",
        "date": DateTime.now(),
      });

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.friendId)
          .collection('messages')
          .doc(event.currentId)
          .collection('chats')
          .add({
        "senderId": event.currentId,
        "receiverId": event.friendId,
        "message": message,
        "type": "link",
        "date": DateTime.now(),
      });

      // Update last message
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.currentId)
          .collection('messages')
          .doc(event.friendId)
          .set({'last_msg': message});

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.friendId)
          .collection('messages')
          .doc(event.currentId)
          .set({'last_msg': message});
    } catch (e) {
      print(e.toString());
    }
  }

  FutureOr<void> cameraImagesSentEvent(
      CameraImagesSentEvent event, Emitter<ChatState> emit) async {
    final imagePicker = ImagePicker();
    String fileName = const Uuid().v1();

    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.camera);
      emit(GalleryImageSentSuccessState());

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        var ref = FirebaseStorage.instance
            .ref()
            .child('images')
            .child("$fileName.jpg");
        var uploadTask = await ref.putFile(imageFile);
        String imageUrl = await uploadTask.ref.getDownloadURL();

        // Save the image URL to Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(event.currentId)
            .collection('messages')
            .doc(event.friendId)
            .collection('chats')
            .add({
          "senderId": event.currentId,
          "receiverId": event.friendId,
          "message": imageUrl,
          "type": "img",
          "date": DateTime.now(),
        });

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(event.friendId)
            .collection('messages')
            .doc(event.currentId)
            .collection('chats')
            .add({
          "senderId": event.currentId,
          "receiverId": event.friendId,
          "message": imageUrl,
          "type": "img",
          "date": DateTime.now(),
        });

        // Update last message
        FirebaseFirestore.instance
            .collection('Users')
            .doc(event.currentId)
            .collection('messages')
            .doc(event.friendId)
            .set({'last_msg': imageUrl});

        FirebaseFirestore.instance
            .collection('Users')
            .doc(event.friendId)
            .collection('messages')
            .doc(event.currentId)
            .set({'last_msg': imageUrl});
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  FutureOr<void> videoCallButtonClickedEvent(
      VideoCallButtonClickedEvent event, Emitter<ChatState> emit) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.friendId)
          .get();
      emit(VideoCallWorkingState(
          token: snapshot['token'], name: snapshot['name']));
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  FutureOr<void> audioCallButtonClickedEvent(
      AudioCallButtonClickedEvent event, Emitter<ChatState> emit) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.friendId)
          .get();
      emit(AudioCallWorkingState(
          token: snapshot['token'], name: snapshot['name']));
    } catch (error) {
      print("Error fetching user data: $error");
    }
  }

  FutureOr<void> stickerSentEvent(
      StickerSentEvent event, Emitter<ChatState> emit) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(event.currentId)
        .collection('messages')
        .doc(event.friendId)
        .collection('chats')
        .add({
      "senderId": event.currentId,
      "receiverId": event.friendId,
      "message": event.message,
      "type": "sticker",
      "date": DateTime.now(),
    });

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(event.friendId)
        .collection('messages')
        .doc(event.currentId)
        .collection('chats')
        .add({
      "senderId": event.currentId,
      "receiverId": event.friendId,
      "message": event.message,
      "type": "sticker",
      "date": DateTime.now(),
    });

    // Update last message
    FirebaseFirestore.instance
        .collection('Users')
        .doc(event.currentId)
        .collection('messages')
        .doc(event.friendId)
        .set({'last_msg': event.message});

    FirebaseFirestore.instance
        .collection('Users')
        .doc(event.friendId)
        .collection('messages')
        .doc(event.currentId)
        .set({'last_msg': event.message});
  }
}
