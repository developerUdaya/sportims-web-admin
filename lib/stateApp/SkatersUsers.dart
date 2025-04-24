import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/dialog/UserDetailsPage2.dart';
import 'package:sport_ims/dialog/EditUserDialog.dart';
import 'package:sport_ims/models/Constants.dart';

import '../../models/DistrictModel.dart';
import '../../models/StateModel.dart';
import '../../models/UsersModel.dart';
import '../../models/ClubsModel.dart';
import '../dialog/AddNewUserDialog.dart';
import '../utils/Colors.dart';

class Skaters extends StatefulWidget {
  String? stateName;
  Skaters({required this.stateName});

  @override
  State<Skaters> createState() => _SkatersState();
}

class _SkatersState extends State<Skaters> {

  bool _isSearching = false;
  double _textFieldWidth = 70;
  List<Users> allSkaters = [];

  List<Users> tableData = [
   // Users(skaterID: "817ID", name: "Udaya", address: "Chennai,tn", state: "Tamilnadu", district: "Namakkal", school: "kms", schoolAffiliationNumber: "182719289", club: "club001", email: "uday@gmail.com", contactNumber: "9944758128", bloodGroup: "o-ve", gender: "male", skateCategory: "Beginner", aadharBirthCertificateNumber: "8398639849932", dateOfBirth: "25-12-2000", profileImageUrl: "profileImageUrl.", docFileUrl: "docFileUrl", regDate: '', approval: '')
  ];


  //Add new user variables Initialize variables for dropdown selections
  String? selectedState;
  String? selectedDistrict;
  String? selectedClub;
  String? selectedBloodGroup;
  String? selectedGender;
  String? selectedSkate;
  DateTime? selectedDateOfBirth;

  List<Club> clubs = [];
  List<States> states = Constants().states;
  List<District> allDistrict = Constants().districts;
  List<District> district = Constants().districts;
  List<Club> filteredClubs = [];

  @override
  void initState() {
    super.initState();
    _getClubs();
     getUsers();
  }

  Future<void> exportToExcel() async {
    // Show loading dialog
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Add headers
      List<String> headers = [
        'Skater ID', 'Name', 'Address', 'State', 'District', 'School', 'School Affiliation Number', 'Club', 'Email', 'Contact Number',
        'Blood Group', 'Gender', 'Skate Category', 'Aadhar Birth Certificate Number', 'Date of Birth', 'Profile Image URL', 'Doc File URL',
        'Registration Date', 'Approval'
      ];
      sheetObject.appendRow(headers);

      // Add data
      for (var user in allSkaters) {
        List<String> data = [
          user.skaterID, user.name, user.address, user.state, user.district, user.school, user.schoolAffiliationNumber, user.club, user.email,
          user.contactNumber, user.bloodGroup, user.gender, user.skateCategory, user.aadharBirthCertificateNumber, user.dateOfBirth,
          user.profileImageUrl, user.docFileUrl, user.regDate, user.approval
        ];
        sheetObject.appendRow(data);
      }

      // Save the file
      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'SkatersData.xlsx')
        ..click();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported successfully'))
      );
    } catch (e) {
      // Close loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e'))
      );
    }

  }
  Future<void> _getClubs() async {
    List<Club> fetchedClubs = await getClubs();
    setState(() {
      clubs.addAll(fetchedClubs);
      filteredClubs?.addAll(fetchedClubs);
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
      }
    }
    return clubs;
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
      print(2);
      tableData = users.where((element) => element.state.contains(widget.stateName!)).toList();
      allSkaters = users.where((element) => element.state.contains(widget.stateName!)).toList();

      print(3);
    });
  }
  Future<void> showEditDialog(Users user) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUserDialog(user: user, club: clubs, updateUser: updateUser);
      },
    );
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

  Future<String> uploadFileToStorage(String path, String fileName, {bool isWeb = false, html.File? webFile}) async {
    try {
      if (isWeb && webFile != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(webFile);
        await reader.onLoad.first;
        final fileBytes = reader.result as Uint8List;
        final storageRef = FirebaseStorage.instance.ref('uploads/$fileName');
        final uploadTask = storageRef.putData(fileBytes);
        final snapshot = await uploadTask;
        return await snapshot.ref.getDownloadURL();
      } else {
        return '';

      }
    } catch (e) {
      print(e);
      return '';
    }
  }

  void updateUser(Users user){
    setState(() {
      int index = tableData.indexWhere((element) => element.skaterID == user.skaterID);
      if (index != -1) {
        tableData[index] = user;
      }
    });
  }

  void addUser(Users user){

    setState(() {
      tableData.add(user);
    });
  }
  void showSnackBar(String msg){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void addNewUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddNewUserDialog(updateUser: addUser,);
      },
    );
  }

  void updateUserApproval(Users user){

    setState(() {
      int index = tableData.indexWhere((element) => element.skaterID == user.skaterID);
      if (index != -1) {
        tableData[index].approval = "Approved";
      }
    });
  }

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  void showUserDetailsDialog(Users user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserDetailsPage(user: user, updateUserApproval: updateUserApproval,);
      },
    );
  }

  void approveUser(Users user) {
    final ref = FirebaseDatabase.instance.ref('skaters/${user.contactNumber}');
    ref.update({'approval': "Approved"});
  }

  void deleteUser(Users user) async {
    bool shouldDelete = false;

    // Show confirmation dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user? This action cannot be undone.'),
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

    // Show loading screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: CircularProgressIndicator(),
        );
      },
    );


    // Perform deletion
    try {
      final ref = FirebaseDatabase.instance.ref('skaters/${user.contactNumber}');
      await ref.remove();

      setState(() {
        tableData.removeWhere((element) => element.skaterID == user.skaterID);

      });


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('User deleted successfully.'),
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
            content: Text('Failed to delete user. Please try again.'),
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
          title: Text("Skaters"),
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
                    Expanded(
                            child: Container()
                        ), // Add spacing between the button and the search bar
                    AnimatedContainer(
                      duration: Duration(milliseconds: 65),
                      width: _isSearching ? 200 : 0,
                      height: _isSearching ? 35 : 0,
                      padding: _isSearching?EdgeInsets.symmetric(horizontal: 0,vertical: 0):EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: _textFieldWidth,
                              child: CupertinoSearchTextField(
                                onChanged: (value) {
                                  // Handle search query changes
                                  setState(() {
                                    tableData = allSkaters.where((element) =>
                                    element.name.toLowerCase().contains(value.toLowerCase()) ||
                                        element.skaterID.toLowerCase().contains(value.toLowerCase())
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
                          DataColumn(label: Text('S.No')),
                          DataColumn(label: Text('Skater ID')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Club')),
                          DataColumn(label: Text('Reg Date')),
                          DataColumn(label: Text('View')),
                          DataColumn(label: Text('Status')),
                        ],
                        source: MyData(
                          data: tableData,
                          showUserDetailsDialog: showUserDetailsDialog,
                          showEditDialog: showEditDialog,
                          deleteUser: deleteUser,
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



class MyData extends DataTableSource {
  final List<Users> data;
  final Function(Users) showUserDetailsDialog;
  final Function(Users) showEditDialog;
  final Function(Users) deleteUser;

  MyData({
    required this.data,
    required this.showUserDetailsDialog,
    required this.showEditDialog,
    required this.deleteUser
  });

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      print('Invalid index accessed: $index, data length: ${data.length}');
      return null; // or throw an exception if preferred
    }
    final Users user = data[index];
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text((index + 1).toString())),
      DataCell(Text(user.skaterID)),
      DataCell(Text(user.name)),
      DataCell(Text(user.club)),
      DataCell(Text(user.regDate.length>=9?user.regDate.substring(0, 10):_formatDate(DateTime.now()))),
      DataCell(IconButton(
        icon: Icon(Icons.visibility, size: 16, color: Colors.orangeAccent),
        onPressed: () {
          showUserDetailsDialog(user);
        },
      )),

      DataCell(IconButton(
        icon: Icon(
          user.approval != "Approved" ? Icons.thumb_down : Icons.verified,
          size: 16,
          color: user.approval != "Approved" ? Colors.red : Colors.green,
        ),
        onPressed: () {
          // Handle status action
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
  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }
}
