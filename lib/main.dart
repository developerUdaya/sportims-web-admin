import 'dart:html';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sport_ims/Dashboard.dart';
import 'package:sport_ims/LoadingScreen.dart';
import 'package:sport_ims/approval/ClubApproval.dart';
import 'package:sport_ims/approval/SkatersApprovel2.dart';
import 'package:sport_ims/models/UserCredentialsModel.dart';
import 'package:sport_ims/services/ClubService.dart';
import 'package:sport_ims/users/AdminUsers.dart';
import 'package:sport_ims/users/ClubsData.dart';
import 'package:sport_ims/users/DistrictSecretaryData.dart';
import 'package:sport_ims/users/StateSecretaryData.dart';
import 'package:sport_ims/users/SkatersUsers.dart';
import 'package:sport_ims/events/Events.dart';
import 'package:sport_ims/Stateinmaster.dart';
import 'package:sport_ims/utils/Colors.dart';

import 'appData/birthday/BirthdaySkatersPage.dart';
import 'appData/gallery/GalleryPage.dart';
import 'appData/news/NewsListPage.dart';
import 'dashboard/DashBoard.dart';
import 'eventOrganiser/EventOrganiserData.dart';
import 'eventReport/EventReportData.dart';
import 'eventReport/PaymentReportData.dart';
import 'events/EventDetailsPage2.dart';
import 'appData/TsetPage.dart';
import 'dialog/UserDetailsPage2.dart';
import 'events/AddEvent.dart';
import 'events/EventRaceForm.dart';
import 'approval/DistrictApproval.dart';
import 'firebase_options.dart';
import 'loginApp/LoginApp.dart';
import 'models/EventRaceModel.dart';
//import 'package:provider/provider.dart';

import 'official/EventOfficialData.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(  MaterialApp(home:  LoginApp()));
}


bool navigation = true;
class MyApp extends StatefulWidget {

  UserCredentials userCredentials;
  MyApp({required this.userCredentials});

  @override
  State<MyApp> createState() => _MyAppState();
}


int index =0;

List pages = [
  DashboardPage(), //0
  LoadingScreen(),       // 1
  LoadingScreen(),    // 2
  LoadingScreen(),   // 3
  LoadingScreen(),    // 4
  ClubApproval(),        // 5
  SkatersApprovel(),          // 6
  LoadingScreen(),        // 7
  ClubsData(),        // 8
  Skaters(),                  // 9
  Events(),   // 10
  LoadingScreen(),      // 11
  LoadingScreen(),            // 12
  LoadingScreen(),                // 13
  LoadingScreen(),           // 14
  NewsListPage(),         // 15
  EventOfficialData(),            // 16
  DistrictSecretaryApproval(),             // 17
  DistrictSecretaryData(),             // 18
  EventOrganiserData(),  //19
  PaymentReportData(), //20
  EventReportData(),   //21
  UserCredentialsPage(), //22
  GalleryPage(), //23
  BirthdaySkatersPage() //24
];


class _MyAppState extends State<MyApp> {
  bool isDashboard = false;
  bool ismaster = false;
  bool isApprovel = false;
  bool isUsers = false;
  bool isEvents = false;
  bool isEventsdetails = false;
  bool isOfficial = false;
  bool isEventOrganizer = false;
  bool isAppdata = false;
  bool isAdminUser = false;

  static const Color bgLightBlue =  Color(0xffe3ecfa);
  static const Color bgDarkBlue = Color(0xffcbdcf7);

  late Color isDashboardColor = bgLightBlue, ismasterColor = bgLightBlue,isApprovelColor = bgLightBlue,isEventsColor = bgLightBlue,isUsersColor= bgLightBlue, isEventsdetailsColor = bgLightBlue,isOfficialColor = bgLightBlue,isEventOrganizerColor=bgLightBlue,isAppDataColor=bgLightBlue, isAdminUserColor = bgLightBlue;

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
      isAdminUserColor = isAdminUser? bgDarkBlue : bgLightBlue;
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
                SizedBox(height: 10),
                Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                    width: 250,
                    color: Color(0xffe3ecfa),
                      child: Center(
                        child: SizedBox(

                        child: Text(widget.userCredentials.name??'',style: TextStyle(
                            color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                        ))
                                          ),
                      ),
                        ),
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
                                Container(
                                  color: isEventOrganizerColor,
                                  child: Column(
                                    children: [

                                      if (isEventOrganizer)
                                        Column(
                                            children: [
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              // ),
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              // ),
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              //
                                              // ),
                                            ]

                                        )],
                                  ),
                                ),


                                //DashBoard
                                Container(
                                  color: isDashboardColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        child: MaterialButton(
                                          child: Row(
                                            children: [
                                              // Reduce the size of the icon and change its color
                                              Icon(Icons.dashboard, size: 20, color: Color(0xffb0ccf8)),
                                              SizedBox(width: 8,),
                                              Text(
                                                "Dashboard",
                                                style: TextStyle(
                                                  color: Color(0xff244c8c),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              // Expanded(child: SizedBox()),
                                              // Icon(Icons.arrow_drop_down),
                                              // SizedBox(width: 16),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              isDropdownOpen = !isDropdownOpen;
                                              isDropdownOpen = false;
                                              isDropdownOpen1 = false;
                                              isDropdownOpen2 = false;
                                              isDropdownOpen3 = false;
                                              isDropdownOpen4 = false;
                                              isDropdownOpen5 = false;
                                              isDropdownOpen6 = false;
                                            });
                                            _toggleItem("Dashboard");
                                            changePageIndex(0);
                                          },
                                          hoverColor: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //Master
                                if(false)Container(
                                  color: ismasterColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        child: MaterialButton(
                                          child: Row(
                                            children: [
                                              // Reduce the size of the icon and change its color
                                              Icon(Icons.extension, size: 20, color: Color(0xffb0ccf8)),
                                              SizedBox(width: 8,),
                                              Text(
                                                "Master",
                                                style: TextStyle(
                                                  color: Color(0xff244c8c),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Expanded(child: SizedBox()),
                                              // You can keep the dropdown icon as is
                                              Icon(isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                                              SizedBox(width: 16),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              isDropdownOpen = !isDropdownOpen;
                                              isDropdownOpen1 = false;
                                              isDropdownOpen2 = false;
                                              isDropdownOpen3 = false;
                                              isDropdownOpen4 = false;
                                              isDropdownOpen5 = false;
                                              isDropdownOpen6 = false;
                                            });
                                            _toggleItem("Master");
                                          },
                                          hoverColor: Colors.blueAccent,
                                        ),
                                      ),

                                      if (ismaster)
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 30,
                                              child: MaterialButton(
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 10),
                                                    Icon(Icons.home, size: 20, color: Colors.black),
                                                    Text("State"),
                                                  ],
                                                ),
                                                onPressed: (){
                                                  changePageIndex(1);
                                                },
                                                hoverColor: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: MaterialButton(
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 10),
                                                    Icon(Icons.person, size: 20, color: Colors.black), // Reduce the size and change color
                                                    Text("District"),
                                                  ],
                                                ),
                                                onPressed: (){
                                                  changePageIndex(2);
                                                },
                                                hoverColor: Colors.white,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 30,
                                              child: MaterialButton(
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 10),
                                                    Icon(Icons.roller_skating, size: 20, color: Colors.black), // Reduce the size and change color
                                                    Text("Event Race"),
                                                  ],
                                                ),
                                                onPressed: (){
                                                  changePageIndex(16);
                                                },
                                                hoverColor: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),

                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //AppData
                                Container(
                                  color: isAppDataColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.cable,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("App Data",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                Icon(isDropdownOpen7 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen1 = false;
                                                isDropdownOpen = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen5 = false;
                                                isDropdownOpen6 = false;

                                                isDropdownOpen7 = !isDropdownOpen7;

                                              });
                                              _toggleItem("App Data");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),

                                      if (isAppdata)
                                        Column(
                                            children: [

                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.image, size: 20, color: Colors.black),
                                                        Text("Gallery",)
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(23);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )
                                              ),
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.shopping_bag, size: 20, color: Colors.black),
                                                        Text("News")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(15);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )
                                              ),
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.cake, size: 20, color: Colors.black),
                                                        Text("Birthday")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(24);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )

                                              ),
                                            ]

                                        )],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //Approval
                                Container(
                                  color: isApprovelColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.file_open,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Approvel",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                Icon(isDropdownOpen1 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen1 = !isDropdownOpen1;
                                                isDropdownOpen = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen5 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              _toggleItem("Approvels");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),

                                      if (isApprovel)
                                        Column(
                                            children: [

                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.home, size: 20, color: Colors.black),
                                                        Text("District Approvel")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(17);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )
                                              ),
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.shopping_bag, size: 20, color: Colors.black),
                                                        Text("Club Approvel")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(5);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )
                                              ),
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.roller_skating, size: 20, color: Colors.black),
                                                        Text("Skaters Approvel")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(6);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )

                                              ),
                                            ]

                                        )],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),
                                Container(
                                  color: isUsersColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.face,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Users",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                Icon(isDropdownOpen2 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen2 = !isDropdownOpen2;
                                                isDropdownOpen = false;
                                                isDropdownOpen1 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen5 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              _toggleItem("Users");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),

                                      if (isUsers)
                                        Column(
                                            children: [
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.home, size: 20, color: Colors.black),
                                                        Text("District Secretary User")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(18);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )
                                              ),
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.shopping_bag, size: 20, color: Colors.black),
                                                        Text("Club Users")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(8);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )
                                              ),
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.roller_skating, size: 20, color: Colors.black),
                                                        Text("Skaters Users")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(9);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )

                                              ),
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.admin_panel_settings, size: 20, color: Colors.black),
                                                        Text("Admin Users Credentials")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(22);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )

                                              ),
                                            ]

                                        )],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

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

                                                Text("Events",style: TextStyle(
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
                                              changePageIndex(10);

                                              _toggleItem("Events");

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

                                //Events Details
                                Container(
                                  color: isEventsdetailsColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.menu_outlined,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Events Details",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                Icon(isDropdownOpen4 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen4 = !isDropdownOpen4;
                                                isDropdownOpen = false;
                                                isDropdownOpen1 = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen5 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              _toggleItem("Events Details");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),

                                      if (isEventsdetails)
                                        Column(
                                            children: [
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.event, size: 20, color: Colors.black),
                                                        Text("Event Participation")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(21);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )
                                              ),
                                              SizedBox(
                                                  height: 30,
                                                  child: MaterialButton(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width: 10),
                                                        Icon(Icons.payment, size: 20, color: Colors.black),
                                                        Text("Payment Report")
                                                      ],
                                                    ),
                                                    onPressed: (){
                                                      changePageIndex(20);
                                                    },
                                                    hoverColor: Colors.white,
                                                  )
                                              ),
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              //
                                              // ),
                                            ]

                                        )],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //Official
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

                                                Text("Official",style: TextStyle(
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
                                              changePageIndex(16);
                                              _toggleItem("Official");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),

                                      if (isOfficial)
                                        Column(
                                            children: [
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              // ),
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              // ),
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              //
                                              // ),
                                            ]

                                        )],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),
                                Container(
                                  color: isEventOrganizerColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.perm_identity,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("EventOrganizer",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                // Icon(isDropdownOpen6 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 19,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen6 = !isDropdownOpen6;
                                                isDropdownOpen = false;
                                                isDropdownOpen1 = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen5 = false;
                                              });
                                              changePageIndex(19);
                                              _toggleItem("EventOrganizer");

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),

                                      if (isEventOrganizer)
                                        Column(
                                            children: [
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              // ),
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              // ),
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              //
                                              // ),
                                            ]

                                        )],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),
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

                                      if (isEventOrganizer)
                                        Column(
                                            children: [
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              // ),
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              // ),
                                              // SizedBox(
                                              //     height: 30,
                                              //     child: MaterialButton(
                                              //       child: Row(
                                              //         children: [
                                              //           SizedBox(width: 10),
                                              //           Icon(Icons.add),
                                              //           Text("Data")
                                              //         ],
                                              //       ),
                                              //       onPressed: (){},
                                              //       hoverColor: Colors.white,
                                              //     )
                                              //
                                              // ),
                                            ]

                                        )],
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




