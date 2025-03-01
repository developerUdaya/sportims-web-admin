import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sport_ims/player/SkaterEditRegistrationForm.dart';
import '../models/UsersModel.dart';
import '../utils/Controllers.dart';

class SkaterProfilePage extends StatefulWidget {
  final Users skater;

  SkaterProfilePage({required this.skater});

  @override
  _SkaterProfilePageState createState() => _SkaterProfilePageState();
}

class _SkaterProfilePageState extends State<SkaterProfilePage> {
  Uint8List? _imageData;
  bool isEditing = false;
  bool _isSaving = false;

  double _cropTop = 0, _cropLeft = 0, _cropWidth = 200, _cropHeight = 200;
  final double _canvasWidth = 400, _canvasHeight = 400;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Skater Profile'),
      //   backgroundColor: Colors.blue[700],
      //   actions: [
      //     if (!isEditing)
      //       IconButton(
      //         icon: Icon(Icons.edit, color: Colors.white),
      //         onPressed: () {
      //           setState(() {
      //             isEditing = true;
      //           });
      //         },
      //       ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header Section
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Color(0xFFDD5E89), Color(0xFFF7BB97)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Skater Profile Image
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageData != null
                              ? MemoryImage(_imageData!)
                              : CachedNetworkImageProvider(widget.skater.profileImageUrl) as ImageProvider,
                          backgroundColor: Colors.grey[200],
                        ),
                        // Edit Icon
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt, color: Colors.blue[700], size: 24),
                            ),
                          ),
                        ),


                      ],
                    ),
                    SizedBox(width: 16),
                    // Skater Name and ID
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.skater.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skater ID: ${widget.skater.skaterID}',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),

                    IconButton(
                      icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          showDialog(context: context,barrierColor: Colors.transparent, builder: (context) => MaterialApp(home: SkaterEditRegistrationForm(skater: widget.skater)),);
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Display Crop Area
              if (isEditing && _imageData != null)
                Center(
                  child: Container(
                    width: _canvasWidth,
                    height: _canvasHeight,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(_canvasWidth, _canvasHeight),
                          painter: CropPainter(
                            top: _cropTop,
                            left: _cropLeft,
                            width: _cropWidth,
                            height: _cropHeight,
                          ),
                          child: Container(
                            width: _canvasWidth,
                            height: _canvasHeight,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: MemoryImage(_imageData!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: _cropTop + _cropHeight - 10,
                          left: _cropLeft + _cropWidth - 10,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _cropWidth = (_cropWidth + details.delta.dx).clamp(50, _canvasWidth - _cropLeft);
                                _cropHeight = (_cropHeight + details.delta.dy).clamp(50, _canvasHeight - _cropTop);
                              });
                            },
                            child: Icon(Icons.crop_square, color: Colors.red, size: 24),
                          ),
                        ),
                        Positioned(
                          top: _cropTop,
                          left: _cropLeft,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _cropTop = (_cropTop + details.delta.dy).clamp(0, _canvasHeight - _cropHeight);
                                _cropLeft = (_cropLeft + details.delta.dx).clamp(0, _canvasWidth - _cropWidth);
                              });
                            },
                            child: Container(
                              width: _cropWidth,
                              height: _cropHeight,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),



                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              if (isEditing && _imageData != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _cropImage,
                      icon: Icon(Icons.crop, color: Colors.white),
                      label: Text('Crop & Save', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isEditing = false;
                          _imageData = null;
                        });
                      },
                      icon: Icon(Icons.cancel, color: Colors.white),
                      label: Text('Cancel', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              Row(
                children: [

                ],
              ),

              // Skater Info Section
              buildInfoCard('Skater Details', [
                buildInfoRow('Email', widget.skater.email),
                buildInfoRow('Contact Number', widget.skater.contactNumber),
                buildInfoRow('Date of Birth',widget.skater.dateOfBirth),
                buildInfoRow('Blood Group', widget.skater.bloodGroup),
                buildInfoRow('Gender', widget.skater.gender),
              ]),

              // Club Info Section
              buildInfoCard('Club & School Information', [
                buildInfoRow('Club', widget.skater.club),
                buildInfoRow('School', widget.skater.school),
                buildInfoRow('School Affiliation Number', widget.skater.schoolAffiliationNumber),
              ]),

              // Other Information
              buildInfoCard('Additional Information', [
                buildInfoRow('Skate Category', widget.skater.skateCategory),
                buildInfoRow('Aadhar/Birth Certificate Number', widget.skater.aadharBirthCertificateNumber),
                buildInfoRow('Registration Date', widget.skater.regDate),
                buildInfoRow('Approval Status', widget.skater.approval),
              ]),

            ],
          ),
        ),
      ),
    );
  }


  Widget buildInfoCard(String title, List<Widget> rows) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
            ),
            SizedBox(height: 16),
            Column(
              children: rows,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
  // Pick an image using Image Picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final Uint8List fileData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = fileData;
        isEditing = true;
      });
    }
  }

  // Manually crop the image
  Future<void> _cropImage() async {
    BuildContext dialogContext = context; // Create a variable to hold the dialog context

    // Show the circular progress dialog and store the context
    showDialog(
      context: context,
      builder: (context) {
        dialogContext = context; // Assign the context of the dialog to the variable
        return Center(
          child: CircularProgressIndicator(
            color: Colors.blueAccent,
          ),
        );
      },
    );

    if (_imageData == null) {
      Navigator.pop(dialogContext); // Close the dialog if no image data is available
      return;
    }

    try {
      // Decode the image
      img.Image originalImage = img.decodeImage(_imageData!)!;
      int x = (_cropLeft * originalImage.width / _canvasWidth).round();
      int y = (_cropTop * originalImage.height / _canvasHeight).round();
      int width = (_cropWidth * originalImage.width / _canvasWidth).round();
      int height = (_cropHeight * originalImage.height / _canvasHeight).round();

      // Crop the image
      img.Image croppedImage = img.copyCrop(originalImage, x: x, y: y, width: width, height: height);

      // Convert back to Uint8List
      Uint8List croppedBytes = Uint8List.fromList(img.encodeJpg(croppedImage));

      // Upload to Firebase Storage
      String fileName = widget.skater.skaterID + '_profile.jpg';
      final ref = FirebaseStorage.instance.ref().child('skater_images/$fileName');
      await ref.putData(croppedBytes);

      // Get the download URL and update the profile image URL
      String imageUrl = await ref.getDownloadURL();
      await FirebaseDatabase.instance
          .ref('skaters/${widget.skater.contactNumber}')
          .update({'profileImageUrl': imageUrl});

      setState(() {
        widget.skater.profileImageUrl = imageUrl;
        _imageData = croppedBytes;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile image updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error occurred while cropping and saving the image",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );

      print("Error occurred while cropping and saving the image: $e");
    } finally {
      // Always pop the dialog context, not the main context
      Navigator.pop(dialogContext);
    }
  }
}

// Custom painter to highlight the cropping area
class CropPainter extends CustomPainter {
  final double top;
  final double left;
  final double width;
  final double height;

  CropPainter({required this.top, required this.left, required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.red.withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(left, top, width, height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }


}
