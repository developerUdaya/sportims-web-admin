import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:excel/excel.dart';
import 'package:sport_ims/models/EventParticipantsModel.dart';
import '../models/UsersModel.dart';
import '../models/EventModel.dart';

class ParticipantsListPage extends StatefulWidget {
  final String? clubName;

  ParticipantsListPage({required this.clubName});

  @override
  _ParticipantsListPageState createState() => _ParticipantsListPageState();
}

class _ParticipantsListPageState extends State<ParticipantsListPage> {
  List<Users> clubSkaters = [];
  List<Users> participants = [];
  List<Users> nonParticipants = [];
  List<EventModel> events = [];
  List<EventParticipantsModel> evenParticipants = [];

  String? selectedEvent;
  String selectedFilter = 'Participants';
  bool _isLoading = true;
  bool _isSearching = false;
  List<Users> tableData = [];
  final database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    fetchEvents().whenComplete(() => fetchEventParticipants(),);
    fetchClubSkaters();
  }


  Future<void> fetchEventParticipants() async {
    List<EventParticipantsModel> evenParticipants = [];

    print("eventParticipantsModel.skaterId");

    for(String eventId in events.map((e) => e.id,).toList()){
        final ref = database.ref().child('events/pastEvents/$eventId');
        DataSnapshot snapshot = await ref.get();

        if (snapshot.exists) {
          print('Value : ${snapshot.value}');

          // Extract the 'eventParticipants' sub-map
          Map<dynamic, dynamic> eventMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
          if (eventMap.containsKey('eventParticipants')) {
            Map<dynamic, dynamic> participantsMap = Map<dynamic, dynamic>.from(eventMap['eventParticipants'] as Map);

            for (final entry in participantsMap.entries) {
              EventParticipantsModel eventParticipantsModel = EventParticipantsModel.fromJson(
                  Map<String, dynamic>.from(entry.value as Map)
              );
              evenParticipants.add(eventParticipantsModel);

              print('Skater ID : ${eventParticipantsModel.skaterId}');
            }
          } else {
            print('No participants found for event ID: $eventId');
          }
        } else {
          print('No event found for event ID: $eventId');
        }



    }

    setState(() {
      this.evenParticipants = evenParticipants;
    });
    
    
  }

  // Fetch events from Firebase and populate participants based on skaterId
  Future<void> fetchEvents() async {
    List<EventModel> eventList = [];
    final ref = database.ref().child('events/pastEvents');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        EventModel event = EventModel.fromJson(Map<String, dynamic>.from(child.value as Map));
        if(!event.deleteStatus) {
          eventList.add(event);
        }
      }
    }

    setState(() {
      events = eventList;

    });
  }

  // Fetch skaters data from the database
  Future<void> fetchClubSkaters() async {
    List<Users> users = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('skaters');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        try {
          Users user = Users.fromJson(Map<String, dynamic>.from(child.value as Map));



          if (user.club == widget.clubName) {
            users.add(user);
          }
        } catch (e) {
          print(e);
        }
      }
    }

    setState(() {
      clubSkaters = users;
      _isLoading = false;
      filterParticipants(); // Filter participants for initial setup
    });
  }

  // Filter participants and non-participants based on selected event and skaterId
  void filterParticipants() {
    if (selectedEvent != null) {
      // Get the selected event object
      EventModel? selectedEventModel = events.firstWhere((event) => event.eventName==selectedEvent!);


      setState(() {
        // Filter participants and non-participants
        participants = clubSkaters.where((element) =>evenParticipants.where((element) => element.eventID==selectedEventModel.id,).map((e) => e.skaterId,).toList().contains( element.skaterID)).toList();
        nonParticipants = clubSkaters.where((element) =>!evenParticipants.where((element) => element.eventID==selectedEventModel.id,).toList().map((e) => e.skaterId,).toList().contains( element.skaterID)).toList();
        // participants = clubSkaters.where((clubSkater) => evenParticipants.map((e) => e.skaterId).toList().contains(clubSkater.skaterID )).toList();
        // nonParticipants = clubSkaters.where((clubSkater) => !evenParticipants.map((e) => e.skaterId).toList().contains(clubSkater.skaterID )).toList();
        // participants =  clubSkaters.where((user) => selectedEventModel.participants.map((e) => e.skaterID).toList().join(',').toString().contains(user.skaterID)).toList();
        // nonParticipants = clubSkaters.where((user) => !selectedEventModel.participants.map((e) => e.skaterID).toList().join(',').toString().contains(user.skaterID)).toList();
        tableData = selectedFilter == 'Participants' ? participants : nonParticipants;
      });
    }
  }

  // Search functionality
  void _searchSkaters(String value) {
    setState(() {
      tableData = (selectedFilter == 'Participants' ? participants : nonParticipants)
          .where((skater) => skater.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Report', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon:const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
          SizedBox(width: 20),
          // TextButton.icon(
          //   onPressed: exportToExcel,
          //   icon: Icon(Icons.download_for_offline, color: Colors.white),
          //   label: Text(
          //     'Export to Excel',
          //     style: TextStyle(color: Colors.white),
          //   ),
          //   style: TextButton.styleFrom(
          //     backgroundColor: Colors.blue[800],
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //   ),
          // ),
          // SizedBox(width: 20),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_isSearching)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by skater name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _searchSkaters,
              ),
            ),
          // Dropdowns for event and participant filter
          Container(
            color: Color(0xfff5f6fa),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dropdown for selecting the event
                Expanded(
                  child: _buildDropdown(
                    value: selectedEvent,
                    hint: 'Select Event',
                    items: events.map((event) {
                      return DropdownMenuItem<String>(
                        value: event.eventName,
                        child: Text(event.eventName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedEvent = value;
                        filterParticipants();
                      });
                    },
                  ),
                ),
                SizedBox(width: 20),
                // Dropdown for selecting Participants or Non-Participants
                Expanded(
                  child: _buildDropdown(
                    value: selectedFilter,
                    items: <String>['Participants', 'Non-Participants']
                        .map((filter) => DropdownMenuItem<String>(
                      value: filter,
                      child: Text(filter),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                        filterParticipants();
                      });
                    },
                    hint: '',
                  ),
                ),
              ],
            ),
          ),
          // Table header
          Container(
            margin: EdgeInsets.fromLTRB(10,0,10,80),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderCell('S.No'),
                _buildHeaderCell('Name'),
                _buildHeaderCell('Skater ID'),
                _buildHeaderCell('Contact'),
                _buildHeaderCell('Skate Category'),
                _buildHeaderCell('DOB'),
              ],
            ),
          ),
          // Table body
          Expanded(
            child: Container(
              color: Color(0xfff5f6fa),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: tableData.length,
                  itemBuilder: (context, index) {
                    final skater = tableData[index];
                    return Container(
                      // margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDataCell((index + 1).toString()),
                          _buildDataCell(skater.name),
                          _buildDataCell(skater.skaterID),
                          _buildDataCell(skater.contactNumber), // Skater Mobile Number added
                          _buildDataCell(skater.skateCategory),
                          _buildDataCell(skater.dateOfBirth),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: exportToExcel,
        icon: Icon(Icons.download_for_offline, color: Colors.white),
        label: Text('Export to Excel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  // Widget for dropdowns
  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
      icon: Icon(Icons.arrow_drop_down),
    );
  }

  // Widget for data cells
  Widget _buildDataCell(String text) {
    return Container(
      width: 100,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // Widget for header cells
  Widget _buildHeaderCell(String text) {
    return Container(
      width: 100,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Export to Excel functionality
  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Add headers
      List<String> headers = ['S.No', 'Name', 'Skater ID', 'Mobile Number', 'Skate Category', 'Date of Birth'];
      sheetObject.appendRow(headers);

      // Add data
      for (int i = 0; i < tableData.length; i++) {
        Users skater = tableData[i];
        List<String> data = [
          (i + 1).toString(),
          skater.name,
          skater.skaterID,
          skater.contactNumber, // Add skater's mobile number to Excel export
          skater.skateCategory,
          skater.dateOfBirth,
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', '${widget.clubName}_${selectedEvent}_SkatersData.xlsx')
        ..click();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }
}
