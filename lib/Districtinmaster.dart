import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/Dashboard.dart';
import 'package:sport_ims/Eventraceinmaster.dart';
import 'package:sport_ims/Stateinmaster.dart';
import 'package:sport_ims/main.dart';

class Districtinmaster extends StatefulWidget {
  const Districtinmaster({super.key});

  @override
  State<Districtinmaster> createState() => _DistrictinmasterState();
}

class _DistrictinmasterState extends State<Districtinmaster> {
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
  String selectedState = 'State A';
  double _textFieldWidth = 70;
  bool addNewState = false;

  List<DistrictModel> tableData = [
    DistrictModel("001","Tamilnadu","Ariyalur","AR"),
    DistrictModel("002","Tamilnadu", "Chennai","CH"),
    DistrictModel("003","Tamilnadu", "Chengalpattu","CGL"),
    DistrictModel("004","Tamilnadu", "Coimbatore","CO"),
    DistrictModel("005","Tamilnadu", "Kanchipuram","KC"),
    DistrictModel("006","Tamilnadu", "Cuddalore","CU"),
    DistrictModel("007","Tamilnadu", "Dharmapuri","DH"),



  ];



  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(
        appBar: AppBar(
          title: Text("District"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.only(top: 20, left: 20,right: 20,bottom: 10), // Add space from top and left
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!addNewState) Row(
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
                          // Handle button press
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
                  ],
                ),
                if(!addNewState) SizedBox(height: 20),
                if(!addNewState) Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8, // Set width to 90% of the screen width
                      child: Expanded(
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
                                DataColumn(label: Text('State '), numeric: false),
                                DataColumn(label: Text('District'), numeric: false),
                                DataColumn(label: Text('District code'), numeric: false),
                                DataColumn(label: Text('View'), numeric: false),
                                DataColumn(label: Text('Edit'), numeric: false),
                                DataColumn(label: Text('Delete'), numeric: false),
                              ],
                              rows: List.generate(tableData.length, (index) {
                                return DataRow(cells: [
                                  DataCell(Text(tableData[index].serialnumber)),
                                  DataCell(Text(tableData[index].State)),
                                  DataCell(Text(tableData[index].District)),
                                  DataCell(Text(tableData[index].DistrictCode)),
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
                                  )
                                  ),
                                ]
                                );
                              }),
                            ),
                          ),
                        ),
                      ),

                    ),
                  ),
                ),



                if(!addNewState) Row(
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
                if(addNewState)ClipRRect(
                  borderRadius: BorderRadius.circular(10),
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
                            padding: const EdgeInsets.fromLTRB(20,20, 10, 0), // Adjust the left padding here
                            child: Text(
                              "Add District",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 300,
                                child: Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(50,20,20, 20),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'District',
                                        // border: OutlineInputBorder(),
                                      ),
                                      cursorColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ),


                              Container(
                                width: 300,
                                child: Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(50,20,20, 20),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'District code',
                                        // border: OutlineInputBorder(),
                                      ),
                                      cursorColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                padding: EdgeInsets.fromLTRB(50, 5,0, 0),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'States', // Text to display above the dropdown button
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      // Adding some space between text and dropdown button
                                      Container(
                                          width: 250,
                                          child: Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(0, 5,0, 0),
                                                child: Container(
                                                  width: 300,
                                                  child: DropdownButton<String>(
                                                    value: dropdownValue,
                                                    icon: Icon(Icons.arrow_drop_down),
                                                    onChanged: (String? newValue) {
                                                      setState(() {
                                                        dropdownValue = newValue!;
                                                      });
                                                    },
                                                    // Here's where you replace the options with a text
                                                    items: <String>[
                                                      'Choose an option', // Text displayed when no option is selected
                                                      'Option 1',
                                                      'Option 2',
                                                      'Option 3',
                                                      'Option 4'
                                                    ].map<DropdownMenuItem<String>>((String value) {
                                                      return DropdownMenuItem<String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              )
                                          )
                                      ),
                                    ] ),


                              )],
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
     ]             ),
                )
                )        ],
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

class DistrictModel {
  String serialnumber,State,District,DistrictCode;

  DistrictModel(this.serialnumber, this.State,this.District,this.DistrictCode);

}
