import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'dart:html' as html;
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_database/firebase_database.dart';
import 'package:sport_ims/models/EventScheduleModel.dart';
import 'package:sport_ims/models/ResultModel.dart';

import '../models/EventModel.dart';
import '../models/EventParticipantsModel.dart';

class UpdatePosition extends StatefulWidget {

  EventScheduleModel scheduleModel ;
  EventModel eventModel;

  UpdatePosition({required this.scheduleModel,required this.eventModel});

  @override
  State<UpdatePosition> createState() => _UpdatePositionState();
}

class _UpdatePositionState extends State<UpdatePosition> {
  bool _isSearching = false;
  double _textFieldWidth = 70;

  EventScheduleModel? scheduleModel;
  EventModel? eventModel;
  List<EventParticipantsModel> allSchedules = [];

  List<TextEditingController> h1Controllers = [];
  List<TextEditingController> h2Controllers = [];
  List<TextEditingController> h3Controllers = [];
  List<TextEditingController> sfControllers = [];
  List<TextEditingController> fControllers = [];
  List<ResultModel> results = [];


  List<EventParticipantsModel> tableData = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      eventModel = widget.eventModel;
      scheduleModel = widget.scheduleModel;
      allSchedules = eventModel!.eventParticipants.where((element) => scheduleModel!.participants.join(", ").contains( element!.skaterId)).toList();
      tableData = allSchedules;
      results = scheduleModel!.resultList;

      if(results.length!=0){
        // Initialize controllers for each row
        for (int i = 0; i < tableData.length; i++) {
          h1Controllers.add(TextEditingController(text:results[i].categoryResultModel.first.H1??''));
          h2Controllers.add(TextEditingController(text:results[i].categoryResultModel.first.H2??''));
          h3Controllers.add(TextEditingController(text:results[i].categoryResultModel.first.H3??''));
          sfControllers.add(TextEditingController(text:results[i].categoryResultModel.first.SF??''));
          fControllers.add(TextEditingController(text:results[i].categoryResultModel.first.F??''));
        }
      }
      else{
        for (int i = 0; i < tableData.length; i++) {
          h1Controllers.add(TextEditingController());
          h2Controllers.add(TextEditingController());
          h3Controllers.add(TextEditingController());
          sfControllers.add(TextEditingController());
          fControllers.add(TextEditingController());
        }
      }
    });
  }


// Function to fetch EventModel data from Firebase Realtime Database
  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = [
        'ID', 'Event ID', 'Event Name', 'Schedule ID', 'Schedule Date', 'Schedule Time',
        'Gender', 'Skater Category', 'Age Category', 'Race Category', 'Participants'
      ];
      sheetObject.appendRow(headers);

      for (var eventSchedule in allSchedules) {
        List<String> data = [
          // eventSchedule.id, eventSchedule.eventId, eventSchedule.eventName, eventSchedule.scheduleId,
          // eventSchedule.scheduleDate, eventSchedule.scheduleTime, eventSchedule.gender,
          // eventSchedule.skaterCategory, eventSchedule.ageCategory, eventSchedule.raceCategory,
          // eventSchedule.participants.join(', ')
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'EventScheduleModels.xlsx')
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




  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
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


  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> generateResultsPDFOld(List<EventScheduleModel> schedules) async {
    final pdf = pw.Document();

    for (var schedule in schedules) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Event: ${schedule.eventName}', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Schedule ID: ${schedule.scheduleId}', style: pw.TextStyle(fontSize: 16)),
                // Add more information as needed
                pw.SizedBox(height: 16),
                pw.Text('Results:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Table.fromTextArray(
                  context: context,
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: pw.TextStyle(fontSize: 10),
                  headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
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
                    <String>['S.NO', 'SCHEDULE NO', 'SKATER NAME', 'SKATER CATEGORY', 'GENDER', 'CLUB', 'DISTRICT', 'CHEST NO', 'AGE', 'H1', 'H2', 'H3', 'SF', 'F'],
                    ...schedule.resultList.map(
                          (result) => [
                        (schedule.resultList.indexOf(result) + 1).toString(), // S.NO
                        schedule.id,
                        result.skaterName,
                        schedule.skaterCategory,
                        schedule.gender,
                        "tRICHU tRICHU tRICHU tRICHU tRICHU tRICHU tRICHU tRICHU tRICHU tRICHU ",
                        "tRICHU tRICHU ",
                        result.chestNumber,
                        result.ageCategory,
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).H1,
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).H2,
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).H3,
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).SF,
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).F,
                      ],
                    ),
                  ],
                ),
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

  Future<void> generateResultsPDF(List<EventScheduleModel> schedules) async {
    final pdf = pw.Document();

    // Load the Times New Roman font
    final ttf = pw.Font.timesBold();

    for (var schedule in schedules) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: pw.EdgeInsets.all(5), // Remove page padding
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  color: PdfColor.fromHex('#000000'),  // Black background color
                  child: pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Center(
                      child: pw.Text(
                        'Event: ${schedule.eventName} ${eventModel!.eventDate.toString().substring(0,10)}',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#FFFFFF'),  // White text color
                        ),
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                // pw.Text('Schedule ID: ${schedule.scheduleId}', style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Row(
                  children: [
                    pw.Text('Schedule Date: ${schedule.scheduleDate}   ', style: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Schedule Time: ${schedule.scheduleTime}', style: pw.TextStyle(font: ttf, fontSize: 10, fontWeight: pw.FontWeight.bold)),
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
                  cellStyle: pw.TextStyle(font: ttf,fontSize: 10),
                  headerStyle: pw.TextStyle(font: ttf,fontSize: 10, fontWeight: pw.FontWeight.bold),
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
                    <String>['S.NO', 'SCHEDULE NO', 'SKATER NAME', 'SKATER CATEGORY', 'GENDER', 'CLUB', 'DISTRICT', 'CHEST NO', 'AGE', 'H1', 'H2', 'H3', 'SF', 'F'],
                    ...schedule.resultList.map(
                          (result) => [
                        (schedule.resultList.indexOf(result) + 1).toString(), // S.NO
                        schedule.id,
                        result.skaterName.toUpperCase(),
                        schedule.skaterCategory.toUpperCase(),
                        schedule.gender.toUpperCase(),
                        eventModel!.eventParticipants.firstWhere((e) => e.skaterId==result.skaterId).club.toUpperCase(),
                        eventModel!.eventParticipants.firstWhere((e) => e.skaterId==result.skaterId).district.toUpperCase(),
                        result.chestNumber.toUpperCase(),
                        result.ageCategory.toUpperCase(),
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).H1.toUpperCase(),
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).H2.toUpperCase(),
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).H3.toUpperCase(),
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).SF.toUpperCase(),
                        result.categoryResultModel.firstWhere((element) => element.raceCategory.contains(schedule.raceCategory)).F.toUpperCase(),
                      ],
                    ),

                  ],
                ),
                pw.Container(
                  width: double.infinity,
                  child:pw.Text("For SPORT-IMS",style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.end)
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

  void saveResults() {
    results.clear();

    DatabaseReference db = FirebaseDatabase.instance.ref();

    for (int i = 0; i < tableData.length; i++) {
      final participant = tableData[i];

      print(sfControllers[i].text);

      final categoryResultModel = CategoryResultModel(
        H1: h1Controllers[i].text,
        H2: h2Controllers[i].text,
        H3: h3Controllers[i].text,
        SF: sfControllers[i].text,
        F: fControllers[i].text,
        result: fControllers[i].text, // Add any result calculation logic if needed
        raceCategory: scheduleModel!.raceCategory, // Add appropriate race category
        eventScheduleId: scheduleModel!.id,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final resultModel = ResultModel(
        resultId: participant.skaterId, // Generate or assign an ID
        skaterName: participant.name,
        skaterId: participant.skaterId,
        ageCategory: scheduleModel!.ageCategory,
        skaterCategory: participant.skaterCategory,
        certificateNumber: eventModel!.id+participant.chestNumber, // Add certificate number if needed
        chestNumber: participant.chestNumber,
        eventId: eventModel!.id,
        eventName: eventModel!.eventName,
        certificateUrl: '', // Add certificate URL if needed
        categoryResultModel: [categoryResultModel],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        published: '',
      );

      print(participant.skaterId);

      results.add(resultModel);
      db.child('skaters/${participant.skaterId}/events/${eventModel!.id}/result/categoryResultModel/${(scheduleModel!.raceCategory).replaceAll('-', "").replaceAll('/', "").replaceAll(" ", "")}/').set(categoryResultModel.toJson());

      print(results[0].categoryResultModel[0].H1);

    }

    setState(() {
      scheduleModel!.resultList = results;
    });

    try {

      print("ajdhjkashkd 11111111");

      db.child('events/pastEvents/${eventModel!.id}/eventSchedules/${scheduleModel!.id}/resultList/').set(results.map((e) => e.toJson()));
      print("ajdhjkashkd 2222222");

    }catch(e){
      print("ajdhjkashkd");
    }

    showSuccessDialog("Results saved successfully!");
  }
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text("Event Position Update"),
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
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffdde7f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          generateResultsPDF([scheduleModel!]);                        },
                        icon: Icon(
                          Icons.import_export,
                          color: Color(0xff276ad5),
                        ),
                        label: Text(
                          'Export',
                          style: TextStyle(
                            color: Color(0xff276ad5),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(child: Container()),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffdde7f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          saveResults();
                        },
                        icon: Icon(
                          Icons.save,
                          color: Color(0xff276ad5),
                        ),
                        label: Text(
                          'Save',
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: PaginatedDataTable(

                        columns: [
                          DataColumn(label: Text('S.No')),
                          DataColumn(label: Text('Skater Name')),
                          DataColumn(label: Text('Chest No')),
                          DataColumn(label: Text('H1')),
                          DataColumn(label: Text('H2')),
                          DataColumn(label: Text('H3')),
                          DataColumn(label: Text('SF')),
                          DataColumn(label: Text('F')),
                        ],
                        source: EventScheduleDataSource(
                          tableData: tableData,
                          h1Controllers: h1Controllers,
                          h2Controllers: h2Controllers,
                          h3Controllers: h3Controllers,
                          sfControllers: sfControllers,
                          fControllers: fControllers,
                          showEditDialog: (p0) => {},
                          deleteEventScheduleModel: (p0) => {},
                        ),
                        headingRowHeight: 45,
                        dataRowMinHeight: 14,
                        dataRowMaxHeight: 60,
                        showFirstLastButtons: true,
                        columnSpacing: width/28,
                        rowsPerPage: _rowsPerPage,
                        availableRowsPerPage: [5,10,15],
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
  final List<EventParticipantsModel> tableData;

  final List<TextEditingController> h1Controllers;
  final List<TextEditingController> h2Controllers;
  final List<TextEditingController> h3Controllers;
  final List<TextEditingController> sfControllers;
  final List<TextEditingController> fControllers;
  final Function(EventScheduleModel) showEditDialog;
  final Function(EventScheduleModel) deleteEventScheduleModel;

  EventScheduleDataSource({
    required this.tableData,
    required this.h1Controllers,
    required this.h2Controllers,
    required this.h3Controllers,
    required this.sfControllers,
    required this.fControllers,
    required this.showEditDialog,
    required this.deleteEventScheduleModel,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= tableData.length) return null;

    final eventSchedule = tableData[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text('${index+1}')),
        DataCell(Text(eventSchedule.name)),
        DataCell(Text(eventSchedule.chestNumber)),

        DataCell(
            Container(
              width: 120,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: h1Controllers[index],
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  hintText: "H1",
                  hintStyle: TextStyle(color: Colors.red),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
              ),
            )
        ),
        DataCell(
            Container(
              width: 120,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: h2Controllers[index],
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  hintText: "H2",
                  hintStyle: TextStyle(color: Colors.red),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
              ),
            )
        ),
        DataCell(
            Container(
              width: 120,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: h3Controllers[index],
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  hintText: "H3",
                  hintStyle: TextStyle(color: Colors.red),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
              ),
            )
        ),
        DataCell(
            Container(
              width: 120,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: sfControllers[index],

                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  hintText: "SF",
                  hintStyle: TextStyle(color: Colors.red),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
              ),
            )
        ),
        DataCell(
            Container(
              width: 120,
              padding: EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                controller: fControllers[index],
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(5.5),
                  ),
                  hintText: "F",
                  hintStyle: TextStyle(color: Colors.red),
                  filled: true,
                  fillColor: Colors.blue[50],
                        ),
                      ),
            )
        ),


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
