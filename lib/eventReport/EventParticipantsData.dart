import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../models/EventParticipantsModel.dart';

class EventParticipantsData extends StatefulWidget {

  List<EventParticipantsModel> eventParticipants;


  EventParticipantsData({required this.eventParticipants});

  @override
  State<EventParticipantsData> createState() => _EventParticipantsDataState();
}

class _EventParticipantsDataState extends State<EventParticipantsData> {
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
    });
  }

  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      List<String> headers = [
        'ID', 'Skater ID', 'Chest Number', 'Name', 'Age', 'DOB', 'Event Name', 'Event ID',
        'Skater Category', 'Race Category', 'Payment Status', 'Payment Amount', 'Payment ID',
        'Payment Order ID', 'Payment Mode', 'Created At'
      ];
      sheetObject.appendRow(headers);

      for (var report in allReports) {
        List<String> data = [
          report.id, report.skaterId, report.chestNumber, report.name, report.age, report.dob,
          report.eventName, report.eventID, report.skaterCategory, report.raceCategory.join(", "),
          report.paymentStatus, report.paymentAmount, report.paymentId, report.paymentOrderId,
          report.paymentMode, report.createdAt
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
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon:Icon(Icons.arrow_back)
          ),
        ),
        body: Container(
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
                                      element.eventName.toLowerCase().contains(value.toLowerCase()) ||
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
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                        width: 20),
                  ),
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
                    flex: 3,
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
                        DataColumn(label: Text('Skater ID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Chest Number')),
                        DataColumn(label: Text('Event Name')),
                        DataColumn(label: Text('Age')),
                        DataColumn(label: Text('DOB')),
                        DataColumn(label: Text('Skater Category')),
                        DataColumn(label: Text('Payment Status')),
                        DataColumn(label: Text('Payment Amount')),
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
        DataCell(Text(report.eventName)),
        DataCell(Text(report.age)),
        DataCell(Text(report.dob)),
        DataCell(Text(report.skaterCategory)),
        DataCell(Text(report.paymentStatus)),
        DataCell(Text(report.paymentAmount)),
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
