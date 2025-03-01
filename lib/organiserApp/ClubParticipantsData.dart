import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../models/EventParticipantsModel.dart';

class ClubParticipantsData extends StatefulWidget {
  final List<EventParticipantsModel> eventParticipants;
  final String club;

  ClubParticipantsData({required this.eventParticipants, required this.club});

  @override
  _ClubParticipantsDataState createState() => _ClubParticipantsDataState();
}

class _ClubParticipantsDataState extends State<ClubParticipantsData> {
  List<ClubCount> clubCounts = [];
  List<ClubCount> tableData = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _calculateClubCounts();
  }

  // Calculate the number of participants per club
  void _calculateClubCounts() {
    Map<String, int> clubCountMap = {};
    for (var participant in widget.eventParticipants) {
      clubCountMap.update(participant.club, (value) => value + 1, ifAbsent: () => 1);
    }

    setState(() {
      clubCounts = clubCountMap.entries
          .map((entry) => ClubCount(club: entry.key, count: entry.value))
          .toList();
      tableData = clubCounts;
    });
  }

  // Search functionality
  void _searchClubs(String value) {
    setState(() {
      tableData = clubCounts
          .where((element) => element.club.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // Export to Excel functionality
  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      List<String> headers = ['S.No', 'Club', 'Count'];
      sheetObject.appendRow(headers);

      for (int i = 0; i < clubCounts.length; i++) {
        List<String> data = [
          (i + 1).toString(),
          clubCounts[i].club,
          clubCounts[i].count.toString()
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'ClubParticipants.xlsx')
        ..click();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported successfully'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Club Report",style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
        actions: [
          Container(
              width: 500,
              alignment: Alignment.centerRight,
              child: Text("Hello, ${widget.club} !",style: TextStyle(color: Colors.white,fontSize: 18,overflow: TextOverflow.ellipsis),)),

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
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                placeholder: 'Search by club name...',
                onChanged: _searchClubs,
              ),
            ),
          Expanded(
            child: Container(
              color: Color(0xffe3ecfa),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header Row
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderCell('S.No'),
                          _buildHeaderCell('Club'),
                          _buildHeaderCell('Count'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // Data Rows
                    Expanded(
                      child: ListView.builder(
                        itemCount: tableData.length,
                        itemBuilder: (context, index) {
                          final clubCount = tableData[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
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
                                _buildDataCell('${index + 1}'),
                                _buildDataCell(clubCount.club),
                                _buildDataCell('${clubCount.count}'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: exportToExcel,
        icon: Icon(Icons.download_for_offline,color: Colors.white,),
        label: Text('Export to Excel',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
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

  Widget _buildDataCell(String text) {
    return Expanded(
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

// Class to hold club name and participant count
class ClubCount {
  final String club;
  final int count;

  ClubCount({required this.club, required this.count});
}
