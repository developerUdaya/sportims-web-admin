import 'dart:html' as html;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../models/GalleryModel.dart';
import '../../utils/Widgets.dart';


class AddEditGalleryPage extends StatefulWidget {
  final GalleryModel? gallery;

  AddEditGalleryPage({this.gallery});

  @override
  _AddEditGalleryPageState createState() => _AddEditGalleryPageState();
}

class _AddEditGalleryPageState extends State<AddEditGalleryPage> {
  final DatabaseReference galleryRef = FirebaseDatabase.instance.ref().child('gallery');
  TextEditingController titleController = TextEditingController();
  TextEditingController altTextController = TextEditingController();
  TextEditingController imgUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.gallery != null) {
      titleController.text = widget.gallery!.title;
      altTextController.text = widget.gallery!.altText;
      imgUrlController.text = widget.gallery!.imgUrl;
    }
  }

  // Save or update gallery item
  void saveGalleryItem() async {
    if (titleController.text.isEmpty || imgUrlController.text.isEmpty) {
      return; // Show error if required fields are empty
    }

    String id = widget.gallery?.id ?? galleryRef.push().key!;
    final newGalleryItem = GalleryModel(
      id: id,
      title: titleController.text,
      altText: altTextController.text,
      imgUrl: imgUrlController.text,
    );

    galleryRef.child(id).set(newGalleryItem.toJson());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.gallery == null ? 'Add Image' : 'Edit Image'),
        backgroundColor: Color(0xffb0ccf8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              buildTitleAndField('Title', 'Enter title', controller: titleController),
              buildTitleAndField('Alt Text', 'Enter alt text', controller: altTextController),
              buildFileUploadButton('Upload Image', imgUrlController, (file) async {
                // Upload the image and get the URL
                final downloadUrl = await uploadImageToFirebase(file);
                imgUrlController.text = downloadUrl;
              }),
              ElevatedButton(
                onPressed: saveGalleryItem,
                child: Text(widget.gallery == null ? 'Add Image' : 'Update Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusing the file upload method from your previous implementation
  Future<String> uploadImageToFirebase(html.File file) async {
    final storageRef = FirebaseStorage.instance.ref().child('galleryImages/${file.name}');
    await storageRef.putBlob(file);
    return await storageRef.getDownloadURL();
  }
}
