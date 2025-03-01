import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_database/firebase_database.dart';
import 'package:sport_ims/models/EventScheduleModel.dart';

import '../models/EventModel.dart';

import 'AddEventSchedule.dart';
import 'EditEventSchedule.dart';

class EventScheduleData extends StatefulWidget {
  EventModel eventModel;
  EventScheduleData({required this.eventModel});
  @override
  State<EventScheduleData> createState() => _EventScheduleDataState();
}


class _EventScheduleDataState extends State<EventScheduleData> {
  bool _isSearching = false;
  double _textFieldWidth = 70;

  EventModel? eventModel;
  List<EventScheduleModel> allSchedules = [];


  List<EventScheduleModel> tableData = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      eventModel = widget.eventModel;
    });
    getEventScheduleModel(eventModel!.id);
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
          eventSchedule.id, eventSchedule.eventId, eventSchedule.eventName, eventSchedule.scheduleId,
          eventSchedule.scheduleDate, eventSchedule.scheduleTime, eventSchedule.gender,
          eventSchedule.skaterCategory, eventSchedule.ageCategory, eventSchedule.raceCategory,
          eventSchedule.participants.join(', ')
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
        allSchedules = eventSchedules;
      });
    } catch (e) {
      print('Error fetching data from Firebase: $e');
    }
  }


  Future<void> showEditDialog(EventScheduleModel eventSchedule) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditEventSchedule(
          updateEventScheduleModels: updateEventScheduleModel,
          eventScheduleModel: eventSchedule, eventModel: eventModel!, eventScheduleModelList: allSchedules,
        );
      },
    );
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

  void updateEventScheduleModel(EventScheduleModel eventSchedule) {
    setState(() {
      int index = tableData.indexWhere((element) => element.id == eventSchedule.id);
      if (index != -1) {
        tableData[index] = eventSchedule;
      }
    });
  }

  void addEventScheduleModel(EventScheduleModel eventSchedule) {
    setState(() {
      tableData.add(eventSchedule);
      print(eventSchedule.eventName);
    });
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void addNewEventScheduleModelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEventSchedule(updateEventScheduleModels: addEventScheduleModel, eventModel: eventModel!, eventScheduleModelList: allSchedules,);
      },
    );
  }

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  void showEventScheduleModelDetailsDialog(EventScheduleModel eventSchedule) {
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return EditEventScheduleDetails(
    //       updateEventScheduleModels: addEventScheduleModel,
    //       eventScheduleModel: eventSchedule,
    //     );
    //   },
    // );
  }

  void deleteEventScheduleModel(EventScheduleModel eventSchedule) async {
    bool shouldDelete = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete EventScheduleModel'),
          content: Text('Are you sure you want to delete this event schedule? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                shouldDelete = true;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    if (!shouldDelete) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final ref = FirebaseDatabase.instance.ref('eventSchedules/${eventSchedule.id}');
      await ref.remove();

      setState(() {
        tableData.removeWhere((element) => element.id == eventSchedule.id);
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('EventScheduleModel deleted successfully.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to delete event schedule. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Event Schedule"),
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
                      decoration: BoxDecoration(
                        color: Color(0xffdde7f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          addNewEventScheduleModelDialog(context);
                        },
                        icon: Icon(
                          Icons.add_circle,
                          color: Color(0xff276ad5),
                        ),
                        label: Text(
                          'Add',
                          style: TextStyle(
                            color: Color(0xff276ad5),
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffdde7f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          exportToExcel();
                        },
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
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(width: 1000,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: PaginatedDataTable(

                        columns: [
                          DataColumn(label: Text('S.No')),
                          DataColumn(label: Text('Schedule Id')),
                          DataColumn(label: Text('Schedule Date')),
                          DataColumn(label: Text('Schedule Time')),
                          DataColumn(label: Text('Gender')),
                          DataColumn(label: Text('Skater Category')),
                          DataColumn(label: Text('Age Category')),
                          DataColumn(label: Text('Race Category')),
                          DataColumn(label: Text('View')),
                        ],
                        source: EventScheduleDataSource(
                          tableData: tableData,
                          showEditDialog: showEditDialog,
                          deleteEventScheduleModel: deleteEventScheduleModel,
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
  final List<EventScheduleModel> tableData;
  final Function(EventScheduleModel) showEditDialog;
  final Function(EventScheduleModel) deleteEventScheduleModel;

  EventScheduleDataSource({
    required this.tableData,
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
        DataCell(Text(eventSchedule.scheduleId)),
        DataCell(Text(eventSchedule.scheduleDate)),
        DataCell(Text(eventSchedule.scheduleTime)),
        DataCell(Text(eventSchedule.gender)),
        DataCell(Text(eventSchedule.skaterCategory)),
        DataCell(Text(eventSchedule.ageCategory)),
        DataCell(Text(eventSchedule.raceCategory)),
        DataCell(IconButton(
          icon: Icon(Icons.visibility, size: 16, color: Colors.orangeAccent),
          onPressed: () {
            showEditDialog(eventSchedule);
          },
        )),


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
