import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sport_ims/dialog/AddNewClubDialog.dart';
import 'package:sport_ims/dialog/ClubDetailsPage.dart';
import 'package:sport_ims/dialog/EditClubDetails.dart';

import '../models/ClubsModel.dart';
import '../models/Constants.dart';

class ClubsData extends StatefulWidget {
  @override
  _ClubsDataState createState() => _ClubsDataState();
}

class _ClubsDataState extends State<ClubsData> {
  List<Club> tableData = [];
  List<Club> allClubs = [];
  bool _isSearching = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    _getClubs();
    // Fetch data from Firebase and populate tableData for clubs
  }

  void deleteClub(Club user) async {
    bool shouldDelete = false;

    // Show confirmation dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Club'),
          content: Text('Are you sure you want to delete this club? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                shouldDelete = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (!shouldDelete) return;




    // Perform deletion
    try {
      final ref = FirebaseDatabase.instance.ref('clubs/${user.id}');
      await ref.remove();

      setState(() {
        tableData.removeWhere((element) => element.id == user.id);

      });


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Club deleted successfully.'),
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
            content: Text('Failed to delete user. Please try again.'),
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

  Future<void> _getClubs() async {
    List<Club> fetchedClubs = await getClubs();
    setState(() {
      tableData.addAll(fetchedClubs);
      allClubs.addAll(fetchedClubs);

    });
  }

  Future<List<Club>> getClubs() async {
    List<Club> clubs = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('clubs');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        Club club = Club.fromJson(Map<String, dynamic>.from(child.value as Map));
        clubs.add(club);
        print(club.clubName);
      }
    }
    return clubs;
  }

  void addClub(Club club){
    setState(() {
      tableData.add(club);
    });
  }


  Future<void> exportToExcel(BuildContext context, List<Club> clubs) async {
    // Show loading dialog

    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Add headers
      List<String> headers = [
        'ID', 'Club Name', 'Address', 'District', 'State', 'Contact Number', 'Email',
        'Coach Name', 'Master Name', 'Registration Date', 'Approval'
      ];
      sheetObject.appendRow(headers);

      // Add data for each club
      for (var club in clubs) {
        List<dynamic> rowData = [
          club.id,
          club.clubName,
          club.address,
          club.district,
          club.state,
          club.contactNumber,
          club.email,
          club.coachName,
          club.masterName,
          club.regDate,
          club.approval,
        ];
        sheetObject.appendRow(rowData);
      }

      // Save the file
      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'ClubsData.xlsx')
        ..click();

      // Show success message

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Clubs data exported successfully')),
      );
    } catch (e) {
      // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export clubs data: $e')),
      );
    }
  }

  void showEditDialog(Club club) {
    // Controllers for text fields

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditClubDialog(club: club, updateClub: updateClub);
      },
    );
  }

  void addNewClubDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddNewClubDialog(updateClubs: addClub,);
      },
    );
  }

  void updateClub(Club user){
    setState(() {
      int index = tableData.indexWhere((element) => element.id == user.id);
      if (index != -1) {
        tableData[index] = user;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Clubs"),
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
                          addNewClubDialog(context);
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
                    Container(
                        child: Expanded(
                            child: Container())), // Add spacing between the button and the search bar
                    AnimatedContainer(
                      duration: Duration(milliseconds: 65),
                      width: _isSearching ? 200 : 0,
                      height: _isSearching ? 35 : 0,
                      padding: _isSearching?EdgeInsets.symmetric(horizontal: 0,vertical: 0):EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: 70,
                              child: CupertinoSearchTextField(
                                onChanged: (value) {
                                  // Handle search query changes
                                  setState(() {
                                    tableData = allClubs.where((element) =>
                                    (element.clubName?.toLowerCase().contains(value.toLowerCase()) ?? false) ||
                                        (element.address?.toLowerCase().contains(value.toLowerCase()) ?? false)
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
                    if(!_isSearching)TextButton.icon(
                      onPressed: () async {
                        // Handle button press
                        await exportToExcel(context, allClubs);
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
                    )       ],
                ),
                SizedBox
                  (height: 20),
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
                        columns: const [
                          DataColumn(label: Text('S.No')),
                          DataColumn(label: Text('Club ID')),
                          DataColumn(label: Text('Club Name')),
                          DataColumn(label: Text('Address')),
                          DataColumn(label: Text('District')),
                          DataColumn(label: Text('State')),
                          DataColumn(label: Text('Contact Number')),
                          DataColumn(label: Text('View')),
                          DataColumn(label: Text('Edit')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Delete')),
                        ],
                        source: MyData(
                          data: tableData,
                          showClubDetailsDialog: showClubDetailsDialog,
                          showEditDialog: showEditDialog, deleteClub: deleteClub,
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

  void showClubDetailsDialog(Club club) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClubDetailsPage(club: club, updateClubApproval: updateClub);
      },
    );
  }

  Future<void> _launchURL(String url) async {
    html.window.open(url, 'new_tab');
  }

  void approveClub(Club club) {
    final ref = FirebaseDatabase.instance.ref('clubs/${club.contactNumber}');
    ref.update({'approval': "Approved"});
  }
}

class MyData extends DataTableSource {
  final List<Club> data;
  final Function(Club) showClubDetailsDialog;
  final Function(Club) showEditDialog;
  final Function(Club) deleteClub;

  MyData({
    required this.data,
    required this.showClubDetailsDialog,
    required this.showEditDialog,
    required this.deleteClub
  });

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      return null;
    }
    final Club club = data[index];
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text((index + 1).toString())),
      
      DataCell(Container(
          width: 150,
          child: Text(club.id ?? "",style: TextStyle(overflow: TextOverflow.ellipsis),))
      ),
      DataCell(Container(
          width: 150,
          child: Text(club.clubName ?? "",style: TextStyle(overflow: TextOverflow.ellipsis),))
      ),
      DataCell(Container(
        width: 150,
          child: Text(club.address ?? "",style: TextStyle(overflow: TextOverflow.ellipsis),))
      ),
      DataCell(Text(club.district ?? "")),
      DataCell(Text(club.state ?? "")),
      DataCell(Text(club.contactNumber ?? "")),
      DataCell(IconButton(
        icon: Icon(Icons.visibility, size: 16, color: Colors.orangeAccent),
        onPressed: () {
          showClubDetailsDialog(club);
        },
      )),
      DataCell(IconButton(
        icon: Icon(Icons.edit, size: 16, color: Colors.blue),
        onPressed: () {
          showEditDialog(club);
        },
      )),
      DataCell(IconButton(
        icon: Icon(
          club.approval != "Approved" ? Icons.thumb_down : Icons.verified,
          size: 16,
          color: club.approval != "Approved" ? Colors.red : Colors.green,
        ),
        onPressed: () {
          // Handle status action
        },
      )),
      DataCell(IconButton(
        icon: Icon(Icons.delete, size: 16, color: Colors.red),
        onPressed: () {
          // Handle delete action
          deleteClub(club);
        },
      )),
    ]);
  }


  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
