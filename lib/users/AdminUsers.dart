import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:html' as html;
import 'package:intl/intl.dart';
import 'package:sport_ims/dialog/AddNewAdminDialog.dart';

import '../models/UserCredentialsModel.dart';
import '../utils/Controllers.dart';

class UserCredentialsPage extends StatefulWidget {
  @override
  _UserCredentialsPageState createState() => _UserCredentialsPageState();
}

class _UserCredentialsPageState extends State<UserCredentialsPage> {
  List<UserCredentials> userCredentials = [];
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    fetchUserCredentials();
  }

  Future<void> fetchUserCredentials() async {
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('users');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      final users = snapshot.children.map((e) {
        return UserCredentials.fromJson(Map<String, dynamic>.from(e.value as Map));
      }).toList();

      print(snapshot.value);
      setState(() {
        userCredentials = users.where((element) => element.role=="admin").toList();
      });
    }
  }

  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      List<String> headers = [
        'Username', 'Password', 'Name', 'Mobile Number', 'Role', 'Status', 'Created At', 'Access Log', 'Event ID'
      ];


      sheetObject.appendRow(headers);

      for (var user in userCredentials) {
        List<String> data = [
          user.username ?? '',
          user.password ?? '',
          user.name ?? '',
          user.mobileNumber ?? '',
          user.role ?? '',
          user.status.toString(),
          user.createdAt ?? '',
          user.accessLog?.join(', ') ?? '',
          user.eventId ?? ''
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
        href: 'data:application/octet-stream;charset=utf-8;base64,$content',
      )
        ..setAttribute('download', 'UserCredentials.xlsx')
        ..click();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: SelectableText('Data exported successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: SelectableText('Failed to export data: $e')));
    }
  }

  void addUserDialog() {
    addNewAdmin();
  }

  void addNewAdmin() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: AddNewAdminDialog(
            updateAdmin: (UserCredentials ) {
              fetchUserCredentials();
            },
          ),
        ),
    );
  }

  Future<void> addUserToDatabase(UserCredentials user) async {
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('users/${user.username}/');
    await ref.set(user.toJson());
    fetchUserCredentials();
  }


  void deleteUser(UserCredentials user) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: SelectableText('Delete User'),
          content: SelectableText('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true && user.username!.isNotEmpty && user.username!="") {
      final database = FirebaseDatabase.instance;
      final ref = database.ref().child('users').child(user.username!);
      await ref.remove();
      fetchUserCredentials();
    }
    else if(user.username!.isEmpty || user.username==""){
      showDialog(
        context: context, builder: (context)  {
        return AlertDialog(
          title: SelectableText("Error"),
          content: SelectableText("Error Occured"),
        );
      },);
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: SelectableText("Admin Users Credentials"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.only(top: 10, left: 20,right: 20,bottom: 0), // Add space from top and left
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(

                      decoration: BoxDecoration(
                        color: Color(0xffdde7f9), // Example color, you can change it
                        borderRadius: BorderRadius.circular(10), // Adjust border radius as needed
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          // Handle button press
                          addUserDialog();
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
                    TextButton.icon(
                      onPressed: () async {
                        // Handle button press

                        await exportToExcel();
                      },
                      icon: Icon(
                        Icons.download_for_offline,
                        color: Color(0xff276ad5),
                      ),
                      label: SelectableText(
                        'Export',
                        style: TextStyle(
                          color: Color(0xff276ad5),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: 1000,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child:PaginatedDataTable(
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
                        columns: const [
                          DataColumn(label: SelectableText('S.No')),
                          DataColumn(label: SelectableText('Name')),
                          DataColumn(label: SelectableText('Username')),
                          DataColumn(label: SelectableText('Password')),
                          DataColumn(label: SelectableText('Mobile Number')),
                          DataColumn(label: SelectableText('Role')),
                          DataColumn(label: SelectableText('Delete')),
                        ],
                        source: UserCredentialsDataSource(userCredentials: userCredentials, onDelete: deleteUser,

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
}

class UserCredentialsDataSource extends DataTableSource {
  final List<UserCredentials> userCredentials;
  final Function(UserCredentials) onDelete;

  UserCredentialsDataSource({
    required this.userCredentials,
    required this.onDelete,
  });

  @override
  DataRow getRow(int index) {
    final user = userCredentials[index];
    return DataRow.byIndex(index: index, cells: [
      DataCell(SelectableText((index + 1).toString())),
      DataCell(SelectableText(user.name ?? user.username!)),
      DataCell(SelectableText(user.username ?? '')),
      DataCell(SelectableText(user.password ?? '')),
      DataCell(SelectableText(user.mobileNumber ?? '')),
      DataCell(SelectableText(user.role ?? '')),
      DataCell(IconButton(
        icon: Icon(Icons.delete, size: 16, color: Colors.red),
        onPressed: () => onDelete(user),
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => userCredentials.length;

  @override
  int get selectedRowCount => 0;
}
