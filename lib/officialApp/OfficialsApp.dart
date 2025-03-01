import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/LoadingScreen.dart';
import 'package:sport_ims/models/PublishedData.dart';
import 'package:sport_ims/models/UserCredentialsModel.dart';
import 'package:sport_ims/officialApp/AddEventSchedule.dart';
import 'package:sport_ims/officialApp/EventPositionUpdateData.dart';
import 'package:sport_ims/officialApp/EventScheduleData.dart';
import 'package:sport_ims/officialApp/OfficialEventOrganiserData.dart';
import 'package:sport_ims/officialApp/PublishResults.dart';
import 'package:sport_ims/officialApp/ReportsData.dart';

import '../Dashboard.dart';
import '../loginApp/LoginApp.dart';
import '../firebase_options.dart';
import '../models/EventModel.dart';
import 'ParticipantsData.dart';



bool navigation = true;
class OfficialsApp extends StatefulWidget {
  UserCredentials credentials;

  OfficialsApp({required this.credentials});

  @override
  State<OfficialsApp> createState() => _OfficialsAppState();
}


class _OfficialsAppState extends State<OfficialsApp> {

  int index =2;
  List pages = [];
  EventModel? eventModel;

  bool isDashboard = false;
  bool ismaster = false;
  bool isApprovel = false;
  bool isUsers = false;
  bool isEvents = false;
  bool isEventsdetails = false;
  bool isOfficial = false;
  bool isEventOrganizer = false;
  bool isAppdata = false;

  static const Color bgLightBlue =  Color(0xffe3ecfa);
  static const Color bgDarkBlue = Color(0xffcbdcf7);

  late Color isDashboardColor = bgLightBlue, ismasterColor = bgLightBlue,isApprovelColor = bgLightBlue,isEventsColor = bgLightBlue,isUsersColor= bgLightBlue, isEventsdetailsColor = bgLightBlue,isOfficialColor = bgLightBlue,isEventOrganizerColor=bgLightBlue,isAppDataColor=bgLightBlue;

  void _toggleItem(String itemName) {
    setState(() {
      isDashboard = itemName == 'Dashboard' ? !isDashboard : false;
      ismaster = itemName == 'Master' ? !ismaster : false;
      isApprovel = itemName == 'Approvels' ? !isApprovel : false;
      isUsers = itemName == 'Users' ? !isUsers : false;
      isEvents = itemName == 'Events' ? !isEvents : false;
      isEventsdetails = itemName == 'Events Details' ? !isEventsdetails : false;
      isOfficial = itemName == 'Official' ? !isOfficial : false;
      isEventOrganizer = itemName == 'EventOganizer' ? !isEventOrganizer : false;
      isAppdata = itemName== 'App Data' ? !isAppdata : false;

      isDashboardColor = isDashboard ? bgDarkBlue : bgLightBlue;
      ismasterColor = ismaster  ? bgDarkBlue : bgLightBlue;
      isApprovelColor = isApprovel  ? bgDarkBlue : bgLightBlue;
      isUsersColor = isUsers  ? bgDarkBlue : bgLightBlue;
      isEventsColor = isEvents ? bgDarkBlue : bgLightBlue;
      isEventsdetailsColor = isEventsdetails ? bgDarkBlue : bgLightBlue;
      isOfficialColor = isOfficial? bgDarkBlue : bgLightBlue;
      isEventOrganizerColor = isEventOrganizer? bgDarkBlue : bgLightBlue;
      isAppDataColor = isAppdata? bgDarkBlue : bgLightBlue;
    });
  }


  bool isDropdownOpen = false;
  bool isDropdownOpen1 = false;
  bool isDropdownOpen2 = false;
  bool isDropdownOpen3 = false;
  bool isDropdownOpen4 = false;
  bool isDropdownOpen5 = false;
  bool isDropdownOpen6 = false;
  bool isDropdownOpen7 = false;

  Future<EventModel> fetchEventModelFromFirebase(String eventId) async {
    DatabaseReference eventRef =
    FirebaseDatabase.instance.ref().child('events/pastEvents').child(eventId);

    try {
      // Fetch data from Firebase
      DataSnapshot dataSnapshot = await eventRef.get();

      if (dataSnapshot.exists) {
        // Convert fetched data to Map<String, dynamic>
        print(dataSnapshot.value);
        Map<String, dynamic> eventData = Map<String, dynamic>.from(dataSnapshot.value as Map);

        // Parse eventData to EventModel using fromJson method
        EventModel eventModel = EventModel.fromJson(eventData);

        setState(() {
          this.eventModel = eventModel;
          pages= [
              LoadingScreen(),                                  //0
              Dashboard(),                                      //1
              EventScheduleData(eventModel: eventModel,),       //2
              EventPositionUpdateData(eventModel: eventModel,), //3
              ParticipantsData( eventParticipants: eventModel.eventParticipants,),//4
              ReportsData(eventModel: eventModel), //5,
              PublishDataPage(eventModel: eventModel,) ,  //6,
              OfficialEventOrganiserData(eventModel: eventModel)  //7
          ];

        });

        return eventModel;
      } else {
        throw Exception('Event not found in Firebase');
      }
    } catch (e) {
      // Handle any errors that might occur during the fetch
      throw Exception('Failed to load event: $e');
    }
  }

  @override
  void initState() {

    super.initState();
    fetchEventModelFromFirebase(widget.credentials.eventId!);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              navigation?leftSide(context):Container(
                width: 50,
                child: Scaffold(

                  appBar:AppBar(
                    backgroundColor: Color(0xffb0ccf8),
                    leading: IconButton(
                      icon: Icon(
                        Icons.dehaze_sharp,
                      ),

                      onPressed: (){
                        setState(() {
                          navigation = !navigation;
                        });
                      },
                    ),
                  ),
                  backgroundColor:  Color(0xffcbdcf7),

                ),
              ),
              Expanded(
                child: pages[index],
              ),
            ],
          ),
        )
    );
  }


  @override
  Widget leftSide(BuildContext context) {
    return Row(
      children: [
        if(!navigation)Container(
          child: IconButton(
            onPressed: () {
              setState(() {
                navigation = !navigation;
              });
            },
            icon: Icon(Icons.arrow_forward_ios),
          ),
        ),
        if(navigation)Container(
          width: 300,
          color: Colors.white70,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView(

              scrollDirection: Axis.vertical,
              children: [

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 30,
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          height: 38,
                          child: Image.asset('assets/logo.jpg'),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.dehaze_sharp),
                      onPressed: () {
                        // Add your onPressed functionality here\
                        setState(() {
                          navigation = !navigation;
                        });
                      },
                    ),
                  ],
                ),
                // Divider(
                //   color: Colors.grey,
                // ),
                SizedBox(height: 30),
                Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                          width: 250,
                          color: Color(0xffe3ecfa),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [

                                //Schedule Create
                                Container(
                                  color: isEventsColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.extension,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Schedule Create",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                // Icon(isDropdownOpen3 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen3 = !isDropdownOpen3;
                                                isDropdownOpen = false;
                                                isDropdownOpen1 = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen5 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              changePageIndex(2);

                                              _toggleItem("Schedule Create");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //Position Update
                                Container(
                                  color: isOfficialColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.message,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Position Update",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                // Icon(isDropdownOpen5 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen5 = !isDropdownOpen5;
                                                isDropdownOpen = false;
                                                isDropdownOpen1 = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              changePageIndex(3);
                                              _toggleItem("Position Update");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //Publish
                                Container(
                                  color: isEventsColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.extension,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Publish",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                // Icon(isDropdownOpen3 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen3 = !isDropdownOpen3;
                                                isDropdownOpen = false;
                                                isDropdownOpen1 = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen5 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              changePageIndex(6);

                                              _toggleItem("Publish");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //Participation
                                Container(
                                  color: isOfficialColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.message,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Participation",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                // Icon(isDropdownOpen5 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen5 = !isDropdownOpen5;
                                                isDropdownOpen = false;
                                                isDropdownOpen1 = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              changePageIndex(4);
                                              _toggleItem("Position Update");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //Report
                                Container(
                                  color: isOfficialColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.message,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Report",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                // Icon(isDropdownOpen5 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen5 = !isDropdownOpen5;
                                                isDropdownOpen = false;
                                                isDropdownOpen1 = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              changePageIndex(5);
                                              _toggleItem("Report");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),
                                    ],
                                  ),
                                ),

                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                // //Event Organisers
                                // Container(
                                //   color: isOfficialColor,
                                //   child: Column(
                                //     children: [
                                //       SizedBox(
                                //           height: 40,
                                //           child: MaterialButton(
                                //             child: Row(
                                //               children: [
                                //                 Icon(Icons.message,size: 20,color:Color(0xffb0ccf8)),
                                //                 SizedBox(width: 8,),
                                //
                                //                 Text("Event Organisers",style: TextStyle(
                                //                     color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                //                 )),Expanded(child: SizedBox()),
                                //                 // Icon(isDropdownOpen5 ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                                //
                                //                 SizedBox(width: 16,)
                                //               ],
                                //
                                //             ),
                                //
                                //             onPressed: (){
                                //               setState(() {
                                //                 isDropdownOpen5 = !isDropdownOpen5;
                                //                 isDropdownOpen = false;
                                //                 isDropdownOpen1 = false;
                                //                 isDropdownOpen2 = false;
                                //                 isDropdownOpen3 = false;
                                //                 isDropdownOpen4 = false;
                                //                 isDropdownOpen6 = false;
                                //               });
                                //               changePageIndex(7);
                                //               _toggleItem("Event Organisers");
                                //
                                //             },
                                //             hoverColor: Colors.blueAccent,
                                //           )
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // Divider(
                                //   color: Colors.white,
                                //   height: 0,
                                // ),

                                //Logout
                                Container(
                                  color: isEventOrganizerColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.logout,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Logout",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                // Icon(isDropdownOpen6 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 19,)
                                              ],

                                            ),

                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(builder: (context) => LoginApp()),
                                              );
                                            },

                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),
                                    ],
                                  ),
                                ),

                              ])

                      ),

                    )) ],
            ),
          ),
        ),
      ],
    );
  }

  void changePageIndex(int i) {
    setState(() {
      index = i;
    });
  }
}




