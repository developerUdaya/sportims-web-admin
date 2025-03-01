import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventsParticipation extends StatefulWidget {
  const EventsParticipation({super.key});

  @override
  State<EventsParticipation> createState() => _EventsParticipationState();
}

class _EventsParticipationState extends State<EventsParticipation> {
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
  List<EventparticipandModel> tableData = [
    EventparticipandModel("s001", "1st Erode District Roller\n Skating Championship","Punjai Sports Academy Skating\nRink(100 MTS),Alapalayam\nRoad,Near,Neelipalayam,Punjai,\nPuliampatti-638459","14/10/2023","Finished Event","130"),
    EventparticipandModel("s001", "1st Erode District Roller\n Skating Championship","Punjai Sports Academy Skating\nRink(100 MTS),Alapalayam\nRoad,Near,Neelipalayam,Punjai,\nPuliampatti-638459","14/10/2023","Finished Event","130"),
    EventparticipandModel("s001", "1st Erode District Roller\n Skating Championship","Punjai Sports Academy Skating\nRink(100 MTS),Alapalayam\nRoad,Near,Neelipalayam,Punjai,\nPuliampatti-638459","14/10/2023","Finished Event","130"),
    EventparticipandModel("s001", "1st Erode District Roller\n Skating Championship","Punjai Sports Academy Skating\nRink(100 MTS),Alapalayam\nRoad,Near,Neelipalayam,Punjai,\nPuliampatti-638459","14/10/2023","Finished Event","130"),
    EventparticipandModel("s001", "1st Erode District Roller\n Skating Championship","Punjai Sports Academy Skating\nRink(100 MTS),Alapalayam\nRoad,Near,Neelipalayam,Punjai,\nPuliampatti-638459","14/10/2023","Finished Event","130"),
    EventparticipandModel("s001", "1st Erode District Roller\n Skating Championship","Punjai Sports Academy Skating\nRink(100 MTS),Alapalayam\nRoad,Near,Neelipalayam,Punjai,\nPuliampatti-638459","14/10/2023","Finished Event","130"),
    EventparticipandModel("s001", "1st Erode District Roller\n Skating Championship","Punjai Sports Academy Skating\nRink(100 MTS),Alapalayam\nRoad,Near,Neelipalayam,Punjai,\nPuliampatti-638459","14/10/2023","Finished Event","130"),
    EventparticipandModel("s001", "1st Erode District Roller\n Skating Championship","Punjai Sports Academy Skating\nRink(100 MTS),Alapalayam\nRoad,Near,Neelipalayam,Punjai,\nPuliampatti-638459","14/10/2023","Finished Event","130"),


  ];


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: Text("Skating Participation"),
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
                            // width: MediaQuery.of(context).size.width*0.8,
                            padding: EdgeInsets.all(9),
                            child: Expanded(
                              child: DataTable(
                                headingRowHeight: 45,
                                dataRowHeight: 95,
                                columns: [
                                  DataColumn(label: Text('Serial No',style: TextStyle(fontSize: 14))),
                                  DataColumn(label: Text('Events'), numeric: false),
                                  DataColumn(label: Text('Place'), numeric: false),
                                  DataColumn(label: Text('Date'), numeric: false),
                                  DataColumn(label: Text('Status'), numeric: false),
                                  DataColumn(label: Text('No.of.Participant'), numeric: false),
                                  DataColumn(label: Text('View'), numeric: false),
                                  DataColumn(label: Text('Edit'), numeric: false),
                                  // DataColumn(label: Text('Status'), numeric: false),
                                  DataColumn(label: Text('Delete'), numeric: false),
                                ],
                                rows: List.generate(tableData.length, (index) {
                                  return DataRow(cells: [
                                    DataCell(Text(tableData[index].serialnumber,style: TextStyle(fontSize: 14),)),
                                    DataCell(Text(tableData[index].Events,style: TextStyle(fontSize: 12),)),
                                    DataCell(Text(tableData[index].Place,style: TextStyle(fontSize: 12),)),
                                    DataCell(Text(tableData[index].Date)),
                                    DataCell(Text(tableData[index].Status)),
                                    DataCell(Text(tableData[index].NoofParticipant)),
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

class EventparticipandModel {
  String serialnumber,Events,Place,Date,Status,NoofParticipant;

  EventparticipandModel(this.serialnumber, this.Events,this.Place,this.Date,this.Status,this.NoofParticipant);

}
