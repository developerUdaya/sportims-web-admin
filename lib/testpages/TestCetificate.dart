import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/ResultModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Certificate Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CertificatePage(),
    );
  }
}

class CertificatePage extends StatefulWidget {
  @override
  _CertificatePageState createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  final GlobalKey _globalKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  String _certificateImageUrl = '';
  String _participantImageUrl = '';
  Uint8List? _certificateImage;
  Uint8List? _participantImage;
  Uint8List? _certificateWithQR;

  List<ResultModel>? results;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificate Generator'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _resultController,
              decoration: InputDecoration(labelText: 'Result'),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _certificateImageUrl = value;
                });
              },
              decoration: InputDecoration(labelText: 'Certificate Image URL'),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _participantImageUrl = value;
                });
              },
              decoration: InputDecoration(labelText: 'Participant Image URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateCertificate,
              child: Text('Generate Certificate'),
            ),
            SizedBox(height: 20),
            _certificateWithQR != null
                ? RepaintBoundary(
              key: _globalKey,
              child: Image.memory(_certificateWithQR!),
            )
                : Container(),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _uploadCertificate,
                  child: Text('Upload to Firebase'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _downloadCertificate,
                  child: Text('Download Certificate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateCertificate() async {
    if (_certificateImageUrl.isEmpty || _participantImageUrl.isEmpty) return;

    _certificateImage = await _loadImageFromUrl(_certificateImageUrl);
    _participantImage = await _loadImageFromUrl(_participantImageUrl);

    if (_certificateImage != null && _participantImage != null) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();

      final certificateImage = await decodeImageFromList(_certificateImage!);
      final participantImage = await decodeImageFromList(_participantImage!);

      canvas.drawImage(certificateImage, Offset.zero, paint);

      final name = _nameController.text;
      final result = _resultController.text;

      final textStyle = TextStyle(color: Colors.black, fontSize: 24);
      final nameSpan = TextSpan(text: name, style: textStyle);
      final resultSpan = TextSpan(text: result, style: textStyle);

      final textPainterName = TextPainter(
        text: nameSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      final textPainterResult = TextPainter(
        text: resultSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );

      textPainterName.layout();
      textPainterName.paint(canvas, Offset(100, 400)); // Adjust position accordingly

      textPainterResult.layout();
      textPainterResult.paint(canvas, Offset(100, 450)); // Adjust position accordingly

// Original dimensions of the participantImage
      final double originalWidth = participantImage.width.toDouble();
      final double originalHeight = participantImage.height.toDouble();

// Desired dimensions for the participantImage on the canvas
      final double desiredWidth = 100;
      final double desiredHeight = 100;

// Calculate scaling factors for width and height
      final double scaleX = desiredWidth / originalWidth;
      final double scaleY = desiredHeight / originalHeight;

// Use the smaller scaling factor to ensure the image fits within the desired dimensions
      final scaleFactor = scaleX < scaleY ? scaleX : scaleY;

// Calculate scaled dimensions
      final double scaledWidth = originalWidth * scaleFactor;
      final double scaledHeight = originalHeight * scaleFactor;

      canvas.save(); // Save the current canvas state
      canvas.scale(scaleFactor, scaleFactor); // Scale the canvas operations

      canvas.drawImage(
        participantImage,
        Offset(400 / scaleFactor, 300 / scaleFactor), // Adjust position for scaled canvas
        paint,
      );

      canvas.restore(); // Restore the canvas state


      final qrValidationResult = QrValidator.validate(
        data: 'https://firebasestorage.googleapis.com/v0/b/sportimsweb.appspot.com/o/certificates%2F${results!.first.eventId}${results!.first.skaterId}${results!.first.chestNumber}.png',
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.Q,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final qrPainter = QrPainter.withQr(
          qr: qrCode,
          color: const Color(0xFF000000),
          gapless: true,
          embeddedImageStyle: null,
          embeddedImage: null,
        );

        final qrCodeSize = 100.0;
        final qrCodeImage = await qrPainter.toImageData(qrCodeSize);
        if (qrCodeImage != null) {
          final qrImage = await decodeImageFromList(qrCodeImage.buffer.asUint8List());
          canvas.drawImage(
            qrImage,
            Offset(500, 300), // Adjust position accordingly
            paint,
          );
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(certificateImage.width, certificateImage.height);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        setState(() {
          _certificateWithQR = byteData.buffer.asUint8List();
        });
      }
    }
  }

  Future<Uint8List?> _loadImageFromUrl(String imageUrl) async {
    try {
      final response = await Dio().get<Uint8List>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      print('Error loading image from $imageUrl: $e');
      return null;
    }
  }

  Future<void> _uploadCertificate() async {
    if (_certificateWithQR == null) return;
    try {
      final storageRef = FirebaseStorage.instance.ref().child('certificates/${results!.first.eventId}${results!.first.skaterId}${results!.first.chestNumber}.png');
      final uploadTask = storageRef.putData(_certificateWithQR!);

      await uploadTask.whenComplete(() async {
        final downloadUrl = await storageRef.getDownloadURL();
        print('Certificate uploaded. Download URL: $downloadUrl');
      });
    } catch (e) {
      print('Error uploading certificate: $e');
    }
  }

  void _downloadCertificate() {
    if (_certificateWithQR == null) return;

    final blob = html.Blob([_certificateWithQR!]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "certificate.png")
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
