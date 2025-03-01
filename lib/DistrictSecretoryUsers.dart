import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class DistrictSecretory extends StatefulWidget {
  const DistrictSecretory({super.key});

  @override
  State<DistrictSecretory> createState() => _DistrictSecretoryState();
}

class _DistrictSecretoryState extends State<DistrictSecretory> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: RightSide(),
    );
  }
}

class RightSide extends StatefulWidget {
  @override
  State<RightSide> createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  String dropdownValue = 'Option 1'; // Default dropdown value
  bool _showPrefix = true;
  bool _isSearching = false;
  double _textFieldWidth = 70;
  List<DistrictSecretoryModel> tableData = [
    DistrictSecretoryModel("s001", "TNTPD0002","Tirupur"," Tiruppur","24/08/2023"),
    DistrictSecretoryModel("s001", "TNTPD0002","Tirupur"," Tiruppur","24/08/2023"),
    DistrictSecretoryModel("s001", "TNTPD0002","Tirupur"," Tiruppur","24/08/2023"),
    DistrictSecretoryModel("s001", "TNTPD0002","Tirupur"," Tiruppur","24/08/2023"),
    DistrictSecretoryModel("s001", "TNTPD0002","Tirupur"," Tiruppur","24/08/2023"),
    DistrictSecretoryModel("s001", "TNTPD0002","Tirupur"," Tiruppur","24/08/2023"),


  ];


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: Text("District Secretory Users"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.only(top: 20, left: 20,right: 20,bottom: 10), // Add space from top and left
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [

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
                                },
                              ),
                            ),
                          ),
                          // IconButton(
                          //   // icon: Icon(Icons.cancel),
                          //   onPressed: () {
                          //     setState(() {
                          //       _isSearching = false;
                          //     });
                          //   },
                          // ),
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

                    // Expanded(child: SizedBox()),
                    //

                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(9),
                            child: Expanded(
                              child: DataTable(

                                headingRowHeight: 45,
                                dataRowHeight: 40,
                                columns: [
                                  DataColumn(label: Text('Serial No'), numeric: false),
                                  DataColumn(label: Text('DS ID'), numeric: false),
                                  DataColumn(label: Text('DS Name'), numeric: false),
                                  DataColumn(label: Text('District'), numeric: false),
                                  DataColumn(label: Text('Registered Date'), numeric: false),
                                  // DataColumn(label: Text('No.of.Participant'), numeric: false),
                                  DataColumn(label: Text('View'), numeric: false),
                                  DataColumn(label: Text('Edit'), numeric: false),
                                  // DataColumn(label: Text('Status'), numeric: false),
                                  DataColumn(label: Text('Delete'), numeric: false),
                                ],
                                rows: List.generate(tableData.length, (index) {
                                  return DataRow(cells: [
                                    DataCell(Text(tableData[index].serialnumber)),
                                    DataCell(Text(tableData[index].DSID)),
                                    DataCell(Text(tableData[index].DSName)),
                                    DataCell(Text(tableData[index].District)),
                                    DataCell(Text(tableData[index].RegisteredDate)),
                                    // DataCell(Text(tableData[index].NoofParticipant)),
                                    // DataCell(Text(tableData[1])),
                                    // DataCell(Text(tableData[2])),
                                    // DataCell(Text(tableData[3])),
                                    DataCell(IconButton(
                                      icon: Icon(Icons.visibility,size: 16),
                                      onPressed: () {
                                        // Handle view action
                                      },
                                    )),
                                    DataCell(IconButton(
                                      icon: Icon(Icons.edit,size: 16),
                                      onPressed: () {
                                        // Handle edit action
                                      },
                                    )),
                                    // DataCell(IconButton(
                                    //   icon: Icon(Icons.thumb_down,size: 16),
                                    //   onPressed: () {
                                    //     // Handle edit action
                                    //   },
                                    // )),
                                    DataCell(
                                        IconButton(
                                          icon: Icon(Icons.delete,size: 16),
                                          onPressed: () {
                                            // Handle delete action
                                          },
                                        )),
                                  ]);
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Handle reverse button press
                      },
                      icon: Icon(Icons.arrow_circle_left_sharp),
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle reverse button press
                      },
                      icon: Transform.rotate(
                        angle: -4.7, // Specify the angle in radians to rotate the icon
                        child: Icon(Icons.arrow_drop_down_circle_sharp), // Icon widget to rotate
                      )
                      ,
                    ),
                    Text("1"),

                    IconButton(
                      onPressed: () {
                        // Handle play button press
                      },
                      icon: Transform.rotate(
                        angle: 4.7, // Specify the angle in radians to rotate the icon
                        child: Icon(Icons.arrow_drop_down_circle_sharp), // Icon widget to rotate
                      )
                      ,
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle reverse button press
                      },
                      icon: Icon(Icons.arrow_circle_right_sharp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class widgets062 extends StatelessWidget{
  widgets062({Key? key}) : super(key: key);
  final TextEditingController _textController =
  TextEditingController(text: 'Flutter Mapp');
  @override
  Widget build (BuildContext context){
    return Container(
      color: CupertinoColors.activeOrange,
      padding: const EdgeInsets.all(10.0),
      child:  Center(
        child: Center(
          child: CupertinoSearchTextField(
            controller: _textController,
          ),
        ),
      ),
    );
  }
}

class DistrictSecretoryModel {
  String serialnumber,DSID,DSName,District,RegisteredDate;

  DistrictSecretoryModel(this.serialnumber, this.DSID,this.DSName,this.District,this.RegisteredDate);

}
