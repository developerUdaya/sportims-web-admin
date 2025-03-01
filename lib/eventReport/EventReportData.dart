import 'dart:collection';
import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/eventReport/EventParticipantsData.dart';

import '../models/EventModel.dart';
import '../models/EventParticipantsModel.dart';

class EventReportData extends StatefulWidget {
  const EventReportData({super.key});

  @override
  State<EventReportData> createState() => _EventReportDataState();
}

class _EventReportDataState extends State<EventReportData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RightSide(),
    );
  }
}

class RightSide extends StatefulWidget {
  @override
  State<RightSide> createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  bool _isSearching = false;
  double _textFieldWidth = 70;
  List<EventModel> allReports = [];
  List<EventModel> tableData = [];
  List<String> events = []; // List of event names
  String? selectedEvent = 'View All';
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    getEventModels();
  }

  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      List<String> headers = [
        'ID', 'Event Name', 'Place', 'Date', 'No of Participants', 'Participants'
      ];
      sheetObject.appendRow(headers);

      for (var report in allReports) {
        List<String> data = [
          report.id, report.eventName, report.place, report.eventDate.toString().substring(0,10), report.eventParticipants.length.toString(), report.eventParticipants.map((e) => e.skaterId).toList().join(", ")
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'EventModels.xlsx')
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

  Future<void> getEventModels() async {
    // Show loading dialog
    print("jjhhj");
    List<EventModel> events = [];
    try{
      final database = FirebaseDatabase.instance;
      final ref = database.ref().child('events/pastEvents');
      // Fetch the data once using a single await call
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          // Convert each child snapshot to a Club object
          EventModel event = EventModel.fromJson(Map<String, dynamic>.from(child.value as Map));
          if(!event.deleteStatus) {
            events.add(event);
          }

          print('length : ${event.eventParticipants.length}');
        }
      } else {
        print('No data available.');
      }


      setState(() {
        print(2);
        tableData = events;
        allReports = events;

        print(3);
      });
    }catch(e){
      print(e.toString());
    }
  }


  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  void filterByEvent(String? eventName) {
    setState(() {
      if (eventName == 'View All') {
        tableData = allReports;
      } else {
        tableData = allReports.where((report) => report.eventName == eventName).toList();
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isFromDate ? fromDate : toDate)) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
        filterByDateRange();
      });
    }
  }

  void filterByDateRange() {
    if (fromDate != null && toDate != null) {
      setState(() {
        tableData = allReports.where((report) {
          DateTime reportDate = report.eventDate;
          return reportDate.isAfter(fromDate!) && reportDate.isBefore(toDate!);
        }).toList();
      });
    }
  }

  Future<void> showParticipantsDialog(List<EventParticipantsModel> eventParticipants) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventParticipantsData(eventParticipants: eventParticipants, );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Event Participants Reports"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        child: Expanded(
                            child: Container())), // Add spacing between the button and the search bar
                    AnimatedContainer(
                      duration: Duration(milliseconds: 65),
                      width: _isSearching ? 200 : 0,
                      height: _isSearching ? 35 : 0,
                      padding: _isSearching ? EdgeInsets.symmetric(horizontal: 0, vertical: 0) : EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: _textFieldWidth,
                              child: CupertinoSearchTextField(
                                onChanged: (value) {
                                  // Handle search query changes
                                  setState(() {
                                    tableData = allReports.where((element) =>
                                    element.eventName.toLowerCase().contains(value.toLowerCase()) ||
                                        element.id.toLowerCase().contains(value.toLowerCase()) ||
                                        element.place.toLowerCase().contains(value.toLowerCase())
                                    ).toList();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                    ),
                    if (!_isSearching) TextButton.icon(
                      onPressed: () async {
                        // Handle button press
                        await exportToExcel();
                      },
                      icon: Icon(
                        Icons.download_for_offline,
                        color: Color(0xff276ad5),
                      ),
                      label: Text(
                        'Export',
                        style: TextStyle(
                          color: Color(0xff276ad5),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'From Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () {
                          _selectDate(context, true);
                        },
                        controller: TextEditingController(
                          text: fromDate != null
                              ? DateFormat('yyyy-MM-dd').format(fromDate!)
                              : '',
                        ),
                      ),
                    ),
                    SizedBox(
                        width: 20),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'To Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () {
                          _selectDate(context, false);
                        },
                        controller: TextEditingController(
                          text: toDate != null
                              ? DateFormat('yyyy-MM-dd').format(toDate!)
                              : '',
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                          width: 20),
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
                        columns: [
                          DataColumn(label: Text('S.No')),
                          DataColumn(label: Text('Event Name')),
                          DataColumn(label: Text('Place')),
                          DataColumn(label: Text('Event Date')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('No of Participants')),
                          DataColumn(label: Text('View Participants'))
                        ],
                        source: EventModelDataSource(data: tableData,showParticipantsDialog: showParticipantsDialog),
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
      ),
    );
  }
}

class EventModelDataSource extends DataTableSource {
  final List<EventModel> data;
  Function(List<EventParticipantsModel>) showParticipantsDialog;

  EventModelDataSource({ required this.data, required this.showParticipantsDialog});

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
        DataCell(
            SizedBox(
              width: 120,
              child: Text(
                  report.eventName,
                  overflow: TextOverflow.ellipsis,
              )
          )
        ),
        DataCell(
            SizedBox(
                width: 120,
                child: Text(
                    report.place,
                    overflow: TextOverflow.ellipsis,
                )
            )
        ),
        DataCell(Text(report.eventDate.toString().substring(0,10))),
        DataCell(Text(getEventStatus(report.eventDate),style:TextStyle(color: Colors.red))),//Event Status
        DataCell(Center(child: Text(report.eventParticipants.length.toString()))),
        DataCell(Center(
    child:Transform.scale(
    scale: 0.7, // Adjust the scale value to make the switch smaller
    child: IconButton(
            icon: Icon(Icons.visibility,color: Colors.orange,),
            onPressed: (){
              showParticipantsDialog(report.eventParticipants);
            },
          ),
        )))
      ],
    );
  }

  String getEventStatus(DateTime eventDate) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    DateTime twoDaysAhead = DateTime(now.year, now.month, now.day + 2);

    // Check if event date is today
    if (eventDate.year == today.year && eventDate.month == today.month && eventDate.day == today.day) {
      return 'Live';
    }
    // Check if event date is tomorrow
    else if (eventDate.year == tomorrow.year && eventDate.month == tomorrow.month && eventDate.day == tomorrow.day) {
      return 'Tomorrow';
    }
    // Check if event date is 2 days ahead or more
    else if (eventDate.isAfter(twoDaysAhead) || eventDate.difference(now).inDays > 2) {
      return '${eventDate.difference(now).inDays} Days Left';
    }
    // Assume event date is in the past, so it's ended
    else {
      return 'Event Ended';
    }
  }
  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

