import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/Dashboard.dart';
import 'package:sport_ims/Districtinmaster.dart';
import 'package:sport_ims/Eventraceinmaster.dart';
import 'package:sport_ims/Stateinmaster.dart';
import 'package:sport_ims/main.dart';
class StateApprovel extends StatefulWidget {
  const StateApprovel({super.key});

  @override
  State<StateApprovel> createState() => _StateApprovelState();
}

class _StateApprovelState extends State<StateApprovel> {
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
  List<StateModel> tableData = [
    StateModel("s001", "TNstateCode","TamilNadu","2023"),
    StateModel("s001", "TNstateCode","TamilNadu","2023"),
    StateModel("s001", "TNstateCode","TamilNadu","2023"),
    StateModel("s001", "TNstateCode","TamilNadu","2023"),
    StateModel("s001", "TNstateCode","TamilNadu","2023"),
    StateModel("s001", "TNstateCode","TamilNadu","2023"),
    StateModel("s001", "TNstateCode","TamilNadu","2023"),
    StateModel("s001", "TNstateCode","TamilNadu","2023"),



  ];


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: Text("State Secretary Pending Approvel"),
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
                    // Container(
                    //
                    //   decoration: BoxDecoration(
                    //     color: Color(0xffdde7f9), // Example color, you can change it
                    //     borderRadius: BorderRadius.circular(10), // Adjust border radius as needed
                    //   ),
                    //   child: TextButton.icon(
                    //     onPressed: () {
                    //       // Handle button press
                    //     },
                    //     icon: Icon(
                    //       Icons.add_circle,
                    //       color: Color(0xff276ad5),
                    //     ),
                    //     label: Text(
                    //       'Add',
                    //       style: TextStyle(
                    //         color: Color(0xff276ad5),
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
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
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8, // Set width to 90% of the screen width
                          // height: MediaQuery.of(context).size.height * 0.7, // Set height to 70% of the screen height
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(9),
                              child: DataTable(
                                headingRowHeight: 45,
                                dataRowHeight: 34,
                                columns: [
                                  DataColumn(label: Text('Serial No'), numeric: false),
                                  DataColumn(label: Text(' S ID'), numeric: false),
                                  DataColumn(label: Text('State Name'), numeric: false),
                                  DataColumn(label: Text('Registered Date'), numeric: false),
                                  DataColumn(label: Text('View'), numeric: false),
                                  DataColumn(label: Text('Edit'), numeric: false),
                                  DataColumn(label: Text('Delete'), numeric: false),
                                ],
                                rows: List.generate(tableData.length, (index) {
                                  return DataRow(cells: [
                                    DataCell(Text(tableData[index].serialnumber)),
                                    DataCell(Text(tableData[index].DistrictID)),
                                    DataCell(Text(tableData[index].District)),
                                    DataCell(Text(tableData[index].RegistrationDate)),
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
                                    DataCell(
                                      IconButton(
                                        icon: Icon(Icons.delete,size: 16),
                                        onPressed: () {
                                          // Handle delete action
                                        },
                                      ),
                                    ),
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

class StateModel {
  String serialnumber,DistrictID,District,RegistrationDate;

  StateModel(this.serialnumber, this.DistrictID,this.District,this.RegistrationDate);

}
