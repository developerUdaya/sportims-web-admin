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
import 'package:sport_ims/eventOrganiser/AddEventOrganiserDialog.dart';
import 'package:sport_ims/eventOrganiser/EventOrganiserDetailsPage.dart';
import 'package:sport_ims/models/Constants.dart';
import 'package:sport_ims/models/EventOrganiser.dart';

import '../../models/DistrictModel.dart';
import '../../models/StateModel.dart';
import '../../models/ClubsModel.dart';
import '../eventOrganiser/EditEventOrganiserDialog.dart';
import '../models/EventModel.dart';
import '../utils/Colors.dart';
import 'AddOfficialEventOrganiserDialog.dart';
import 'EditOfficialEventOrganiserDialog.dart';


class OfficialEventOrganiserData extends StatefulWidget {

  EventModel eventModel;
  OfficialEventOrganiserData({required this.eventModel});

  @override
  State<OfficialEventOrganiserData> createState() => _OfficialEventOrganiserDataState();
}

class _OfficialEventOrganiserDataState extends State<OfficialEventOrganiserData> {

  bool _isSearching = false;
  double _textFieldWidth = 70;
  List<EventOrganiser> allSkaters = [];

  List<EventOrganiser> tableData = [
    // EventOrganiser(skaterID: "817ID", name: "Udaya", address: "Chennai,tn", state: "Tamilnadu", district: "Namakkal", school: "kms", schoolAffiliationNumber: "182719289", club: "club001", email: "uday@gmail.com", contactNumber: "9944758128", bloodGroup: "o-ve", gender: "male", skateCategory: "Beginner", aadharBirthCertificateNumber: "8398639849932", dateOfBirth: "25-12-2000", profileImageUrl: "profileImageUrl.", docFileUrl: "docFileUrl", regDate: '', approval: '')
  ];

  late EventModel eventModel;

  //Add new eventOrganiser variables Initialize variables for dropdown selections
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

    getEventOrganiser();

  }

  Future<void> exportToExcel() async {
    // Show loading dialog
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Add headers
      List<String> headers = [
        'ID', 'Name', 'User Name', 'Password', 'Event Id', 'Event Name','Registration Date', 'Updated At','Status'
      ];
      sheetObject.appendRow(headers);

      // Add data
      for (var eventOrganiser in allSkaters) {
        List<String> data = [
          eventOrganiser.id, eventOrganiser.name, eventOrganiser.userName, eventOrganiser.password, eventOrganiser.eventId, eventOrganiser.eventName, eventOrganiser.createdAt, eventOrganiser.updatedAt, eventOrganiser.approval
        ];
        sheetObject.appendRow(data);
      }

      // Save the file
      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'EventOrganisers.xlsx')
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



  Future<void> getEventOrganiser() async {
    // Show loading dialog
    setState(() {
      widget.eventModel = this.eventModel!;

    });
    List<EventOrganiser> eventOrganisers = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('eventOrganisers');

    // Fetch the data once using a single await call
    try {
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          try {
            // Convert each child snapshot to an EventOrganiser object
            EventOrganiser eventOrganiser = EventOrganiser.fromJson(Map<String, dynamic>.from(child.value as Map));
            eventOrganisers.add(eventOrganiser);
            print(eventOrganiser.name);
          } catch (e) {
            print('Error converting child snapshot to EventOrganiser: $e');
          }
        }
      } else {
        print('No data available.');
      }

      setState(() {
        print(2);
        tableData = eventOrganisers.where((element) => element.eventId.contains(eventModel!.id)).toList();
        allSkaters = eventOrganisers.where((element) => element.eventId.contains(eventModel!.id)).toList();
        print(3);
      });
    } catch (e) {
      print('Error fetching data from Firebase: $e');
    }
  }
  Future<void> showEditDialog(EventOrganiser eventOrganiser) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditOfficialEventOrganiserDialog(eventOrganiser: eventOrganiser,  updateEventOrganiser: updateEventOrganiser, eventModel: eventModel!,);
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

  void updateEventOrganiser(EventOrganiser eventOrganiser){
    setState(() {
      int index = tableData.indexWhere((element) => element.id == eventOrganiser.id);
      if (index != -1) {
        tableData[index] = eventOrganiser;
      }
    });
  }

  void addEventOrganiser(EventOrganiser eventOrganiser){

    setState(() {
      tableData.add(eventOrganiser);
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

  void addNewEventOrganiserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddNewOfficialEventOrganiserDialog(updateEventOrganiser: addEventOrganiser, eventModel: widget.eventModel!,);
      },
    );
  }

  void updateEventOrganiserApproval(EventOrganiser eventOrganiser){

    setState(() {
      int index = tableData.indexWhere((element) => element.id == eventOrganiser.id);
      if (index != -1) {
        tableData[index].approval = "Approved";
      }
    });
  }

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  void showEventOrganiserDetailsDialog(EventOrganiser eventOrganiser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventOrganiserDetailsPage(eventOrganiser: eventOrganiser, updateEventOrganiserApproval: updateEventOrganiserApproval,);
      },
    );
  }

  void approveEventOrganiser(EventOrganiser eventOrganiser) {
    final ref = FirebaseDatabase.instance.ref('eventOrganisers/${eventOrganiser.id}');
    ref.update({'approval': "Approved"});
  }

  void deleteEventOrganiser(EventOrganiser eventOrganiser) async {
    bool shouldDelete = false;

    // Show confirmation dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete EventOrganiser'),
          content: Text('Are you sure you want to delete this eventOrganiser? This action cannot be undone.'),
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
      final ref = FirebaseDatabase.instance.ref('eventOrganisers/${eventOrganiser.id}');
      await ref.remove();

      final userRef = FirebaseDatabase.instance.ref('users/${eventOrganiser.userName}');
      await userRef.remove();

      setState(() {
        tableData.removeWhere((element) => element.id == eventOrganiser.id);

      });


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('EventOrganiser deleted successfully.'),
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
            content: Text('Failed to delete eventOrganiser. Please try again.'),
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
          title: Text("Event Organisers"),
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
                          addNewEventOrganiserDialog(context);
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
                                    element.name.toLowerCase().contains(value.toLowerCase()) ||
                                        element.userName.toLowerCase().contains(value.toLowerCase())
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
                          showEventOrganiserDetailsDialog: showEventOrganiserDetailsDialog,
                          showEditDialog: showEditDialog,
                          deleteEventOrganiser: deleteEventOrganiser,
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
  final List<EventOrganiser> data;
  final Function(EventOrganiser) showEventOrganiserDetailsDialog;
  final Function(EventOrganiser) showEditDialog;
  final Function(EventOrganiser) deleteEventOrganiser;

  MyData({
    required this.data,
    required this.showEventOrganiserDetailsDialog,
    required this.showEditDialog,
    required this.deleteEventOrganiser
  });

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      print('Invalid index accessed: $index, data length: ${data.length}');
      return null; // or throw an exception if preferred
    }
    final EventOrganiser eventOrganiser = data[index];
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text((index + 1).toString())),
      DataCell(Text(eventOrganiser.id)),
      DataCell(Text(eventOrganiser.name)),
      DataCell(Text(eventOrganiser.userName)),
      DataCell(Text(eventOrganiser.eventId)),
      DataCell(Text(eventOrganiser.eventName)),
      DataCell(IconButton(
        icon: Icon(Icons.visibility, size: 16, color: Colors.orangeAccent),
        onPressed: () {
          showEventOrganiserDetailsDialog(eventOrganiser);
        },
      )),
      DataCell(IconButton(
        icon: Icon(Icons.edit, size: 16, color: Colors.blue),
        onPressed: () {
          showEditDialog(eventOrganiser);
        },
      )),
      DataCell(IconButton(
        icon: Icon(
          eventOrganiser.approval != "Approved" ? Icons.thumb_down : Icons.verified,
          size: 16,
          color: eventOrganiser.approval != "Approved" ? Colors.red : Colors.green,
        ),
        onPressed: () {
          // Handle status action
        },
      )),
      DataCell(IconButton(
        icon: Icon(Icons.delete, size: 16, color: Colors.red),
        onPressed: () {
          // Handle delete action
          deleteEventOrganiser(eventOrganiser);
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
