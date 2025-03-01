import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';


class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? fileName;
  html.File? file;
  Uint8List? imageData;
  String? uploadedImageUrl;
  bool isUploading = false;

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final Uint8List? fileBytes = result.files.single.bytes;
      setState(() {
        file = result.files.single.bytes != null ? html.File(result.files.single.bytes!, result.files.single.name) : null;
        fileName = result.files.single.name;
        imageData = fileBytes;
        uploadedImageUrl = null; // Reset uploaded image URL
      });
    }
  }

  Future<void> uploadFile() async {
    if (file == null) return; // No file selected

    setState(() {
      isUploading = true;
    });

    try {
      await Firebase.initializeApp();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child(fileName!);
      await ref.putBlob(file!);

      // Get download URL and update state
      String downloadURL = await ref.getDownloadURL();
      setState(() {
        uploadedImageUrl = downloadURL;
        isUploading = false;
      });

      print('File uploaded to Firebase Storage successfully!');
      print('Download URL: $downloadURL');
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      print('File upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload to Firebase Storage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: pickFile,
              child: file != null && imageData != null
                  ? Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: MemoryImage(imageData!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Click here to choose an image',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isUploading ? null : uploadFile,
              child: Text('Upload Image'),
            ),
            if (isUploading) CircularProgressIndicator(),

          ],
        ),
      ),
    );
  }
}
