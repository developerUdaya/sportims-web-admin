import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:excel/excel.dart';
import '../models/ClubsModel.dart';
import '../models/EventModel.dart';
import '../models/EventParticipantsModel.dart';
import '../models/UsersModel.dart';

class DistrictClubsParticipantsPage extends StatefulWidget {
  final String districtName;

  DistrictClubsParticipantsPage({ required this.districtName});

  @override
  _DistrictClubsParticipantsPageState createState() => _DistrictClubsParticipantsPageState();
}

class _DistrictClubsParticipantsPageState extends State<DistrictClubsParticipantsPage> {
  List<Club> clubs = [];
  List<EventModel> events = [];
  String? selectedEvent;
  bool _isLoading = true;
  List<ClubParticipantsCount> clubParticipantsCount = [];
  bool _isSearching = false;
  List<ClubParticipantsCount> tableData = [];
  List<EventParticipantsModel> evenParticipants = [];

  final database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    fetchEvents().whenComplete(() => fetchEventParticipants(),);
    fetchClubs();
  }

  // Fetch the list of events
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

  // Fetch clubs in a specific district
  Future<void> fetchClubs() async {
    List<Club> clubList = [];
    final ref = database.ref().child('clubs');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        Club club = Club.fromJson(Map<String, dynamic>.from(child.value as Map));
        if (club.district == widget.districtName && club.approval == 'Approved') {
          clubList.add(club);
        }
      }
    }

    setState(() {
      clubs = clubList;
      _isLoading = false;
    });
  }

  // Filter the number of participants in each club for the selected event
  void filterParticipants() {
    if (selectedEvent != null) {
      setState(() {
        clubParticipantsCount = clubs.map((club) {
          int participantsCount = 0;
          // Fetch the selected event
          EventModel selectedEventModel = events.firstWhere((event) => event.eventName == selectedEvent);

          // Count participants in the club
          participantsCount = evenParticipants.where((id) => id.club==club.clubName && id.eventID==selectedEventModel.id).length;

          return ClubParticipantsCount(
            clubName: club.clubName!,
            masterName: club.masterName!,
            email: club.email!,
            contactNumber: club.contactNumber!,
            participantsCount: participantsCount,
          );
        }).toList();

        tableData = clubParticipantsCount;
      });
    }
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

  // Search functionality for clubs
  void _searchClubs(String value) {
    setState(() {
      tableData = clubParticipantsCount.where((club) => club.clubName.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('District Club Participants Report', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
          const SizedBox(width: 20),
          TextButton.icon(
            onPressed: exportToExcel,
            icon: Icon(Icons.download_for_offline, color: Colors.white),
            label: Text(
              'Export to Excel',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_isSearching)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by club name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _searchClubs,
              ),
            ),
          // Dropdown for selecting the event
          Container(
            color: const Color(0xfff5f6fa),
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
              ],
            ),
          ),
          // Table Header
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.blueGrey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderCell('S.No'),
                _buildHeaderCell('Club'),
                _buildHeaderCell('Master'),
                _buildHeaderCell('Email'),
                _buildHeaderCell('Contact'),
                _buildHeaderCell('Participants Count'),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: ColoredBox(
              color: const Color(0xfff5f6fa),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: tableData.length,
                  itemBuilder: (context, index) {
                    final club = tableData[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDataCell((index + 1).toString()),
                          _buildDataCell(club.clubName),
                          _buildDataCell(club.masterName),
                          _buildDataCell(club.email),
                          _buildDataCell(club.contactNumber),
                          _buildDataCell(club.participantsCount.toString()),
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: exportToExcel,
      //   icon: const Icon(Icons.download_for_offline, color: Colors.white),
      //   label: const Text('Export to Excel', style: TextStyle(color: Colors.white)),
      //   backgroundColor: Colors.blue[800],
      // ),
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
      icon: const Icon(Icons.arrow_drop_down),
    );
  }

  // Widget for data cells
  Widget _buildDataCell(String text) {
    return Container(
      width: 100,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 10,
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
      List<String> headers = ['S.No', 'Club', 'Master', 'Email', 'Contact', 'Participants Count'];
      sheetObject.appendRow(headers);

      // Add data
      for (int i = 0; i < tableData.length; i++) {
        ClubParticipantsCount club = tableData[i];
        List<String> data = [
          (i + 1).toString(),
          club.clubName,
          club.masterName,
          club.email,
          club.contactNumber,
          club.participantsCount.toString(),
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', '${widget.districtName}_${selectedEvent}_ClubsParticipantsData.xlsx')
        ..click();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data exported successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $e')),
      );
    }
  }
}

// Class to hold club name, master name, contact information, and participants count
class ClubParticipantsCount {
  final String clubName;
  final String masterName;
  final String email;
  final String contactNumber;
  final int participantsCount;

  ClubParticipantsCount({
    required this.clubName,
    required this.masterName,
    required this.email,
    required this.contactNumber,
    required this.participantsCount,
  });
}
