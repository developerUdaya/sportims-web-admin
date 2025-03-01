import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/LoadingScreen.dart';
import 'package:sport_ims/clubApp/ClubDetailsPage.dart';
import 'package:sport_ims/clubApp/ParticipantsListPage.dart';
import 'package:sport_ims/clubApp/SkatersUsers.dart';
import 'package:sport_ims/models/PublishedData.dart';
import 'package:sport_ims/models/UserCredentialsModel.dart';
import 'package:sport_ims/officialApp/AddEventSchedule.dart';
import 'package:sport_ims/officialApp/EventPositionUpdateData.dart';
import 'package:sport_ims/officialApp/EventScheduleData.dart';
import 'package:sport_ims/officialApp/OfficialEventOrganiserData.dart';
import 'package:sport_ims/officialApp/PublishResults.dart';
import 'package:sport_ims/officialApp/ReportsData.dart';

import '../Dashboard.dart';

import '../firebase_options.dart';
import '../loginApp/LoginApp.dart';
import '../models/ClubsModel.dart';
import '../models/EventModel.dart';
import 'ClubSkaters.dart';
import 'EventsData.dart';

bool navigation = true;
class ClubApp extends StatefulWidget {
  UserCredentials credentials;

  ClubApp({required this.credentials});

  @override
  State<ClubApp> createState() => _ClubAppState();
}


class _ClubAppState extends State<ClubApp> {

  int index =3;
  List pages = [];

  Club? club;

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


  @override
  void initState() {

    super.initState();
    _getClubs();
  }

  Future<void> _getClubs() async {
    List<Club> fetchedClubs = await getClubs();
    setState(() {
    club = fetchedClubs.firstWhere((element) => element.id==widget.credentials.username);
    pages= [
      LoadingScreen(),                                  //0
      ClubSkaters(clubName: club!.clubName)  ,   //1
      ClubDetailsPage(club: club!, updateClubApproval: (Club ) {  },),//2
      EventsData(), //3,
      ParticipantsListPage(clubName: club!.clubName) //4
    ];

    });
  }

  Future<List<Club>> getClubs() async {
    List<Club> clubs = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('clubs');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        Club club = Club.fromJson(Map<String, dynamic>.from(child.value as Map));
        clubs.add(club);
        print(club.clubName);
      }
    }
    return clubs;
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
                  backgroundColor: Color(0xfff5f6fa),

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
          color: Color(0xfff5f6fa),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView(

              scrollDirection: Axis.vertical,
              children: [

                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color:  Colors.blue[700],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // SizedBox(width: 30),
                      Expanded(
                        child: Center(
                          child: Container(
                            height: 38,
                            child: Image.asset('assets/logo.jpg'),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.dehaze_sharp,color: Colors.white,),
                        onPressed: () {
                          setState(() {
                            navigation = !navigation;
                          });
                        },
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 10),
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

                                //Events
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

                                                Text("Dashboard",style: TextStyle(
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
                                              changePageIndex(3);

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

                                //Skaters
                                Container(
                                  color: isOfficialColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.sports_handball,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Skaters",style: TextStyle(
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
                                              changePageIndex(1);
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

                                //Event Report
                                Container(
                                  color: isOfficialColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.file_copy,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Event Report",style: TextStyle(
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

                                //Profile
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

                                                Text("Profile",style: TextStyle(
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




