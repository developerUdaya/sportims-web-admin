import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/Dashboard.dart';
import 'package:sport_ims/Districtinmaster.dart';
import 'package:sport_ims/main.dart';

class Stateinmaster extends StatefulWidget {
  const Stateinmaster({Key? key}) : super(key: key);

  @override
  State<Stateinmaster> createState() => _StateinmasterState();
}

class _StateinmasterState extends State<Stateinmaster> {
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
  TextEditingController _controller = TextEditingController();
  String dropdownValue = 'Option 1'; // Default dropdown value
  bool _showPrefix = true;
  bool _isSearching = false;
  double _textFieldWidth = 70;
  bool addNewState = false;

  List<StateModel> tableData = [
    StateModel("s001", "TNstateCode"),
    StateModel("s002", "TNstateCode"),
    StateModel("s003", "TNstateCode"),
    StateModel("s004", "TNstateCode"),
    StateModel("s005", "TNstateCode"),
    StateModel("s006", "TNstateCode"),
    StateModel("s007", "TNstateCode"),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("State"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!addNewState)Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffdde7f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          // Handle button press
                          setState(() {
                            addNewState = !addNewState;
                          });
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
                      child: Expanded(child: Container()),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 65),
                      width: _isSearching ? 200 : 0,
                      height: _isSearching ? 35 : 0,
                      padding: _isSearching
                          ? EdgeInsets.symmetric(horizontal: 0, vertical: 0)
                          : EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                  ],
                ),
                if(!addNewState)SizedBox(height: 20),
                if(!addNewState)Expanded(
                  child: ListView(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.73,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: DataTable(
                            headingRowHeight: 45,
                            dataRowHeight: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            columns: [
                              DataColumn(label: Text('Serial No'), numeric: false),
                              DataColumn(label: Text('State Code'), numeric: false),
                              DataColumn(label: Text('View'), numeric: false),
                              DataColumn(label: Text('Edit'), numeric: false),
                              DataColumn(label: Text('Delete'), numeric: false),
                            ],
                            rows: List.generate(tableData.length, (index) {
                              return DataRow(cells: [
                                DataCell(Text(tableData[index].serialnumber)),
                                DataCell(Text(tableData[index].stateCode)),
                                DataCell(IconButton(
                                  icon: Icon(Icons.visibility, size: 16),
                                  onPressed: () {
                                    // Handle view action
                                  },
                                )),
                                DataCell(IconButton(
                                  icon: Icon(Icons.edit, size: 16),
                                  onPressed: () {
                                    // Handle edit action
                                  },
                                )),
                                DataCell(IconButton(
                                  icon: Icon(Icons.delete, size: 16),
                                  onPressed: () {
                                    // Handle delete action
                                  },
                                )),
                              ]);
                            }),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                    ],
                  ),
                ),
                if(!addNewState)SizedBox(height: 20),
                if(!addNewState)Row(
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
                        angle: -4.7,
                        child: Icon(Icons.arrow_drop_down_circle_sharp),
                      ),
                    ),
                    Text("1"),
                    IconButton(
                      onPressed: () {
                        // Handle play button press
                      },
                      icon: Transform.rotate(
                        angle: 4.7,
                        child: Icon(Icons.arrow_drop_down_circle_sharp),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle reverse button press
                      },
                      icon: Icon(Icons.arrow_circle_right_sharp),
                    ),
                  ],
                ),
                if(addNewState)ClipRRect(

                  borderRadius: BorderRadius.circular(20),
                 child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                       crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        SizedBox(height: 10),
                        SizedBox(width: 20),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20,10,10,0), // Adjust the left padding here
                          child: Text(
                            "Add State",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'State',

                                    // border: OutlineInputBorder(),
                                  ),
                                  cursorColor: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'State code',
                                    // border: OutlineInputBorder(),
                                  ),
                                  cursorColor: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [

                              Padding(
                                padding: const EdgeInsets.all(20), // Adjust the padding as needed
                                child: MaterialButton(
                                  onPressed: () {
                                    // Handle save button press
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'Save',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width: 10),
                              MaterialButton(
                                onPressed: () {
                                  // Handle back button press
                                  setState(() {
                                    addNewState = !addNewState;
                                  });
                                },
                                child: Row(
                                  children: [

                                    SizedBox(width: 5),
                                    Text(
                                      'Back',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                              )
                            ]
                        ),
                  ]
                    ),

                ),
                )
                ],

            ),
          ),
        ),

      ),
    );
  }
}

class widgets062 extends StatelessWidget {
  widgets062({Key? key}) : super(key: key);
  final TextEditingController _textController = TextEditingController(text: 'Flutter Mapp');
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.activeOrange,
      padding: const EdgeInsets.all(10.0),
      child: Center(
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
  String serialnumber, stateCode;

  StateModel(this.serialnumber, this.stateCode);
}
