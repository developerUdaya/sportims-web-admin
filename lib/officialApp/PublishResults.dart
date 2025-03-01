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
  final database = FirebaseDatabase.instance;
  @override
  void initState() {
    super.initState();
    getEventScheduleModel(widget.eventModel!.id);
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

      const String apiUrl = "http://103.174.10.153:8000/generate_certificates";
  
      try {
        Map<String, dynamic> jsonResults = {
  "users_data": results.map((e) => {
    "name": e.skaterName,
    "eventId": e.eventId,
    "skaterId": e.skaterId,
    "club": allSkaters.firstWhere((element) => element.skaterID == e.skaterId).club,
    "dateOfBirth": e.ageCategory,
    "district": allSkaters.firstWhere((element) => element.skaterID == e.skaterId).district,
    "chestNumber": e.chestNumber,
    "ageGroup": e.ageCategory,
    "gender": allSkaters.firstWhere((element) => element.skaterID == e.skaterId).gender,
    "selected_races": { for (var c in e.categoryResultModel) c.raceCategory: c.result },
    "skate_category": e.skaterCategory,
    "imgUrl": allSkaters.firstWhere((element) => element.skaterID == e.skaterId).profileImageUrl,
    "mobileNumber": allSkaters.firstWhere((element) => element.skaterID == e.skaterId).contactNumber
  }).toList() as List<Map<String, dynamic>>
};

print(jsonResults);

        
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(jsonResults),
        );
        
        if (response.statusCode == 200) {
          debugPrint("Success: ${response.body}");
        } else {
          debugPrint("Failed: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        debugPrint("Error sending request: $e");
      }
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
                      child: Text(
                        "Disclaimer: Once participants are published, the action cannot be undone.",
                        style: TextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                    ),

                    Expanded(child: Container()),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffdde7f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: (){
                          publishAllParticipants();

                        },
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
