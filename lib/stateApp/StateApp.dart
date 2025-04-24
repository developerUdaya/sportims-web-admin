import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/LoadingScreen.dart';
import 'package:sport_ims/clubApp/SkatersUsers.dart';
import 'package:sport_ims/models/StateSecretaryModel.dart';
import 'package:sport_ims/stateApp/StateClubsParticipantsPage.dart';
import 'package:sport_ims/stateApp/StateClubsSkatersPage.dart';
import 'package:sport_ims/stateApp/StateSecretaryDetails.dart';
import '../loginApp/LoginApp.dart';
import '../clubApp/EventsData.dart';
import '../firebase_options.dart';
import '../models/UserCredentialsModel.dart';


bool navigation = true;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(  MaterialApp(home:  StateApp()));
}


class StateApp extends StatefulWidget {
  // UserCredentials credentials;

  // StateApp({ this.credentials});

  @override
  State<StateApp> createState() => _DistrictAppState();
}


class _DistrictAppState extends State<StateApp> {

  int index =3;
  List pages = [];

  StateSecretaryModel? stateSecretaryModel;

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
    _getDistrictSecretaries();
  }


  Future<void> _getDistrictSecretaries() async {
    List<StateSecretaryModel> fetchedSecretaries = await getDistrictSecretaries();
    stateSecretaryModel = StateSecretaryModel(address: 'VGN Nagar , Chennai', adharNumber: '14212687268812', approval: 'Approved', contactNumber: '9944758128', createdAt: '', docUrl: '', email: 'test@gmail.com', id: 'test', name: 'test', password: '', regDate: '', societyCertNumber: 'test', societyCertUrl: 'test.png', stateName: 'Tamil Nadu', updatedAt: '');
    // stateSecretaryModel = fetchedSecretaries.firstWhere((element) => element.id==widget.credentials.username);
    setState(() {
      pages= [
        LoadingScreen(),                                  //0
        Skaters(clubName: stateSecretaryModel!.stateName)  ,   //1
        StateSecretaryDetailsPage( stateSecretary: stateSecretaryModel!, updatestateSecretaryApproval: (StateSecretaryModel ) {  },),//2
        EventsData(), //3,//Used from ClubAPP
        StateClubsParticipantsPage(stateName: stateSecretaryModel!.stateName,),
        StateClubsSkatersPage(stateName: stateSecretaryModel!.stateName)
      ];
    });
  }

  Future<List<StateSecretaryModel>> getDistrictSecretaries() async {
    List<StateSecretaryModel> secretaries = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('stateSecretaries');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        StateSecretaryModel secretary = StateSecretaryModel.fromJson(
            Map<String, dynamic>.from(child.value as Map));
        secretaries.add(secretary);
        print(secretary.name);
      }
    }
    return secretaries;
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

                                //Dashboard
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
                                                Icon(Icons.file_copy_outlined,size: 20,color:Color(0xffb0ccf8)),
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

                                //Clubs Report
                                Container(
                                  color: isOfficialColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.meeting_room,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Clubs Report",style: TextStyle(
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
                                //
                                // //Skaters
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
                                //                 Text("Skaters",style: TextStyle(
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
                                //               changePageIndex(1);
                                //               _toggleItem("Position Update");
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




