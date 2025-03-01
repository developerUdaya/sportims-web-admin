import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

import '../../models/EventScheduleModel.dart';
import '../../models/ResultModel.dart';
import '../../models/UsersModel.dart';

class FirebaseService {
  final database = FirebaseDatabase.instance;

  Future<DataSnapshot> fetchCertificateDetails(String eventId) async {
    return await database.ref().child("events/pastEvents/$eventId/certificateDetails/").get();
  }

  Future<void> updateResultPublication(String eventId, String scheduleId, String resultId) async {
    final ref = database.ref().child('events/pastEvents/$eventId/eventSchedules/$scheduleId/resultList/$resultId');
    await ref.update({'published': 'Published'});
  }

  Future<void> saveCertificateUrl(String skaterMobileNumber, String eventId, String certUrl) async {
    final ref = database.ref().child("skaters/$skaterMobileNumber/events/$eventId/certUrl");
    await ref.set(certUrl);
  }
}

class PDFService {
  Future<Uint8List> fetchImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }
    return response.bodyBytes;
  }

  Future<Uint8List> generateQrCode(String data) async {
    final qrPainter = QrPainter(data: data, version: QrVersions.auto, gapless: true);
    final qrByteData = await qrPainter.toImageData(200);
    return qrByteData!.buffer.asUint8List();
  }

  pw.Document createCertificate(
      ResultModel result,
      Uint8List backgroundImageData,
      Uint8List? profileImageData,
      List<Map<String, dynamic>> textFields,
      Uint8List qrCodeData,
      ) {
    final image = pw.MemoryImage(backgroundImageData);
    final qrImage = pw.MemoryImage(qrCodeData);
    final profileImage = profileImageData != null ? pw.MemoryImage(profileImageData) : null;

    final document = pw.Document();
    document.addPage(
      pw.Page(
        build: (context) => pw.Stack(
          children: [
            pw.Image(image, fit: pw.BoxFit.cover),
            for (var field in textFields)
              pw.Positioned(
                left: field['x'],
                top: field['y'],
                child: pw.Text(
                  field['text']
                      .replaceAll("{{name}}", result.skaterName)
                      .replaceAll("{{chest_no}}", result.chestNumber)
                      .replaceAll("{{event_name}}", result.eventName)
                      .replaceAll("{{age_category}}", result.ageCategory)
                      .replaceAll("{{skater_category}}", result.skaterCategory)
                      .replaceAll(
                    "{{result}}",
                    result.categoryResultModel
                        .map((model) => '"${model.raceCategory}": "${model.result}"')
                        .join('\n'),
                  ),
                  style: pw.TextStyle(
                    color: PdfColor.fromInt(field['color']),
                    fontSize: field['fontSize'],
                  ),
                ),
              ),
            if (profileImage != null)
              pw.Positioned(
                top: 20,
                right: 20,
                child: pw.Image(profileImage, width: 100, height: 100),
              ),
            pw.Positioned(
              bottom: 20,
              left: context.page.pageFormat.width / 2,
              child: pw.Image(qrImage, width: 100, height: 100),
            ),
          ],
        ),
      ),
    );

    return document;
  }
}

Future<void> publishAllParticipants(
    String eventId,
    List<ResultModel> results,
    List<Users> allSkaters,
    BuildContext context,
    List<EventScheduleModel> schedules,
    ) async {
  final firebaseService = FirebaseService();
  final pdfService = PDFService();

  // Fetch Certificate Details
  final Map<String, dynamic> certDetails = await _fetchCertificateDetails(firebaseService, eventId);
  final imageUrl = certDetails['imageUrl'];
  final textFields = List<Map<String, dynamic>>.from(
    (certDetails['textFields'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
  );

  // Fetch Background Image
  final Uint8List backgroundImageData = await pdfService.fetchImage(imageUrl);

  // Process Each Participant
  for (var result in results) {
    try {
      // Update Result Publication
      await _updatePublicationStatus(firebaseService, result, schedules, eventId);

      // Fetch Certificate Components
      final certUrl = _generateCertificateUrl(eventId, result.skaterId);
      final qrCodeData = await pdfService.generateQrCode(certUrl);
      final profileImageData = await _fetchProfileImage(pdfService, allSkaters, result.skaterId);

      // Generate and Save Certificate
      final downloadUrl = await _generateAndSaveCertificate(
        pdfService,
        firebaseService,
        eventId,
        result,
        backgroundImageData,
        profileImageData,
        textFields,
        qrCodeData,
      );

      // Save Certificate URL
      final skaterMobileNumber = _getSkaterMobileNumber(allSkaters, result.skaterId);
      await firebaseService.saveCertificateUrl(skaterMobileNumber, eventId, downloadUrl);
    } catch (e) {
      print('Error processing participant: $e');
    }
  }
}

// Helper Methods
Future<Map<String, dynamic>> _fetchCertificateDetails(FirebaseService firebaseService, String eventId) async {
  final snapshot = await firebaseService.fetchCertificateDetails(eventId);
  return Map<String, dynamic>.from(snapshot.value as Map);
}

Future<void> _updatePublicationStatus(
    FirebaseService firebaseService,
    ResultModel result,
    List<EventScheduleModel> schedules,
    String eventId,
    ) async {
  for (var categoryResult in result.categoryResultModel) {
    final resultId = findResultId(result.skaterId, categoryResult.eventScheduleId, schedules);
    if (resultId != null) {
      await firebaseService.updateResultPublication(eventId, categoryResult.eventScheduleId, resultId);
    }
  }
}

String _generateCertificateUrl(String eventId, String skaterId) {
  return "https://firebasestorage.googleapis.com/v0/b/sportimsweb.appspot.com/o/certificates%2F$eventId%2F${eventId}-${skaterId}.pdf?alt=media";
}

Future<Uint8List?> _fetchProfileImage(
    PDFService pdfService,
    List<Users> allSkaters,
    String skaterId,
    ) async {
  final profileImageUrl = allSkaters.firstWhere((skater) => skater.skaterID == skaterId).profileImageUrl;
  if (profileImageUrl.isNotEmpty) {
    return await pdfService.fetchImage(profileImageUrl);
  }
  return null;
}

Future<String> _generateAndSaveCertificate(
    PDFService pdfService,
    FirebaseService firebaseService,
    String eventId,
    ResultModel result,
    Uint8List backgroundImageData,
    Uint8List? profileImageData,
    List<Map<String, dynamic>> textFields,
    Uint8List qrCodeData,
    ) async {
  final individualPdf = pdfService.createCertificate(
    result,
    backgroundImageData,
    profileImageData,
    textFields,
    qrCodeData,
  );

  // Save Certificate to Firebase
  final Uint8List pdfBytes = await individualPdf.save();
  final storageRef = FirebaseStorage.instance.ref().child('certificates/$eventId/${eventId}-${result.skaterId}.pdf');
  await storageRef.putData(pdfBytes);
  return await storageRef.getDownloadURL();
}

String _getSkaterMobileNumber(List<Users> allSkaters, String skaterId) {
  return allSkaters.firstWhere((skater) => skater.skaterID == skaterId).contactNumber;
}

String? findResultId(String skaterId, String scheduleId, List<EventScheduleModel> schedules) {
  try {
    for (var schedule in schedules) {
      if (schedule.scheduleId == scheduleId) {
        return schedule.resultList.asMap().entries
            .firstWhere((entry) => entry.value.skaterId == skaterId)
            .key
            .toString();
      }
    }
  } catch (e) {
    print('Error finding resultId: $e');
  }
  return null;
}
