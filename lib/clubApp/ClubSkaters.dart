import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:excel/excel.dart';
import 'package:sport_ims/utils/Controllers.dart';
import '../../models/UsersModel.dart';

class ClubSkaters extends StatefulWidget {
  final String? clubName;

  ClubSkaters({required this.clubName});

  @override
  _ClubSkatersState createState() => _ClubSkatersState();
}

class _ClubSkatersState extends State<ClubSkaters> {
  List<Users> clubSkaters = [];
  bool _isLoading = true;
  bool _isSearching = false;
  List<Users> tableData = [];

  @override
  void initState() {
    super.initState();
    getClubSkaters();
  }

  Future<void> getClubSkaters() async {
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
      tableData = users;
      _isLoading = false;
    });
  }

  // Search functionality
  void _searchSkaters(String value) {
    setState(() {
      tableData = clubSkaters
          .where((skater) => skater.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // Export to Excel functionality
  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Add headers
      List<String> headers = ['S.No', 'Name', 'Skater ID', 'Skate Category', 'Date of Birth'];
      sheetObject.appendRow(headers);

      // Add data
      for (int i = 0; i < clubSkaters.length; i++) {
        Users skater = clubSkaters[i];
        List<String> data = [
          (i + 1).toString(),
          skater.name,
          skater.skaterID,
          skater.skateCategory,
          skater.dateOfBirth,
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', '${widget.clubName}_SkatersData.xlsx')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skaters ',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[700],
        actions: [
          Container(
              width: 500,
              alignment: Alignment.centerRight,
              child: Text("${tableData.length} skaters",style: TextStyle(color: Colors.white,fontSize: 18,overflow: TextOverflow.ellipsis),)),

          IconButton(
            icon: Icon(Icons.search,color: Colors.white,),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        margin: EdgeInsets.only(bottom: 80),
            child: Column(
                    children: [
            if (_isSearching)
              Container(
                color: Color(0xfff5f6fa),
                padding: const EdgeInsets.all(16.0),
                child: CupertinoSearchTextField(
                  placeholder: 'Search by skater name...',
                  onChanged: _searchSkaters,
                ),
              ),
            Expanded(
              child: Container(
                color: Color(0xfff5f6fa),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Header Row with Rounded Corners
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          // borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildHeaderCell('S.No', flex: 1),
                            _buildHeaderCell('Name', flex: 3),
                            _buildHeaderCell('Skater ID', flex: 2),
                            _buildHeaderCell('Skate Category', flex: 2),
                            _buildHeaderCell('Date of Birth', flex: 2),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      // Data Rows
                      Expanded(
                        child: ListView.builder(
                          itemCount: tableData.length,
                          itemBuilder: (context, index) {
                            final skater = tableData[index];
                            return Container(
                              // margin: EdgeInsets.only(bottom: 12),
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
                                  _buildDataCell((index+1).toString(), flex: 1),

                                  _buildDataCell(skater.name, flex: 3),
                                  _buildDataCell(skater.skaterID, flex: 2),
                                  _buildDataCell(skater.skateCategory, flex: 2),
                                  _buildDataCell(skater.dateOfBirth, flex: 2),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
                    ],
                  ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: exportToExcel,
        icon: Icon(Icons.download_for_offline,color: Colors.white,),
        label: Text('Export to Excel',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// Users Model
class Users {
  String name;
  String skaterID;
  String club;
  String skateCategory;
  String dateOfBirth;

  Users({
    required this.name,
    required this.skaterID,
    required this.club,
    required this.skateCategory,
    required this.dateOfBirth,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      name: json['name'] ?? '',
      skaterID: json['skaterID'] ?? '',
      club: json['club'] ?? '',
      skateCategory: json['skateCategory'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'skaterID': skaterID,
      'club': club,
      'skateCategory': skateCategory,
      'dateOfBirth': dateOfBirth,
    };
  }
}
