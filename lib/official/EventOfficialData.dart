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
import 'package:sport_ims/models/Constants.dart';
import 'package:sport_ims/models/EventOfficialModel.dart';
import 'package:sport_ims/official/AddEventOfficial.dart';
import 'package:sport_ims/official/EditEventOfficial.dart';

import '../utils/Widgets.dart';


class EventOfficialData extends StatefulWidget {
  const EventOfficialData({super.key});

  @override
  State<EventOfficialData> createState() => _EventOfficialDataState();
}

class _EventOfficialDataState extends State<EventOfficialData> {
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
  List<EventOfficialModel> allSkaters = [];

  List<EventOfficialModel> tableData = [
    // EventOfficialModel(skaterID: "817ID", name: "Udaya", address: "Chennai,tn", state: "Tamilnadu", district: "Namakkal", school: "kms", schoolAffiliationNumber: "182719289", club: "club001", email: "uday@gmail.com", contactNumber: "9944758128", bloodGroup: "o-ve", gender: "male", skateCategory: "Beginner", aadharBirthCertificateNumber: "8398639849932", dateOfBirth: "25-12-2000", profileImageUrl: "profileImageUrl.", docFileUrl: "docFileUrl", regDate: '', approval: '')
  ];


  //Add new eventOfficial variables Initialize variables for dropdown selections
  String? selectedState;
  String? selectedDistrict;
  String? selectedClub;
  String? selectedBloodGroup;
  String? selectedGender;
  String? selectedSkate;
  DateTime? selectedDateOfBirth;


  @override
  void initState() {
    super.initState();
    getEventOfficialModel();
  }

  Future<void> exportToExcel() async {
    // Show loading dialog
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Add headers
      List<String> headers = [
        'ID', 'Name', 'User Name', 'Password', 'Event Id', 'Event Name','Registration Date', 'Updated At','Content','Certificate Url'
      ];
      sheetObject.appendRow(headers);

      // Add data
      for (var eventOfficial in allSkaters) {
        List<String> data = [
          eventOfficial.id, eventOfficial.officialName, eventOfficial.userName, eventOfficial.password, eventOfficial.eventId, eventOfficial.eventName, eventOfficial.createdAt, eventOfficial.updatedAt, eventOfficial.content, eventOfficial.imgUrl
        ];
        sheetObject.appendRow(data);
      }

      // Save the file
      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'EventOfficialModels.xlsx')
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



  Future<void> getEventOfficialModel() async {
    // Show loading dialog
    List<EventOfficialModel> eventOfficials = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('eventOfficials');

    // Fetch the data once using a single await call
    try {
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          try {
            // Convert each child snapshot to an EventOfficialModel object
            EventOfficialModel eventOfficial = EventOfficialModel.fromJson(Map<String, dynamic>.from(child.value as Map));
            if(eventOfficial.deleteStatus!=true){
              eventOfficials.add(eventOfficial);
            }
            print(eventOfficial.officialName);
          } catch (e) {
            print('Error converting child snapshot to EventOfficialModel: $e');
          }
        }
      } else {
        print('No data available.');
      }

      setState(() {
        print(2);
        tableData = eventOfficials;
        allSkaters = eventOfficials;
        print(3);
      });
    } catch (e) {
      print('Error fetching data from Firebase: $e');
    }
  }
  Future<void> showEditDialog(EventOfficialModel eventOfficial) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditEventOfficial( updateEventOfficialModels: addEventOfficialModel, eventOfficialModel: eventOfficial,);
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


  void updateEventOfficialModel(EventOfficialModel eventOfficial){
    setState(() {
      int index = tableData.indexWhere((element) => element.id == eventOfficial.id);
      if (index != -1) {
        tableData[index] = eventOfficial;
      }
    });
  }

  void addEventOfficialModel(EventOfficialModel eventOfficial){

    setState(() {
      tableData.add(eventOfficial);
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

  void addNewEventOfficialModelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddEventOfficial( updateEventOfficialModels: addEventOfficialModel,);
      },
    );
  }

  // void updateEventOfficialModelApproval(EventOfficialModel eventOfficial){
  //
  //   setState(() {
  //     int index = tableData.indexWhere((element) => element.id == eventOfficial.id);
  //     if (index != -1) {
  //       tableData[index].approval = "Approved";
  //     }
  //   });
  // }

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  void showEventOfficialModelDetailsDialog(EventOfficialModel eventOfficial) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditEventOfficial( updateEventOfficialModels: addEventOfficialModel, eventOfficialModel: eventOfficial,);
      },
    );
  }

  void approveEventOfficialModel(EventOfficialModel eventOfficial) {
    final ref = FirebaseDatabase.instance.ref('eventOfficials/${eventOfficial.id}');
    ref.update({'approval': "Approved"});
  }

  void changeCertificateStatus(EventOfficialModel eventOfficial,bool cetificateStatus) {
    final ref = FirebaseDatabase.instance.ref('eventOfficials/${eventOfficial.id}');
    ref.update({'cetificateStatus': cetificateStatus});

    setState(() {
      int index = tableData.indexWhere((element) => element.id.contains(eventOfficial.id));
      tableData[index].cetificateStatus = cetificateStatus;
    });
  }

  void deleteEventOfficialModel(EventOfficialModel eventOfficial) async {
    bool shouldDelete = false;

    // Show confirmation dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete EventOfficialModel'),
          content: Text('Are you sure you want to delete this eventOfficial? This action cannot be undone.'),
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
      final ref = FirebaseDatabase.instance.ref('eventOfficials/${eventOfficial.id}/deleteStatus/');
      await ref.set(true);

      final userRef = FirebaseDatabase.instance.ref('users/${eventOfficial.userName}');
      await userRef.remove();

      setState(() {
        tableData.removeWhere((element) => element.id == eventOfficial.id);

      });


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('EventOfficialModel deleted successfully.'),
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
            content: Text('Failed to delete eventOfficial. Please try again.'),
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
          title: Text("Event Official"),
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
                          addNewEventOfficialModelDialog(context);
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
                              width: _textFieldWidth,
                              child: CupertinoSearchTextField(
                                onChanged: (value) {
                                  // Handle search query changes
                                  setState(() {
                                    tableData = allSkaters.where((element) =>
                                    element.officialName.toLowerCase().contains(value.toLowerCase()) ||
                                        element.userName.toLowerCase().contains(value.toLowerCase()) ||
                                        element.eventId.toLowerCase().contains(value.toLowerCase()) ||
                                        element.eventName.toLowerCase().contains(value.toLowerCase())
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
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('User Name')),
                          DataColumn(label: Text('Event Id')),
                          DataColumn(label: Text('Event Name')),
                          DataColumn(label: Text('View')),
                          DataColumn(label: Text('Edit')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Delete')),
                        ],
                        source: MyData(
                          data: tableData,
                          showEventOfficialModelDetailsDialog: showEventOfficialModelDetailsDialog,
                          showEditDialog: showEditDialog,
                          deleteEventOfficialModel: deleteEventOfficialModel, changeCertificateStatus: changeCertificateStatus,
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
  final List<EventOfficialModel> data;
  final Function(EventOfficialModel) showEventOfficialModelDetailsDialog;
  final Function(EventOfficialModel) showEditDialog;
  final Function(EventOfficialModel) deleteEventOfficialModel;
  final Function(EventOfficialModel,bool) changeCertificateStatus;

  MyData({
    required this.data,
    required this.showEventOfficialModelDetailsDialog,
    required this.showEditDialog,
    required this.deleteEventOfficialModel,
    required this.changeCertificateStatus
  });

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      print('Invalid index accessed: $index, data length: ${data.length}');
      return null; // or throw an exception if preferred
    }
    final EventOfficialModel eventOfficial = data[index];
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text((index + 1).toString())),
      DataCell(Text(eventOfficial.id)),
      DataCell(Text(eventOfficial.officialName)),
      DataCell(Text(eventOfficial.userName)),
      DataCell(Text(eventOfficial.eventId)),
      DataCell(buildEllipseTextContainer(eventOfficial.eventName,100)),
      DataCell(IconButton(
        icon: Icon(Icons.visibility, size: 16, color: Colors.orangeAccent),
        onPressed: () {
          showEventOfficialModelDetailsDialog(eventOfficial);
        },
      )),
      DataCell(IconButton(
        icon: Icon(Icons.edit, size: 16, color: Colors.blue),
        onPressed: () {
          showEditDialog(eventOfficial);
        },
      )),
      DataCell(
        Transform.scale(
          scale: 0.4, // Adjust the scale value to make the switch smaller
          child: Switch(
            value: eventOfficial.cetificateStatus,
            onChanged: (value) {
              changeCertificateStatus(eventOfficial, value);
            },
          ),
        ),
      ),

      DataCell(IconButton(
        icon: Icon(Icons.delete, size: 16, color: Colors.red),
        onPressed: () {
          // Handle delete action
          deleteEventOfficialModel(eventOfficial);
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
