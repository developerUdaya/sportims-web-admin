import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_database/firebase_database.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sport_ims/models/EventScheduleModel.dart';
import 'package:http/http.dart' as http;
import '../models/EventModel.dart';

import '../models/ResultModel.dart';
import '../models/UsersModel.dart';

class PublishDataPage extends StatefulWidget {
  EventModel? eventModel;

  PublishDataPage({required this.eventModel});

  @override
  State<PublishDataPage> createState() => _PublishDataPageState();
}

class _PublishDataPageState extends State<PublishDataPage> {

  List<EventScheduleModel> allSchedules = [];
  List<EventScheduleModel> tableData = [];
  List<ResultModel> results = [];
  List<Users> allSkaters =[];
  bool enablePublish = false;
  final database = FirebaseDatabase.instance;
  @override
  void initState() {
    super.initState();
    getEventScheduleModel(widget.eventModel!.id);
    getPublishValue();
    getUsers();


  }

  Future<void> getUsers() async {
    // Show loading dialog
    List<Users> users = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('skaters');
    // Fetch the data once using a single await call
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        // Convert each child snapshot to a Club object
        Users user;
        try {
          user = Users.fromJson(Map<String, dynamic>.from(child.value as Map));
          users.add(user);
          print(user.name);
        }catch(e){
          print(e);
        }
      }
    } else {
      print('No data available.');
    }
    setState(() {
      allSkaters = users;
    });
  }

  Future<void> getPublishValue() async {
    DataSnapshot publishRef = await database.ref().child('events/pastEvents/${widget.eventModel!.id}/published/').get();
    setState(() {
      enablePublish = publishRef.exists? publishRef.value as String != 'Published':true;
    });
  }

  Future<void> getEventScheduleModel(String eventId) async {
    List<EventScheduleModel> eventSchedules = [];
    List<ResultModel> allResults = [];

    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('events/pastEvents/$eventId/eventSchedules');

    try {
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          try {
            EventScheduleModel eventSchedule = EventScheduleModel.fromJson(Map<String, dynamic>.from(child.value as Map));
            eventSchedules.add(eventSchedule);
          } catch (e) {
            print('Error converting child snapshot to EventScheduleModel: $e');
          }
        }
      } else {
        print('No data available.');
      }

      for (EventScheduleModel schedule in eventSchedules) {
        List<ResultModel> filteredResults = schedule.resultList.where((result) => result.published != "Published").toList();
        allResults.addAll(filteredResults);
      }

      setState(() {
        tableData = eventSchedules;
        allSchedules = eventSchedules;
        results = allResults;
      });
    } catch (e) {
      print('Error fetching data from Firebase: $e');
    }
  }
  
  Future<void> checkForCertificateStatus() async {
    final ref = database.ref().child('events/pastEvents/${widget.eventModel!.id}/certificateStatus');
    final eventScheduleRef = database.ref().child('events/pastEvents/${widget.eventModel!.id}/eventSchedules');
    final certStatusSnapShot = await ref.get();
    if(certStatusSnapShot.exists){
      bool certificateStatus = certStatusSnapShot.value as bool;
      if(certificateStatus){
        publishAllParticipants();
      }else{
        bool? confirmation = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Certificate Generation Diabled'),
              content: Text('Are you sure you want to publish all participants without certificates? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Publish'),
                ),
              ],
            );
          },
        );

        if (confirmation == true) {

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(child: CircularProgressIndicator(color: Colors.blue,),)
          );
          try {
            for (var result in results) {
              // Fetch and update result for each event schedule
              for (var categoryResultModel in result.categoryResultModel) {
                String? resultId = findResultId(
                    result.skaterId, categoryResultModel.eventScheduleId);
                await eventScheduleRef.child(
                    '${categoryResultModel
                        .eventScheduleId}/resultList/$resultId')
                    .update({'published': 'Published'});
              }
            }

            final publishRef = database.ref().child('events/pastEvents/${widget.eventModel!.id}/published/');
            publishRef.set('Published');

            setState(() {
              enablePublish = false;
            });
            Navigator.of(context, rootNavigator: true).pop(); // Close only the dialog


            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All participants published successfully')));

            showSuccessDialog('All participants published successfully');
            // Ensure only the dialog is clos
          }catch(e){
            Navigator.of(context, rootNavigator: true).pop(); // Close only the dialog

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Occurred')));
            return;
          }

          }
      }
    }
  }

  Future<void> publishAllParticipants() async {
    bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Publish'),
          content: Text('Are you sure you want to publish all participants? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Publish'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      final ref = database.ref().child('events/pastEvents/${widget.eventModel!.id}/eventSchedules');
      final DatabaseReference certref = database.ref().child("events/pastEvents/${widget.eventModel?.id}/certificateDetails/");
      final DataSnapshot snapshot = await certref.get();
      final Map<String, dynamic> snapshotValue = Map<String, dynamic>.from(snapshot.value as Map);

      final String imageUrl = snapshotValue['imageUrl'];
      final List<Map<String, dynamic>> textFields = List<Map<String, dynamic>>.from(
        (snapshotValue['textFields'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );

      // Create a new PDF document to hold the combined certificates
      final pw.Document combinedPdf = pw.Document();

      int totalCertificates = results.length;
      final ValueNotifier<int> currentCountNotifier = ValueNotifier<int>(0);

      showDialog(
        context: context,
        barrierDismissible: false,

        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Generating Certificates'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Please do not close the tab and ensure proper internet connectivity.'),
                SizedBox(height: 20),
                ValueListenableBuilder<int>(
                  valueListenable: currentCountNotifier,
                  builder: (context, currentCount, _) {
                    return Text('Generated: $currentCount/$totalCertificates certificates');
                  },
                ),
              ],
            ),
          );
        },
      );

      for (var result in results) {
        String? profileUrl = '';

        try {
          // Fetch and update result for each event schedule
          for (var categoryResultModel in result.categoryResultModel) {
            String? resultId = findResultId(result.skaterId, categoryResultModel.eventScheduleId);
            await ref.child('${categoryResultModel.eventScheduleId}/resultList/$resultId').update({'published': 'Published'});
          }

          // Fetch profile image URL for the participant
          profileUrl = allSkaters.firstWhere((element) => element.skaterID==result.skaterId).profileImageUrl;
          String skaterMobileNumber = allSkaters.firstWhere((element) => element.skaterID==result.skaterId).contactNumber;

          // Generate certificate for the individual participant
          await generateCertificate(result, profileUrl, imageUrl, textFields, combinedPdf,skaterMobileNumber);



          // Update progress
          currentCountNotifier.value++;


          //current count is not updating in dialog box
          // Rebuild dialog with updated count

        } catch (e) {
          Navigator.of(context, rootNavigator: true).pop(); // Close only the dialog

          print('Error updating data: $e');

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Occurred')));
          return;
        }
      }

      // After all certificates are generated, save the combined PDF
      final storageRefCombined = FirebaseStorage.instance
          .ref()
          .child('certificates/${widget.eventModel!.id}/combined_certificates.pdf');

      // Save the combined PDF to bytes
      final Uint8List combinedPdfBytes = await combinedPdf.save();

      // Upload the combined PDF to Firebase Storage
      await storageRefCombined.putData(combinedPdfBytes);
      final String combinedPdfUrl = await storageRefCombined.getDownloadURL();

      // Update Firebase with the combined PDF URL
      final DatabaseReference combinedCertRef = database.ref().child("events/pastEvents/${widget.eventModel!.id}/combinedCertUrl");
      await combinedCertRef.set(combinedPdfUrl);

      final publishRef = database.ref().child('events/pastEvents/${widget.eventModel!.id}/published/');
      publishRef.set('Published');

      // Ensure only the dialog is closed

      //close the dialog here. but it is actually closing the screen behind it . not the dialog

      Navigator.of(context, rootNavigator: true).pop(); // Close only the dialog


      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All participants published successfully')));

      showSuccessDialog('All participants published successfully');

      setState(() {
        results.clear();
      });
    }
  }

  void requestCertificateGeneration() {
    List<Map<String, dynamic>> participants = [
      {
        "player_id": "player123",
        "name": "John Doe",
        "imgUrl": "https://example.com/player123.png",
        "eventName": "Speed Skating Championship",
        "dob": "2005-08-12",
        "raceCategorywithResult": {
          "100m": "1st Place",
          "200m": "2nd Place",
          "500m": "3rd Place",
        },
      },
      {
        "player_id": "player456",
        "name": "Jane Smith",
        "imgUrl": "https://example.com/player456.png",
        "eventName": "Speed Skating Championship",
        "dob": "2007-05-22",
        "raceCategorywithResult": {
          "100m": "2nd Place",
          "200m": "1st Place",
        },
      },
    ];

    generateCertificates(eventId: "event789", participants: participants);
  }


  Future<void> generateCertificates({
    required String eventId,
    required List<Map<String, dynamic>> participants,
  }) async {
    final String apiUrl = 'http://127.0.0.1:5000/generate_certificates'; // Replace with your server IP

    try {
      // Construct the request payload
      final Map<String, dynamic> requestData = {
        "event_id": eventId,
        "participants": participants,
      };

      // Make POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      // Check response status
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Certificates generated successfully!");

        // Iterate through the response data
        for (var participant in responseData['data']) {
          print("Player ID: ${participant['player_id']}");
          print("Certificate URL: ${participant['certificateUrl']}");
          print("Completion Status: ${participant['completion_status']}");
        }
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> generateCertificate(ResultModel resultModel, String profileImageUrl, String imageUrl, List<Map<String, dynamic>> textFields, pw.Document combinedPdf, String skaterMobileNumber) async {

    // Fetch the background image
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }
    final Uint8List imageData = response.bodyBytes;
    final image = pw.MemoryImage(imageData);

    // Profile image if provided
    pw.Widget? profileWidget;
    if (profileImageUrl.isNotEmpty) {
      final profileResponse = await http.get(Uri.parse(profileImageUrl));
      if (profileResponse.statusCode == 200) {
        final profileImageData = profileResponse.bodyBytes;
        final profileImage = pw.MemoryImage(profileImageData);
        profileWidget = pw.Positioned(
          top: 20,
          right: 20,
          child: pw.Image(profileImage, width: 100, height: 100),
        );
      }
    }

    // QR Code generation
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('certificates/${resultModel.eventId}/${resultModel.eventId}-${resultModel.skaterId}.pdf');
    final String certurl = "https://firebasestorage.googleapis.com/v0/b/sportimsweb.appspot.com/o/certificates%2F${resultModel.eventId}%2F${resultModel.eventId}-${resultModel.skaterId}.pdf?alt=media";

    final qrPainter = QrPainter(
      data: certurl,
      version: QrVersions.auto,
      gapless: true,
    );
    final qrByteData = await qrPainter.toImageData(200);
    final qrBytes = qrByteData!.buffer.asUint8List();
    final qrImage = pw.MemoryImage(qrBytes);

    // Generate the individual PDF document
    final individualPdf = pw.Document();

    // Add content to individual PDF
    individualPdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Stack(
            children: [
              pw.Image(image, fit: pw.BoxFit.cover),
              for (var field in textFields)
                pw.Positioned(
                  left: field['x'],
                  top: field['y'],
                  child: pw.Text(
                    field['text'].replaceAll('\\n', '\n')
                        .replaceAll("{{name}}", resultModel.skaterName)
                        .replaceAll("{{chest_no}}", resultModel.chestNumber)
                        .replaceAll("{{event_name}}", resultModel.eventName)
                        .replaceAll("{{age_category}}", resultModel.ageCategory)
                        .replaceAll("{{skater_category}}", resultModel.skaterCategory)
                        .replaceAll("{{result}}", resultModel.categoryResultModel.map(
                            (result) => '"${result.raceCategory}" : "${result.result}"').join('\n')),
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(field['color']),
                      fontSize: field['fontSize'],
                    ),
                  ),
                ),
              if (profileWidget != null) profileWidget,
              pw.Positioned(
                bottom: 20,
                left: context.page.pageFormat.width / 2,
                child: pw.Image(qrImage, width: 100, height: 100),
              ),
            ],
          );
        },
      ),
    );

    // Add the same page to the combined PDF
    combinedPdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Stack(
            children: [
              pw.Image(image, fit: pw.BoxFit.cover),
              for (var field in textFields)
                pw.Positioned(
                  left: field['x'],
                  top: field['y'],
                  child: pw.Text(
                    field['text'].replaceAll('\\n', '\n')
                        .replaceAll("{{name}}", resultModel.skaterName)
                        .replaceAll("{{chest_no}}", resultModel.chestNumber)
                        .replaceAll("{{event_name}}", resultModel.eventName)
                        .replaceAll("{{age_category}}", resultModel.ageCategory)
                        .replaceAll("{{skater_category}}", resultModel.skaterCategory)
                        .replaceAll("{{result}}", resultModel.categoryResultModel.map(
                            (result) => '"${result.raceCategory}" : "${result.result}"').join('\n')),
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(field['color']),
                      fontSize: field['fontSize'],
                    ),
                  ),
                ),
              if (profileWidget != null) profileWidget,
              pw.Positioned(
                bottom: 20,
                left: context.page.pageFormat.width / 2,
                child: pw.Image(qrImage, width: 100, height: 100),
              ),
            ],
          );
        },
      ),
    );

    // Save the individual PDF to bytes
    final Uint8List individualPdfBytes = await individualPdf.save();

    // Upload the individual PDF to Firebase Storage
    await storageRef.putData(individualPdfBytes);
    final String firebasePdfUrl = await storageRef.getDownloadURL();

    // Update Firebase with the individual certificate URL
    final DatabaseReference userRef = database.ref().child("skaters/$skaterMobileNumber/events/${resultModel.eventId}/certUrl");
    await userRef.set(firebasePdfUrl);

    // // Open the individual PDF in a new browser tab (for web)
    // final blob = html.Blob([individualPdfBytes], 'application/pdf');
    // final url = html.Url.createObjectUrlFromBlob(blob);
    // html.window.open(url, "_blank");
    // html.Url.revokeObjectUrl(url);  // Clean up the blob URL
  }

  String? findResultId(String skaterId, String scheduleId) {
    try {
      for (var schedule in allSchedules) {
        if (schedule.scheduleId == scheduleId) {
          for (var entry in schedule.resultList.asMap().entries) {
            var key = entry.key.toString();
            var result = entry.value;

            if (result.skaterId == skaterId) {
              return key;
            }
          }
        }
      }
    } catch (e) {
      print('Error finding result key for skaterId: $skaterId and scheduleId: $scheduleId. Error: $e');
    }
    return null;
  }

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Event Position Update"),

            ],
          ),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xfffd0000),
                        borderRadius: BorderRadius.circular(10),
                        // border: Border.all(color: Colors.grey),
                      ),
                      child: Text(enablePublish?
                        "Disclaimer: Once participants are published, the action cannot be undone.":"Result Published",
                        style: TextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                    ),

                    Expanded(child: Container()),
                    if(enablePublish)Container(
                      decoration: BoxDecoration(
                        color: Color(0xffdde7f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: (){},
                        icon: Icon(
                          Icons.publish,
                          color: Color(0xff276ad5),
                        ),
                        label: Text(
                          'Publish All',
                          style: TextStyle(
                            color: Color(0xff276ad5),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: 1000,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: PaginatedDataTable(
                        columns: [
                          DataColumn(label: Text('S.No')),
                          DataColumn(label: Text('Chest No')),
                          DataColumn(label: Text('Skater Id')),
                          DataColumn(label: Text('Skater Name')),
                          DataColumn(label: Text('Skater Category')),
                          DataColumn(label: Text('Age Category')),
                          DataColumn(label: Text('Race Category')),
                          DataColumn(label: Text('Result')),
                        ],
                        source: EventScheduleDataSource(
                          tableData: results,
                        ),
                        headingRowHeight: 45,
                        dataRowMinHeight: 14,
                        dataRowMaxHeight: 30,
                        showFirstLastButtons: true,
                        columnSpacing: 8,
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: const [5, 10, 20],
                        onRowsPerPageChanged: (int? value) {
                          setState(() {
                            _rowsPerPage = value ?? PaginatedDataTable.defaultRowsPerPage;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventScheduleDataSource extends DataTableSource {
  final List<ResultModel> tableData;

  EventScheduleDataSource({
    required this.tableData,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= tableData.length) return null;

    final eventSchedule = tableData[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(eventSchedule.chestNumber)),
        DataCell(Text(eventSchedule.skaterId)),
        DataCell(Text(eventSchedule.skaterName)),
        DataCell(Text(eventSchedule.skaterCategory)),
        DataCell(Text(eventSchedule.ageCategory)),
        DataCell(Text(eventSchedule.categoryResultModel.isNotEmpty
            ? eventSchedule.categoryResultModel[0].raceCategory
            : '')),
        DataCell(Text(eventSchedule.categoryResultModel.isNotEmpty
            ? eventSchedule.categoryResultModel[0].result
            : '')),
      ],
    );
  }

  @override
  int get rowCount => tableData.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
