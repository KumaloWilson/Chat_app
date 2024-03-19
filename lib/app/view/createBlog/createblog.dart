import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:ionicons/ionicons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:chat_app/app/utils/components/custombutton.dart';
import 'package:chat_app/app/utils/components/customtextFIeld.dart';

class CreateBlog extends StatefulWidget {
  const CreateBlog({Key? key}) : super(key: key);

  @override
  State<CreateBlog> createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  List<String> selectedCategory = [];
  File? image;

  Future<void> uploadBlogData(String imageUrl) async {
    final blogData = {
      'title': titleController.text,
      'description': descController.text,
      'imageUrl': imageUrl,
      'categories': selectedCategory,
      // Add more fields as needed
    };

    await FirebaseFirestore.instance.collection('blogs').add(blogData);

    // Reset form fields and image after upload
    titleController.clear();
    descController.clear();
    selectedCategory.clear();
    setState(() {
      image = null;
    });

    // Navigate back to the previous screen
    Navigator.pop(context);
  }

  Future<void> uploadImage() async {
    if (image != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child("${randomAlphaNumeric(9)}.jpg");

      final TaskSnapshot result = await storageRef.putFile(image!);
      final downloadUrl = await result.ref.getDownloadURL();

      print('Image uploaded. URL: $downloadUrl');

      // Upload blog data to Firestore after image upload
      uploadBlogData(downloadUrl);
    }
  }

  void selectImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Blog"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              image != null
                  ? GestureDetector(
                      onTap: selectImage,
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(image!, fit: BoxFit.cover),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: selectImage,
                      child: DottedBorder(
                        strokeCap: StrokeCap.round,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(10),
                        color: Colors.grey,
                        dashPattern: const [10, 4],
                        child: const SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 15),
                              Text("Select your image",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    "Programming",
                    "Business",
                    "Quote",
                    "Sports",
                    "Entertainment"
                  ].map((e) {
                    final isSelected = selectedCategory.contains(e);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelected
                                ? selectedCategory.remove(e)
                                : selectedCategory.add(e);
                          });
                        },
                        child: Chip(
                          backgroundColor:
                              isSelected ? Colors.orange : Colors.transparent,
                          label: Text(e),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              CustomTextForm(
                  controller: titleController, hintText: "Blog title"),
              CustomTextForm(
                  controller: descController, hintText: "Blog Content"),
              const SizedBox(height: 25),
              CustomButtons(
                  onTap: uploadImage,
                  icon: Ionicons.cloud_upload,
                  title: "Upload"),
            ],
          ),
        ),
      ),
    );
  }
}
