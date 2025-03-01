import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/models/PaymentReportModel.dart';
import 'package:sport_ims/utils/Controllers.dart';

class PaymentReportData extends StatefulWidget {
  const PaymentReportData({super.key});

  @override
  State<PaymentReportData> createState() => _PaymentReportDataState();
}

class _PaymentReportDataState extends State<PaymentReportData> {
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
  List<PaymentReport> allReports = [];
  List<PaymentReport> tableData = [];
  List<String> events = []; // List of event names
  String? selectedEvent = 'View All';
  DateTime? fromDate;
  DateTime? toDate;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getPaymentReports();
  }

  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      List<String> headers = [
        'ID', 'Event Name', 'Skater Name', 'Order ID', 'Payment Ref ID', 'Amount', 'Date Time', 'Payment Mode', 'Payment Status'
      ];
      sheetObject.appendRow(headers);

      for (var report in allReports) {
        List<String> data = [
          report.id, report.eventName, report.skaterName, report.orderId, report.paymentRefId, report.amount, report.dateTime, report.paymentMode, report.paymentStatus
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'PaymentReports.xlsx')
        ..click();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Data exported successfully'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Failed to export data: $e'))
      );
    }
  }

  Future<void> getPaymentReports() async {
    List<PaymentReport> reports = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('paymentReports');

    try {
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          try {
            PaymentReport report = PaymentReport.fromJson(Map<String, dynamic>.from(child.value as Map));
            reports.add(report);
            if (!events.contains(report.eventName)) {
              events.add(report.eventName); // Collect unique event names
            }
          } catch (e) {
            print('Error converting child snapshot to PaymentReport: $e');
          }
        }
      } else {
        print('No data available.');
      }

      setState(() {
        tableData = reports;
        allReports = reports;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching data from Firebase: $e');
      setState(() {
        _loading = false;
      });
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
          DateTime reportDate = DateTime.parse(report.dateTime);
          return reportDate.isAfter(fromDate!) && reportDate.isBefore(toDate!.add(const Duration(days: 1)));
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),"Payment Reports"),
          backgroundColor: const Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: const Color(0xffcbdcf7),
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        child: Expanded(
                            child: Container())), // Add spacing between the button and the search bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 65),
                      width: _isSearching ? 200 : 0,
                      height: _isSearching ? 35 : 0,
                      padding: _isSearching ? const EdgeInsets.symmetric(horizontal: 0, vertical: 0) : const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                                    element.skaterName.toLowerCase().contains(value.toLowerCase()) ||
                                        element.orderId.toLowerCase().contains(value.toLowerCase())
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
                      icon: const Icon(Icons.search),
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
                      icon: const Icon(
                        Icons.download_for_offline,
                        color: Color(0xff276ad5),
                      ),
                      label: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),
                        'Export',
                        style: const TextStyle(
                          color: Color(0xff276ad5),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child:DropdownButtonFormField<String>(
                        value: selectedEvent,
                        onChanged: (newValue) {
                          setState(() {
                            selectedEvent = newValue;
                            filterByEvent(selectedEvent);
                          });
                        },
                        items: ['View All', ...events].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),value),
                          );
                        }).toList(),
                        decoration: const InputDecoration(labelText: 'Select Event'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an event';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'From Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () => _selectDate(context, true),
                        controller: TextEditingController(
                          text: fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'To Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () => _selectDate(context, false),
                        controller: TextEditingController(
                          text: toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : '',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                          DataColumn(label: SizedBox(width: 50, child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'No'))),
                          DataColumn(label: SizedBox(width: 150, child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Event Name'))),
                          DataColumn(label: SizedBox(width: 120, child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Skater Name'))),
                          // DataColumn(label: SizedBox(width: 100, child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Order ID'))),
                          DataColumn(label: SizedBox(width: 150, child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Payment Ref ID'))),
                          DataColumn(label: SizedBox(width: 100, child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Amount'))),
                          DataColumn(label: SizedBox(width: 150, child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Date Time'))),
                          DataColumn(label: SizedBox(width: 120, child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Payment Status'))),
                          DataColumn(label: SizedBox(width: 120, child: SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'Payment Mode'))),

                        ],
                        source: PaymentReportDataSource(tableData),
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

class PaymentReportDataSource extends DataTableSource {
  final List<PaymentReport> data;

  PaymentReportDataSource(this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return null;
    }

    final report = data[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),'${index + 1}')),
        DataCell(Container(
            width: 120,
            child: Text(
                report.eventName,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis
                ),
            )
          )
        ),
        DataCell(SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),report.skaterName)),
        // DataCell(SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),report.orderId)),
        DataCell(SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),report.paymentRefId)),
        DataCell(SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),report.amount)),
        DataCell(Text(formatDate(report.dateTime))),
        DataCell(SelectableText(  onTap: () {},  toolbarOptions: const ToolbarOptions(copy: true),report.paymentStatus)),
        DataCell(Text(report.paymentMode)),

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
