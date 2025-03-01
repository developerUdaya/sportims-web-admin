import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/events/AddEvent.dart';
import 'package:sport_ims/events/EditEventDetails.dart';
import 'package:sport_ims/models/Constants.dart';

import '../../models/DistrictModel.dart';
import '../../models/StateModel.dart';
import '../../models/ClubsModel.dart';
import '../models/EventModel.dart';
import 'EventDetailsPage2.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
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
  List<EventModel> allSkaters = [];

  List<EventModel> tableData = [
    // EventModel(skaterID: "817ID", name: "Udaya", address: "Chennai,tn", state: "Tamilnadu", district: "Namakkal", school: "kms", schoolAffiliationNumber: "182719289", club: "club001", email: "uday@gmail.com", contactNumber: "9944758128", bloodGroup: "o-ve", gender: "male", skateCategory: "Beginner", aadharBirthCertificateNumber: "8398639849932", dateOfBirth: "25-12-2000", profileImageUrl: "profileImageUrl.", docFileUrl: "docFileUrl", regDate: '', approval: '')
  ];


  //Add new event variables Initialize variables for dropdown selections
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
    getEventModel();
  }

  Future<void> exportToExcel(BuildContext context, List<EventModel> events) async {
    // Show loading dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Exporting Events Data...')),
    );
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Add headers
      List<String> headers = [
        'Event ID', 'Event Name', 'Event Date', 'Place', 'Registration Start Date', 'Registration Close Date', 'Age Categories',
        'Participants Count', 'Advertisement', 'Banner Image', 'Certificate Status', 'Declaration', 'Instruction', 'Registration Amount',
        'Event Prefix Name', 'Created At', 'Updated At', 'Visibility', 'Event Races'
      ];
      sheetObject.appendRow(headers);

      // Add data for each event
      for (var event in allSkaters) {

        print(event.id);
        List<dynamic> rowData = [
          event.id,
          event.eventName,
          event.eventDate.toIso8601String(),
          event.place,
          event.regStartDate.toIso8601String(),
          event.regCloseDate.toIso8601String(),
          event.ageCategory.join(', '), // Assuming ageCategory is List<String>
          event.participants.length,
          event.advertisement,
          event.bannerImage,
          event.certificateStatus,
          event.declaration,
          event.instruction,
          event.regAmount,
          event.eventPrefixName,
          event.createdAt.toIso8601String(),
          event.updatedAt.toIso8601String(),
          event.visibility,
          event.eventRaces.map((e) => e).join(', '), // Assuming eventRaces is List<EventRaceModel>
        ];

        sheetObject.appendRow(rowData);
      }

      // Save the file
      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'EventsData.xlsx')
        ..click();

      // Show success message
      // Navigator.of(context).pop(); // Dismiss the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Events data exported successfully')),
      );
    } catch (e) {
      // Close loading dialog
      // Navigator.of(context).pop(); // Dismiss the loading dialog

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to export events data: $e')),
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


  Future<void> getEventModel() async {
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
        }
      } else {
        print('No data available.');
      }
      setState(() {
        print(2);
        tableData = events;
        allSkaters = events;

        print(3);
      });

    }catch(e){
      print(e.toString());
    }
  }
  Future<void> showEditDialog(EventModel eventModel) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditEventDetails(eventModel: eventModel,updateEventModels: updateEvent,);
        // return EditEventDialog(event: event, club: clubs, updateEvent: updateEvent);
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

  void updateEvent(EventModel eventModel){
    setState(() {
      int index = tableData.indexWhere((element) => element.id == eventModel.id);
      if (index != -1) {
        tableData[index] = eventModel;
      }else{
        tableData.add(eventModel);
      }
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

  void addNewEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventCreationForm(updateEventModels: updateEvent,);
      },
    );
  }

  void updateEventApproval(EventModel event){

    setState(() {
      int index = tableData.indexWhere((element) => element.id == event.id);
      if (index != -1) {
        tableData[index].visibility = event.visibility;
      }
    });
  }

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  void showEventDetailsDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventDetailsPage(eventModel: event,);
        //return EventDetailsPage(event: event, updateEventApproval: updateEventApproval,);
      },
    );
  }


  void deleteEvent(EventModel event) async {
    bool shouldDelete = false;

    // Show confirmation dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event? This action cannot be undone.'),
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
      final ref = FirebaseDatabase.instance.ref('events/pastEvents/${event.id}/deleteStatus/');
      await ref.set(true);
      setState(() {
        tableData.removeWhere((element) => element.id == event.id);

      });


      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Event deleted successfully.'),
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
    catch (error) {
      Navigator.pop(context); // Close the loading dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to delete event. Please try again.'),
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


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: Text("Events"),
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
                          addNewEventDialog(context);
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
                      duration: const Duration(milliseconds: 65),
                      width: _isSearching ? 200 : 0,
                      height: _isSearching ? 35 : 0,
                      padding: _isSearching?const EdgeInsets.symmetric(horizontal: 0,vertical: 0):const EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child:Container(
                              width: _textFieldWidth,
                              child: CupertinoSearchTextField(
                                onChanged: (value) {
                                  // Handle search query changes
                                  setState(() {
                                    tableData = allSkaters.where((element) =>
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
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                    ),
                    if(!_isSearching)TextButton.icon(
                      onPressed: () async {
                        // Handle button press

                        await exportToExcel(context, allSkaters);
                      },
                      icon: const Icon(
                        Icons.download_for_offline,
                        color: Color(0xff276ad5),
                      ),
                      label: const Text(
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
                          DataColumn(label: Text('Event ID')),
                          DataColumn(label: Text('Event Name')),
                          DataColumn(label: Text('Place')),
                          DataColumn(label: Text('Event Date')),
                          DataColumn(label: Text('View')),
                          DataColumn(label: Text('Edit')),
                          DataColumn(label: Text('Reg Status')),
                          DataColumn(label: Text('Visibility')),
                          DataColumn(label: Text('Delete')),
                        ],
                        source: MyData(
                          data: tableData,
                          showEventDetailsDialog: showEventDetailsDialog,
                          showEditDialog: showEditDialog,
                          deleteEvent: deleteEvent,
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
  final List<EventModel> data;
  final Function(EventModel) showEventDetailsDialog;
  final Function(EventModel) showEditDialog;
  final Function(EventModel) deleteEvent;

  MyData({
    required this.data,
    required this.showEventDetailsDialog,
    required this.showEditDialog,
    required this.deleteEvent
  });

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= data.length) {
      print('Invalid index accessed: $index, data length: ${data.length}');
      return null; // or throw an exception if preferred
    }
    final EventModel event = data[index];
    DateTime regStartDateTime = DateFormat('yyyy-MM-dd').parse(event.regStartDate.toString());
    DateTime regCloseDateTime = DateFormat('yyyy-MM-dd').parse(event.regCloseDate.toString());
    // Get the current date
    DateTime now = DateTime.now();

    IconData displayIcon;
    String displayText;
    Color displayColor;
    if (now.isBefore(regStartDateTime)) {
      displayText = "Not started";
      displayIcon = Icons.hourglass_bottom_rounded;
      displayColor = Colors.orangeAccent;
    } else if (now.isBefore(regCloseDateTime)) {
      displayText = "Started";
      displayIcon = Icons.check_circle;
      displayColor = Colors.green;

    } else {
      displayText = "Closed";
      displayIcon = Icons.block;
      displayColor = Colors.red;

    }
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text((index + 1).toString())),
      DataCell(Text(event.id)),
      DataCell(
          Container(
              width: 100,
              child: Text(event.eventName,style: TextStyle(overflow: TextOverflow.ellipsis),
              )
          )
      ),
      DataCell(
          Container(
              width: 100,
              child: Text(event.place,style: TextStyle(overflow: TextOverflow.ellipsis),
              )
          )
      ),
      // DataCell(Text(event.place)),
      DataCell(Text(event.eventDate.toString().length>=9?event.eventDate.toString().substring(0, 10):_formatDate(DateTime.now()))),
      DataCell(IconButton(
        icon: Icon(Icons.visibility, size: 16, color: Colors.orangeAccent),
        onPressed: () {
          showEventDetailsDialog(event);
        },
      )),
      DataCell(IconButton(
        icon: Icon(Icons.edit, size: 16, color: Colors.blue),
        onPressed: () {
          showEditDialog(event);
        },
      )),
      DataCell(Row(
        children: [
          Text(displayText,style: TextStyle(color: displayColor),),
          IconButton(
            icon: Icon(
              displayIcon,
              size: 16,
              color: displayColor,
            ),
            onPressed: () {
              // Handle status action
            },
          ),
        ],
      )),
      DataCell(IconButton(
        icon: Icon(
          !event.visibility ? Icons.block : Icons.check_circle,
          size: 16,
          color: !event.visibility ? Colors.red : Colors.green,
        ),
        onPressed: () {
          // Handle status action
        },
      )),
      DataCell(IconButton(
        icon: Icon(Icons.delete, size: 16, color: Colors.red),
        onPressed: () {
          // Handle delete action
          deleteEvent(event);
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


