import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class Status extends StatefulWidget {
  const Status({Key? key}) : super(key: key);

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File file = File(pickedFile.path);
    String fileName = file.path.split('/').last;

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images/$fileName');
      await ref.putFile(file);

      // Get the download URL
      String downloadURL = await ref.getDownloadURL();

      // Store the download URL in Firestore
      await FirebaseFirestore.instance
          .collection('stickers')
          .add({'sticker': downloadURL});

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Image uploaded successfully!'),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to upload image: $error'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: _uploadImage,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
