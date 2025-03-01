import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../models/EventParticipantsModel.dart';

class ParticipantsData extends StatefulWidget {

  List<EventParticipantsModel> eventParticipants;


  ParticipantsData({required this.eventParticipants});

  @override
  State<ParticipantsData> createState() => _ParticipantsDataState();
}

class _ParticipantsDataState extends State<ParticipantsData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RightSide(eventParticipants: widget.eventParticipants,),
    );
  }
}

class RightSide extends StatefulWidget {
  List<EventParticipantsModel> eventParticipants;
  RightSide({required this.eventParticipants});

  @override
  State<RightSide> createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  bool _isSearching = false;
  double _textFieldWidth = 70;
  List<EventParticipantsModel> allReports = [];
  List<EventParticipantsModel> tableData = [];
  List<String> events = []; // List of event names
  String? selectedEvent = 'View All';
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    setState(() {
      tableData = widget.eventParticipants;
      allReports = widget.eventParticipants;
    });
  }

  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      List<String> headers = [
         'Skater ID', 'Name', 'Chest Number',
         'Age', 'Club', 'Event Name',
         'Skater Category','Race Category',
        'District', 'State'
      ];
      sheetObject.appendRow(headers);

      for (var report in allReports) {
        List<String> data = [
          report.skaterId, report.name, report.chestNumber,
          report.age, report.club, report.eventName,
          report.skaterCategory, report.raceCategory.join(", "),
          report.district, report.state,
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'EventParticipants.xlsx')
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
          DateTime reportDate = DateTime.parse(report.createdAt);
          return reportDate.isAfter(fromDate!) && reportDate.isBefore(toDate!);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Event Participants Reports"),
          backgroundColor: Color(0xffb0ccf8),
          // leading: IconButton(
          //   onPressed: (){
          //     Navigator.pop(context);
          //   },
          //   icon:Icon(Icons.arrow_back)
          // ),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
            child: Column(
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
                                    element.name.toLowerCase().contains(value.toLowerCase()) ||
                                        element.club.toLowerCase().contains(value.toLowerCase()) ||
                                        element.skaterCategory.toLowerCase().contains(value.toLowerCase()) ||
                                        element.raceCategory.join(', ').toLowerCase().contains(value.toLowerCase()) ||
                                        element.chestNumber.toLowerCase().contains(value.toLowerCase()) ||
                                        element.skaterId.toLowerCase().contains(value.toLowerCase())
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
                          DataColumn(label: Text('Skater ID')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Chest Number')),
                          DataColumn(label: Text('Age')),
                          DataColumn(label: Text('Club')),
                          DataColumn(label: Text('Skater Category')),
                          DataColumn(label: Text('Race Category')),
                          DataColumn(label: Text('District')),
                          DataColumn(label: Text('State')),
                        ],
                        source: EventParticipantsDataSource(tableData),
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

class EventParticipantsDataSource extends DataTableSource {
  final List<EventParticipantsModel> data;

  EventParticipantsDataSource(this.data);

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
        DataCell(Text(report.skaterId)),
        DataCell(Text(report.name)),
        DataCell(Text(report.chestNumber)),
        DataCell(Text(report.age)),
        DataCell(Text(report.club)),
        DataCell(Text(report.skaterCategory)),
        DataCell(Text(report.raceCategory.join(","))),
        DataCell(Text(report.district)),
        DataCell(Text(report.state)),
      ],
    );
  }

  @override
  int get rowCount => data.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
