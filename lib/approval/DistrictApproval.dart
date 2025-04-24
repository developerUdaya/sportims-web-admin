import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/dialog/AddNewDistrictSecretary.dart';
import 'package:sport_ims/dialog/EditDistrictSecretaryDetails.dart';
import 'dart:html' as html;

import '../dialog/DistrictSecretaryDetails.dart';
import '../models/DistrictSecretaryModel.dart';
import '../utils/Controllers.dart';

class DistrictSecretaryApproval extends StatefulWidget {
  @override
  _DistrictSecretaryApprovalState createState() => _DistrictSecretaryApprovalState();
}

class _DistrictSecretaryApprovalState extends State<DistrictSecretaryApproval> {
  List<DistrictSecretaryModel> tableData = [];
  List<DistrictSecretaryModel> allDistrictSecretaries = [];
  bool _isSearching = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _getDistrictSecretaries();
  }

  Future<void> _getDistrictSecretaries() async {
    List<DistrictSecretaryModel> fetchedSecretaries =
    await getDistrictSecretaries();
    fetchedSecretaries = fetchedSecretaries.where((element) => element.approval!="Approved").toList();
    setState(() {
      tableData.addAll(fetchedSecretaries);
      allDistrictSecretaries.addAll(fetchedSecretaries);
    });
  }

  Future<List<DistrictSecretaryModel>> getDistrictSecretaries() async {
    List<DistrictSecretaryModel> secretaries = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('districtSecretaries');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        DistrictSecretaryModel secretary = DistrictSecretaryModel.fromJson(
            Map<String, dynamic>.from(child.value as Map));
        secretaries.add(secretary);
        print(secretary.name);
      }
    }
    return secretaries;
  }

  void addSecretary(DistrictSecretaryModel secretary) {
    setState(() {
      tableData.add(secretary);
    });
  }

  Future<void> exportToExcel(
      BuildContext context, List<DistrictSecretaryModel> secretaries) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Add headers
      List<String> headers = [
        'ID',
        'Name',
        'Address',
        'Contact Number',
        'Email',
        'Aadhar Number',
        'Document URL',
        'District Name',
        'State Name',
        'Registration Date',
        'Created At',
        'Updated At'
      ];
      sheetObject.appendRow(headers);

      // Add data for each secretary
      for (var secretary in secretaries) {
        List<dynamic> rowData = [
          secretary.id,
          secretary.name,
          secretary.address,
          secretary.contactNumber,
          secretary.email,
          secretary.adharNumber,
          secretary.docUrl,
          secretary.districtName,
          secretary.stateName,
          secretary.regDate,
          secretary.createdAt,
          secretary.updatedAt,
        ];
        sheetObject.appendRow(rowData);
      }

      // Save the file
      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'DistrictSecretariesData.xlsx')
        ..click();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('District Secretaries data exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to export district secretaries data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("District Secretaries Pending Approval"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.all(20),
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
                          addNewSecretaryDialog(context);
                        },
                        icon: Icon(
                          Icons.add_circle,
                          color: Color(0xff276ad5),
                        ),
                        label: Text(
                          'Add',
                          style: TextStyle(
                            color: Color(0xff276ad5),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 65),
                      width: _isSearching ? 200 : 0,
                      height: _isSearching ? 35 : 0,
                      padding: _isSearching
                          ? EdgeInsets.symmetric(horizontal: 0, vertical: 0)
                          : EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: 70,
                              child: CupertinoSearchTextField(
                                onChanged: (value) {
                                  setState(() {
                                    tableData = allDistrictSecretaries
                                        .where((element) =>
                                    (element.name
                                        ?.toLowerCase()
                                        .contains(
                                        value.toLowerCase()) ??
                                        false) ||
                                        (element.districtName
                                            ?.toLowerCase()
                                            .contains(
                                            value.toLowerCase()) ??
                                            false))
                                        .toList();
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
                    if (!_isSearching)
                      TextButton.icon(
                        onPressed: () async {
                          await exportToExcel(context, allDistrictSecretaries);
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
                            _rowsPerPage =
                                value ?? PaginatedDataTable.defaultRowsPerPage;
                          });
                        },
                        columns: const [
                          DataColumn(label: Text('S.No')),
                          DataColumn(label: Text('DS ID')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('District Name')),

                          DataColumn(label: Text('Contact Number')),
                          // DataColumn(label: Text('Email')),
                          DataColumn(label: Text('State Name')),
                          DataColumn(label: Text('Registration Date')),
                          DataColumn(label: Text('View')),
                          DataColumn(label: Text('Edit')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Delete')),
                        ],
                        source: MyData(
                          data: tableData,
                          showDistrictSecretaryDetailsDialog:
                          showDistrictSecretaryDetailsDialog,
                          showEditDialog: editSecretaryDialog,
                          deleteSecretary: deleteSecretary, context: context,
                        ),
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

  void showDistrictSecretaryDetailsDialog(DistrictSecretaryModel secretary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DistrictSecretaryDetailsPage(
          districtSecretary: secretary, updateDistrictSecretaryApproval: updateSecretary,);
      },
    );
  }

  void addNewSecretaryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddNewDistrictSecretaryDialog( updateDistrictSecretary: addSecretary,);
      },
    );
  }

  void editSecretaryDialog(BuildContext context,DistrictSecretaryModel districtSecretaryModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditDistrictSecretaryDialog( updateDistrictSecretary: updateSecretary, districtSecretaryModel: districtSecretaryModel,);
      },
    );
  }

  void updateSecretary(DistrictSecretaryModel secretary) {
    setState(() {
      int index = tableData.indexWhere((element) => element.id == secretary.id);
      if (index != -1) {
        tableData[index] = secretary;
      }
    });
  }

  void addDitsrictSecretary(DistrictSecretaryModel secretary){
    setState(() {
      tableData.add(secretary);
    });
  }

  void deleteSecretary(DistrictSecretaryModel secretary) async {
    bool shouldDelete = false;

    // Show confirmation dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete District Secretary'),
          content: Text(
              'Are you sure you want to delete this district secretary? This action cannot be undone.'),
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

    // Perform deletion
    try {
      final ref =
      FirebaseDatabase.instance.ref('districtSecretaries/${secretary.id}');
      await ref.remove();

      setState(() {
        tableData.removeWhere((element) => element.id == secretary.id);
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('District Secretary deleted successfully.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
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
            content:
            Text('Failed to delete district secretary. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _launchURL(String url) async {
    html.window.open(url, 'new_tab');
  }

  void approveSecretary(DistrictSecretaryModel secretary) {
    final ref =
    FirebaseDatabase.instance.ref('districtSecretaries/${secretary.id}');
    ref.update({'approval': "Approved"});
  }
}

class MyData extends DataTableSource {
  final List<DistrictSecretaryModel> data;
  final Function(DistrictSecretaryModel) showDistrictSecretaryDetailsDialog;
  final Function(BuildContext context,DistrictSecretaryModel) showEditDialog;
  final Function(DistrictSecretaryModel) deleteSecretary;
  final BuildContext context;

  MyData({

    required this.data,
    required this.showDistrictSecretaryDetailsDialog,
    required this.showEditDialog,
    required this.deleteSecretary,
    required this.context
  });

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      return null;
    }
    final DistrictSecretaryModel secretary = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(secretary.id ?? "")),
        DataCell(Text(secretary.name ?? "")),
        DataCell(Text(secretary.districtName ?? "")),
        DataCell(Text(secretary.contactNumber ?? "")),
        // DataCell(Text(secretary.email ?? "")),
        DataCell(Text(secretary.stateName ?? "")),
        DataCell(Text(formatDate(secretary.regDate) ?? "")),
        DataCell(IconButton(
          icon: Icon(Icons.visibility, size: 16, color: Colors.orangeAccent),
          onPressed: () {
            showDistrictSecretaryDetailsDialog(secretary);
          },
        )),
        DataCell(IconButton(
          icon: Icon(Icons.edit, size: 16, color: Colors.blue),
          onPressed: () {
            showEditDialog(context,secretary);
          },
        )),
        DataCell(IconButton(
          icon: Icon(
            secretary.approval != "Approved"
                ? Icons.thumb_down
                : Icons.verified,
            size: 16,
            color: secretary.approval != "Approved" ? Colors.red : Colors.green,
          ),
          onPressed: () {
            // Handle status action
          },
        )),
        DataCell(IconButton(
          icon: Icon(Icons.delete, size: 16, color: Colors.red),
          onPressed: () {
            deleteSecretary(secretary);
          },
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
