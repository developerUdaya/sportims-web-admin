import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../models/EventParticipantsModel.dart';

class DistrictParticipantsData extends StatefulWidget {
  final List<EventParticipantsModel> eventParticipants;
  final String name;

  DistrictParticipantsData({required this.eventParticipants,required this.name});

  @override
  _DistrictParticipantsDataState createState() => _DistrictParticipantsDataState();
}

class _DistrictParticipantsDataState extends State<DistrictParticipantsData> {
  List<DistrictCount> districtCounts = [];
  List<DistrictCount> tableData = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _calculateDistrictCounts();
  }

  // Calculate the number of participants per district
  void _calculateDistrictCounts() {
    Map<String, int> districtCountMap = {};
    for (var participant in widget.eventParticipants) {
      districtCountMap.update(participant.district, (value) => value + 1, ifAbsent: () => 1);
    }

    setState(() {
      districtCounts = districtCountMap.entries
          .map((entry) => DistrictCount(district: entry.key, count: entry.value))
          .toList();
      tableData = districtCounts;
    });
  }

  // Search functionality
  void _searchDistricts(String value) {
    setState(() {
      tableData = districtCounts
          .where((element) => element.district.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // Export to Excel functionality
  Future<void> exportToExcel() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      List<String> headers = ['S.No', 'District', 'Count'];
      sheetObject.appendRow(headers);

      for (int i = 0; i < districtCounts.length; i++) {
        List<String> data = [
          (i + 1).toString(),
          districtCounts[i].district,
          districtCounts[i].count.toString()
        ];
        sheetObject.appendRow(data);
      }

      var fileBytes = excel.encode()!;
      final content = base64Encode(fileBytes);
      final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;charset=utf-8;base64,$content')
        ..setAttribute('download', 'DistrictParticipants.xlsx')
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
        title: Text("District Report",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue[700],
        actions: [
          Text("Hello, ${widget.name} !",style: TextStyle(color: Colors.white,fontSize: 18),),

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
                placeholder: 'Search by district...',
                onChanged: _searchDistricts,
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
                          _buildHeaderCell('District'),
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
                          final districtCount = tableData[index];
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
                                _buildDataCell(districtCount.district),
                                _buildDataCell('${districtCount.count}'),
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

// Class to hold district name and participant count
class DistrictCount {
  final String district;
  final int count;

  DistrictCount({required this.district, required this.count});
}
