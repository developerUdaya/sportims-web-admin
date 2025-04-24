import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:excel/excel.dart';
import '../models/ClubsModel.dart';
import '../models/UsersModel.dart';

class DistrictClubsSkatersPage extends StatefulWidget {
  final String districtName;

  DistrictClubsSkatersPage({required this.districtName});

  @override
  _DistrictClubsSkatersPageState createState() => _DistrictClubsSkatersPageState();
}

class _DistrictClubsSkatersPageState extends State<DistrictClubsSkatersPage> {
  List<Club> clubs = [];
  List<ClubSkatersCount> clubSkatersCount = [];
  bool _isLoading = true;
  bool _isSearching = false;
  List<ClubSkatersCount> tableData = [];

  @override
  void initState() {
    super.initState();
    fetchClubsAndSkaters();

    print('init');
  }

  // Fetch clubs and count skaters in each club within the district
  Future<void> fetchClubsAndSkaters() async {
    List<Club> clubList = [];
    List<Users> allSkaters = [];
    print('fetchClubsAndSkaters');

    // Fetch clubs in the district
    final database = FirebaseDatabase.instance;
    final clubsRef = database.ref().child('clubs');
    DataSnapshot clubsSnapshot = await clubsRef.get();
    print('fetchClubsAndSkaters 2');

    if (clubsSnapshot.exists) {
      for (final child in clubsSnapshot.children) {
        print('fetchClubsAndSkaters for');

        Club club = Club.fromJson(Map<String, dynamic>.from(child.value as Map));
        print('fetchClubsAndSkaters end');

        if (club.district == widget.districtName && club.approval == 'Approved') {
          print('fetchClubsAndSkaters if');

          print("Club name ${club.district}  == ${widget.districtName}");
          clubList.add(club);
        }
      }
    }


    print('fetchClubsAndSkaters end');


    // Fetch all skaters
    final skatersRef = database.ref().child('skaters');
    DataSnapshot skatersSnapshot = await skatersRef.get();

    if (skatersSnapshot.exists) {
      for (final child in skatersSnapshot.children) {
        try {
          Users skater = Users.fromJson(
              Map<String, dynamic>.from(child.value as Map));
          allSkaters.add(skater);
        }catch(e){

        }
      }
    }

    // Calculate skater count for each club
    setState(() {
      clubs = clubList;
      clubSkatersCount = clubs.map((club) {
        int skaterCount = allSkaters.where((skater) => skater.club == club.clubName).length;

        return ClubSkatersCount(
          clubName: club.clubName!,
          masterName: club.masterName!,
          coachName: club.coachName!,
          address: club.address!,
          email: club.email!,
          contactNumber: club.contactNumber!,
          skatersCount: skaterCount,
        );
      }).toList();

      tableData = clubSkatersCount;
      _isLoading = false;
    });
  }

  // Search functionality to filter clubs by name
  void _searchClubs(String value) {
    setState(() {
      tableData = clubSkatersCount.where((club) => club.clubName.toLowerCase().contains(value.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('District Clubs Report', style: TextStyle(color: Colors.white)),
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
            icon: const Icon(Icons.download_for_offline, color: Colors.white),
            label: const Text(
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
          const SizedBox(width: 20),
        ],
      ),
      backgroundColor:  const Color(0xfff5f6fa),
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
          // Table Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
            padding: const EdgeInsets.all(12),
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
                _buildHeaderCell('Coach'),
                _buildHeaderCell('Address'),
                _buildHeaderCell('Email'),
                _buildHeaderCell('Contact'),
                _buildHeaderCell('Skaters Count'),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: Container(
              color: const Color(0xfff5f6fa),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: tableData.length,
                  itemBuilder: (context, index) {
                    final club = tableData[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
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
                          _buildDataCell(club.coachName),
                          _buildDataCell(club.address),
                          _buildDataCell(club.email),
                          _buildDataCell(club.contactNumber),
                          _buildDataCell(club.skatersCount.toString()),
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
      //   icon: Icon(Icons.download_for_offline, color: Colors.white),
      //   label: Text('Export to Excel', style: TextStyle(color: Colors.white)),
      //   backgroundColor: Colors.blue[800],
      // ),
    );
  }

  // Widget for data cells
  Widget _buildDataCell(String text) {
    return SizedBox(
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
    return SizedBox(
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
      List<String> headers = ['S.No', 'Club', 'Master', 'Coach', 'Address', 'Email', 'Contact', 'Skaters Count'];
      sheetObject.appendRow(headers);

      // Add data
      for (int i = 0; i < tableData.length; i++) {
        ClubSkatersCount club = tableData[i];
        List<String> data = [
          (i + 1).toString(),
          club.clubName,
          club.masterName,
          club.coachName,
          club.address,
          club.email,
          club.contactNumber,
          club.skatersCount.toString(),
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', '${widget.districtName}_ClubsSkatersData.xlsx')
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

// Class to hold club information and skaters count
class ClubSkatersCount {
  final String clubName;
  final String masterName;
  final String coachName;
  final String address;
  final String email;
  final String contactNumber;
  final int skatersCount;

  ClubSkatersCount({
    required this.clubName,
    required this.masterName,
    required this.coachName,
    required this.address,
    required this.email,
    required this.contactNumber,
    required this.skatersCount,
  });
}
