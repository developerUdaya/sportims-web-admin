import 'dart:html' as html;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/NewsModel.dart';
import '../../utils/Widgets.dart';

class AddEditNewsPage extends StatefulWidget {
  final NewsModel? news;

  AddEditNewsPage({this.news});

  @override
  _AddEditNewsPageState createState() => _AddEditNewsPageState();
}

class _AddEditNewsPageState extends State<AddEditNewsPage> {
  final DatabaseReference newsRef = FirebaseDatabase.instance.ref().child('appData/news');
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController subtitleController;
  late TextEditingController dateController;
  late TextEditingController contentController;
  TextEditingController imgUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.news?.title ?? '');
    subtitleController = TextEditingController(text: widget.news?.subtitle ?? '');
    dateController = TextEditingController(text: widget.news?.date ?? '');
    contentController = TextEditingController(text: widget.news?.content ?? '');
  }

  // Save or update news
  void saveNews() async {
    if (_formKey.currentState!.validate()) {
      String id = widget.news?.id ?? newsRef.push().key!;
      final newNews = NewsModel(
        id: id,
        title: titleController.text,
        subtitle: subtitleController.text,
        date: dateController.text,
        content: contentController.text,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
        imgUrl: imgUrlController.text,
      );

      newsRef.child(id).set(newNews.toJson());
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.news == null ? 'Add News' : 'Edit News'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTitleAndField('Title', 'Enter title', controller: titleController),
              buildTitleAndField('Subtitle', 'Enter subtitle', controller: subtitleController),
              buildTitleAndField('Author', 'Enter Author Name', controller: dateController),
              buildTitleAndField('Content', 'Enter content', controller: contentController, isMultiline: true),
              buildFileUploadButton('Upload Image', imgUrlController, (file) async {
                // Upload the image and get the URL
                final downloadUrl = await uploadImageToFirebase(file);
                imgUrlController.text = downloadUrl;
              }),
              ElevatedButton(
                onPressed: saveNews,
                child: Text(widget.news == null ? 'Add News' : 'Update News'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> uploadImageToFirebase(html.File file) async {
    // Upload image to Firebase Storage and return the download URL
    final storageRef = FirebaseStorage.instance.ref().child('newsImages/${file.name}');
    await storageRef.putBlob(file);
    return await storageRef.getDownloadURL();
  }
}
