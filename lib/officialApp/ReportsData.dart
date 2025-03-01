import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:sport_ims/models/EventModel.dart';

import '../models/EventParticipantsModel.dart';
import '../models/EventScheduleModel.dart';
import 'dart:typed_data';

// Add this import with an alias to avoid conflicts
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

class ReportsData extends StatefulWidget {

  EventModel eventModel;


  ReportsData({required this.eventModel});

  @override
  State<ReportsData> createState() => _ReportsDataState();
}

class _ReportsDataState extends State<ReportsData> {

  bool _isSearching = false;
  double _textFieldWidth = 70;
  EventModel? eventModel ;
  List<EventScheduleModel> allReports = [];
  List<EventScheduleModel> tableData = [];
  List<String> events = []; // List of event names
  String? selectedEvent = 'View All';
  DateTime? fromDate;
  DateTime? toDate;

  bool published = false;
  final database = FirebaseDatabase.instance;
  @override
  void initState() {
    super.initState();

    setState(() {
      eventModel = widget.eventModel;
    });

    getEventScheduleModel(eventModel!.id);
    getPublishValue();


  }

  Future<void> getPublishValue() async {
    DataSnapshot publishRef = await database.ref().child('events/pastEvents/${widget.eventModel!.id}/published/').get();

    if(publishRef.exists){
      setState(() {
        published = publishRef.value as String !="Published"  ;
      });
    }else{
      published = false;
    }
  }

  Future<void> getEventScheduleModel(String eventId) async {
    List<EventScheduleModel> eventSchedules = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('events/pastEvents/$eventId/eventSchedules');

    try {
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        print(snapshot.value);

        for (final child in snapshot.children) {
          try {
            EventScheduleModel eventSchedule = EventScheduleModel.fromJson(Map<String, dynamic>.from(child.value as Map));
            eventSchedules.add(eventSchedule);
            print(eventSchedule.eventName);
          } catch (e) {
            print('Error converting child snapshot to EventScheduleModel: $e');
          }
        }
      } else {
        print('No data available.');
      }

      setState(() {
        tableData = eventSchedules;
        allReports = eventSchedules;
      });
    } catch (e) {
      print('Error fetching data from Firebase: $e');
    }
  }

  Future<void> generateResultsPDF(List<EventScheduleModel> schedules) async      {
    final pdf = pw.Document();

    // Load the Times New Roman font
    final ttf = pw.Font.timesBold();

    for(EventScheduleModel schedule in schedules) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: pw.EdgeInsets.all(5), // Remove page padding
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  color: PdfColor.fromHex('#000000'), // Black background color
                  child: pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        'Event: ${schedule.eventName} ${eventModel!.eventDate
                            .toString().substring(0, 10)}',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex(
                              '#FFFFFF'), // White text color
                        ),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Schedule ID: ${schedule.scheduleId}',
                    style: pw.TextStyle(font: ttf,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
                pw.Row(
                    children: [
                      pw.Text('Schedule Date: ${schedule.scheduleDate}   ',
                          style: pw.TextStyle(font: ttf,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text('Schedule Time: ${schedule.scheduleTime}',
                          style: pw.TextStyle(font: ttf,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold)),
                    ]
                ),
                // pw.Text('Gender: ${schedule.gender}', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                // pw.Text('Skater Category: ${schedule.skaterCategory}', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                // pw.Text('Age Category: ${schedule.ageCategory}', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                // pw.Text('Race Category: ${schedule.raceCategory}', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                // pw.SizedBox(height: 16),
                // pw.Text('Participants:', style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Table.fromTextArray(
                  context: context,
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: pw.TextStyle(font: ttf, fontSize: 10),
                  headerStyle: pw.TextStyle(
                      font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold),
                  columnWidths: {
                    0: pw.FlexColumnWidth(1), // S.NO
                    1: pw.FlexColumnWidth(2), // SCHEDULE NO
                    2: pw.FlexColumnWidth(3), // SKATER NAME
                    3: pw.FlexColumnWidth(2), // SKATER CATEGORY
                    4: pw.FlexColumnWidth(2), // GENDER
                    5: pw.FlexColumnWidth(2), // CLUB
                    6: pw.FlexColumnWidth(2), // DISTRICT
                    7: pw.FlexColumnWidth(2), // CHEST NO
                    8: pw.FlexColumnWidth(1), // AGE
                    9: pw.FlexColumnWidth(1), // H1
                    10: pw.FlexColumnWidth(1), // H2
                    11: pw.FlexColumnWidth(1), // H3
                    12: pw.FlexColumnWidth(1), // SF
                    13: pw.FlexColumnWidth(1), // F
                  },
                  data: <List<String>>[
                    <String>[
                      'S.NO',
                      'SCHEDULE NO',
                      'SKATER NAME',
                      'SKATER CATEGORY',
                      'GENDER',
                      'CLUB',
                      'DISTRICT',
                      'CHEST NO',
                      'AGE',
                      'H1',
                      'H2',
                      'H3',
                      'SF',
                      'F'
                    ],
                    ...schedule.resultList.map(
                          (result) =>
                      [
                        (schedule.resultList.indexOf(result) + 1).toString(),
                        // S.NO
                        schedule.scheduleId,
                        result.skaterName.toUpperCase(),
                        schedule.skaterCategory.toUpperCase(),
                        schedule.gender.toUpperCase(),
                        eventModel!
                            .eventParticipants
                            .firstWhere((e) => e.skaterId == result.skaterId)
                            .club
                            .toUpperCase(),
                        eventModel!
                            .eventParticipants
                            .firstWhere((e) => e.skaterId == result.skaterId)
                            .district
                            .toUpperCase(),
                        result.chestNumber.toUpperCase(),
                        result.ageCategory.toUpperCase(),
                        result.categoryResultModel
                            .firstWhere((element) =>
                            element.raceCategory.contains(
                                schedule.raceCategory))
                            .H1
                            .toUpperCase(),
                        result.categoryResultModel
                            .firstWhere((element) =>
                            element.raceCategory.contains(
                                schedule.raceCategory))
                            .H2
                            .toUpperCase(),
                        result.categoryResultModel
                            .firstWhere((element) =>
                            element.raceCategory.contains(
                                schedule.raceCategory))
                            .H3
                            .toUpperCase(),
                        result.categoryResultModel
                            .firstWhere((element) =>
                            element.raceCategory.contains(
                                schedule.raceCategory))
                            .SF
                            .toUpperCase(),
                        result.categoryResultModel
                            .firstWhere((element) =>
                            element.raceCategory.contains(
                                schedule.raceCategory))
                            .F
                            .toUpperCase(),
                      ],
                    ),

                  ],
                ),
                pw.Container(
                    width: double.infinity,
                    child: pw.Text("For SPORT-IMS", style: pw.TextStyle(
                        font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.end)
                )
              ],
            );
          },
        ),
      );
    }


    // Save the PDF as bytes
    final Uint8List pdfBytes = await pdf.save();

    // Convert PDF bytes to base64 string
    final base64String = base64Encode(pdfBytes);

    // Construct HTML content with embedded PDF
    final String htmlContent = '''
    <!DOCTYPE html>
    <html>
    <title>Generated PDF</title>
    <body>
      <embed src="data:application/pdf;base64,$base64String" type="application/pdf" width="100%" height="600px" />
    </body>
    </html>
  ''';

    // Convert the HTML string to a Blob
    final blob = html.Blob([htmlContent], 'text/html');

    // Create a URL for the Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Open the Blob URL in a new tab
    html.window.open(url, '_blank');

    // Revoke the URL to free up resources
    html.Url.revokeObjectUrl(url);
  }


  Future<void> exportToExcelEventSchedules(List<EventScheduleModel> schedules) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers =
      ['S.NO', 'SCHEDULE NO', 'SKATER NAME', 'SKATER CATEGORY', 'GENDER', 'CLUB', 'DISTRICT', 'CHEST NO', 'AGE', 'H1', 'H2', 'H3', 'SF', 'F']
      ;
      sheetObject.appendRow(headers);

      for(EventScheduleModel schedule in schedules) {
        for (var result in schedule.resultList) {
          List<String> data = [
            (schedule.resultList.indexOf(result) + 1).toString(), // S.NO
            schedule.scheduleId,
            result.skaterName.toUpperCase(),
            schedule.skaterCategory.toUpperCase(),
            schedule.gender.toUpperCase(),
            eventModel!
                .eventParticipants
                .firstWhere((e) => e.skaterId == result.skaterId)
                .club
                .toUpperCase(),
            eventModel!
                .eventParticipants
                .firstWhere((e) => e.skaterId == result.skaterId)
                .district
                .toUpperCase(),
            result.chestNumber.toUpperCase(),
            result.ageCategory.toUpperCase(),
            result.categoryResultModel
                .firstWhere((element) =>
                element.raceCategory.contains(schedule.raceCategory))
                .H1
                .toUpperCase(),
            result.categoryResultModel
                .firstWhere((element) =>
                element.raceCategory.contains(schedule.raceCategory))
                .H2
                .toUpperCase(),
            result.categoryResultModel
                .firstWhere((element) =>
                element.raceCategory.contains(schedule.raceCategory))
                .H3
                .toUpperCase(),
            result.categoryResultModel
                .firstWhere((element) =>
                element.raceCategory.contains(schedule.raceCategory))
                .SF
                .toUpperCase(),
            result.categoryResultModel
                .firstWhere((element) =>
                element.raceCategory.contains(schedule.raceCategory))
                .F
                .toUpperCase(),
          ];
          sheetObject.appendRow(data);
        }
      }
      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'Report Data.xlsx')
        ..click();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported successfully'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e'))
      );
    }
  }


  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xffcbdcf7),
        appBar: AppBar(
          title: Text("Event Participants Reports"),
          backgroundColor: Color(0xffb0ccf8),
          // leading: IconButton(
          //     onPressed: (){
          //       Navigator.pop(context);
          //     },
          //     icon:Icon(Icons.arrow_back)
          // ),
        ),
        body: Container(
          color: Color(0xffcbdcf7),
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: 1000,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: PaginatedDataTable(
                      headingRowHeight: 45,
                      dataRowMinHeight: 35,
                      dataRowMaxHeight: 45,
                      showFirstLastButtons: false,
                      columnSpacing: 8,
                      rowsPerPage: 1,
                      columns: [
                        DataColumn(label: Text('S.No')),
                        DataColumn(label: Text('Event Name')),
                        DataColumn(label: Text('Skaters')),
                        DataColumn(label: Text('View')),
                        DataColumn(label: Text('Excel')),
                        DataColumn(label: Text('Certificate')),
                      ],
                      source: EventParticipantsDataSource([eventModel! ],generateResultsPDF,exportToExcelEventSchedules,tableData,context,published),
                      showCheckboxColumn: false,
                      sortAscending: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventParticipantsDataSource extends DataTableSource {
  final List<EventModel> data;
  Function(List<EventScheduleModel>) generatePdf;
  Function(List<EventScheduleModel>) exportToExcel;
  List<EventScheduleModel> schedules;
  BuildContext context;
  bool published;

  EventParticipantsDataSource(this.data, this.generatePdf, this.exportToExcel, this.schedules,this.context,this.published);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final report = data[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index + 1}')),
        DataCell(Text(report.eventName)),
        DataCell(Text(data.first.eventParticipants.length.toString())),
        DataCell(IconButton(
          icon: Icon(Icons.visibility, size: 16, color: Colors.orangeAccent),
          onPressed: () {
            generatePdf(schedules);
          },
        )),
        DataCell(IconButton(
          icon: Icon(Icons.file_copy_outlined, size: 16, color: Colors.teal),
          onPressed: () {
            exportToExcel(schedules);
          },
        )),
        DataCell(IconButton(
          icon: Icon(Icons.file_present, size: 16, color: Colors.red),
          onPressed: () {
            // showEditDialog(eventSchedule);
            if(published){
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Results are not published'),
                      actions: [TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text('Ok'))],
                    );
                  },
              );
            }else{
              fetchAndDownloadAllCertificates(report.id);
            }
          },
        )),
      ],
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;




  Future<void> fetchAndDownloadAllCertificates(String eventID) async {
    try {
      print("Fetching PDF URLs...");
      // Reference to your Firebase Storage folder containing certificates
      final storageRef = FirebaseStorage.instance.ref().child('certificates/$eventID');

      // List all items in the 'certificates/' folder
      final ListResult result = await storageRef.listAll();

      // Extract the download URLs for each item in the folder
      List<String> downloadUrls = [];
      for (var item in result.items) {
        // Get the download URL for each PDF
        final String downloadUrl = await item.getDownloadURL();
        print("Fetched PDF URL: $downloadUrl");
        downloadUrls.add(downloadUrl);
      }

      if (downloadUrls.isNotEmpty) {
        print("Combining PDFs...");
        await fetchAndCombinePDFs(downloadUrls);
        print("PDFs combined successfully.");
      } else {
        print("No PDFs found in the folder.");
      }
    } catch (e) {
      print('Error fetching or combining certificates: $e');
    }
  }

  Future<void> fetchAndCombinePDFs(List<String> pdfUrls) async {
    try {
      // Create a list to hold all the PDF byte data
      List<Uint8List> pdfDataList = [];

      // Fetch each PDF and add its bytes to the list
      for (var url in pdfUrls) {
        final Uint8List? pdfData = await fetchPdfFromUrl(url);
        if (pdfData != null) {
          pdfDataList.add(pdfData);
        } else {
          print("Failed to fetch PDF from: $url");
        }
      }

      if (pdfDataList.isNotEmpty) {
        // Combine the PDFs at the byte level (simplified concatenation)
        Uint8List combinedPdf = combinePdfBytes(pdfDataList);

        // Open the combined PDF in a new browser tab
        final blob = html.Blob([combinedPdf], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, "_blank");
        html.Url.revokeObjectUrl(url);  // Clean up the object URL after opening the tab
      } else {
        print("No PDFs to combine.");
      }
    } catch (e) {
      print('Error fetching or combining PDFs: $e');
    }
  }

  Future<Uint8List?> fetchPdfFromUrl(String url) async {
    try {
      // Fetch the PDF file from the given URL
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Convert the response body to Uint8List
        return response.bodyBytes;
      } else {
        print('Failed to load PDF from $url, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching PDF from $url: $e');
    }
    return null;
  }

// Function to combine PDF bytes (concatenation approach)
  Uint8List combinePdfBytes(List<Uint8List> pdfDataList) {
    // Calculate the total length of the combined PDF
    int totalLength = pdfDataList.fold(0, (sum, bytes) => sum + bytes.length);

    // Create a new byte buffer for the combined PDF
    final combinedPdfBytes = BytesBuilder();

    // Concatenate each PDF byte data into the combined PDF
    for (var pdfData in pdfDataList) {
      combinedPdfBytes.add(pdfData);
    }

    return combinedPdfBytes.toBytes();
  }

}
