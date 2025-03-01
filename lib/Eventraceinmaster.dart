import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Eventraceinmaster extends StatefulWidget {
  const Eventraceinmaster({Key? key});

  @override
  State<Eventraceinmaster> createState() => _EventraceinmasterState();
}

class _EventraceinmasterState extends State<Eventraceinmaster> {
  List<Widget> raceFields = [];

  List<TextEditingController> _controllers = [];


  String dropdownValue = 'Option 1'; // Default dropdown value
  bool _showPrefix = true;
  bool _isSearching = false;
  double _textFieldWidth = 70;
  bool addNewState = false;
  List<EventraceModel> tableData = [
    EventraceModel("001", "1st Erode District Roller Skating \nChampionship"),
    EventraceModel("001", "Virudhunagar District speed roller \nchampionship"),
    EventraceModel("001", "Thoothukudi District speed roller \nChampionship"),
    EventraceModel("001", "TestEvent - Please dint login"),
    EventraceModel("001", "Chengalpet district roller Skating \nChampionship"),
    EventraceModel("001", "Chennai speed 2023"),
    EventraceModel("001", "Coimbatore district roller skating\nChampionship"),
  ];

  @override
  void initState() {
    super.initState();
    // Initially add one text field
    _controllers.add(TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Event Race"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.only(
                top: 20, left: 20, right: 20, bottom: 10), // Add space from top and left
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!addNewState)
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffdde7f9), // Example color, you can change it
                          borderRadius: BorderRadius.circular(10), // Adjust border radius as needed
                        ),
                        child: TextButton.icon(
                          onPressed: () {
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
                          child: Expanded(child: Container())),
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
                if (!addNewState) SizedBox(height: 20),
                if (!addNewState)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context)
                            .size
                            .width *
                            0.8, // Set width to 90% of the screen width
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(9),
                            child: DataTable(
                              headingRowHeight: 45,
                              dataRowHeight: 45,
                              columns: [
                                DataColumn(label: Text('Serial No'), numeric: false),
                                DataColumn(label: Text('Event Name'), numeric: false),
                                DataColumn(label: Text('View'), numeric: false),
                                DataColumn(label: Text('Edit'), numeric: false),
                                DataColumn(label: Text('Delete'), numeric: false),
                              ],
                              rows: List.generate(tableData.length, (index) {
                                return DataRow(cells: [
                                  DataCell(Text(tableData[index].serialnumber)),
                                  DataCell(Text(tableData[index].EventName)),
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
                      ),
                    ),
                  ),
                if (!addNewState)
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
                if (addNewState)
                  Expanded(
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 0),
                                  child: GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 0, // Adjust this value as needed
                                      mainAxisSpacing: 0,
                                    ),
                                    itemCount: _controllers.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextField(
                                          controller: _controllers[index],
                                          decoration: InputDecoration(
                                            labelText: 'Text Field ${index + 1}',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MaterialButton(
                                      onPressed: _addTextField,
                                      child: Text('Add Text Field'),
                                    ),
                                    SizedBox(width: 20),
                                    MaterialButton(
                                      onPressed: _removeTextField,
                                      child: Text('Remove Text Field'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addTextField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeTextField() {
    setState(() {
      if (_controllers.length > 1) {
        _controllers.removeLast();
      }
    });
  }

  @override
  void dispose() {
    // Clean up controllers
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}

class EventraceModel {
  String serialnumber, EventName;

  EventraceModel(this.serialnumber, this.EventName);
}

void main() {
  runApp(MaterialApp(
    home: Eventraceinmaster(),
  ));
}
