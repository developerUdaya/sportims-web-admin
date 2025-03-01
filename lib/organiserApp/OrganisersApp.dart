import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../LoadingScreen.dart';
import '../firebase_options.dart';
import '../loginApp/LoginApp.dart';
import '../models/EventModel.dart';
import 'DistrictParticipantsData.dart';
import 'ClubParticipantsData.dart';
import '../models/UserCredentialsModel.dart';

bool navigation = true;



class OrganisersApp extends StatefulWidget {
  final UserCredentials credentials;

  OrganisersApp({required this.credentials});

  @override
  State<OrganisersApp> createState() => _OrganisersAppState();
}

class _OrganisersAppState extends State<OrganisersApp> {
  int index = 1;
  List pages = [];
  EventModel? eventModel;

  bool isDashboard = false;
  bool isDistricts = false;
  bool isClubs = false;

  static const Color bgLightBlue = Color(0xffcee1fa);
  static const Color bgDarkBlue = Color(0xffcbdcf7);

  late Color isDashboardColor = bgLightBlue,
      isDistrictsColor = bgLightBlue,
      isClubsColor = bgLightBlue;

  void _toggleItem(String itemName) {
    setState(() {
      isDashboard = itemName == 'Dashboard' ? !isDashboard : false;
      isDistricts = itemName == 'Districts' ? !isDistricts : false;
      isClubs = itemName == 'Clubs' ? !isClubs : false;

      isDashboardColor = isDashboard ? bgDarkBlue : bgLightBlue;
      isDistrictsColor = isDistricts ? bgDarkBlue : bgLightBlue;
      isClubsColor = isClubs ? bgDarkBlue : bgLightBlue;
    });
  }

  Future<EventModel> fetchEventModelFromFirebase(String eventId) async {
    DatabaseReference eventRef =
    FirebaseDatabase.instance.ref().child('events/pastEvents').child(eventId);

    try {
      DataSnapshot dataSnapshot = await eventRef.get();

      if (dataSnapshot.exists) {
        Map<String, dynamic> eventData = Map<String, dynamic>.from(dataSnapshot.value as Map);
        EventModel eventModel = EventModel.fromJson(eventData);

        setState(() {
          this.eventModel = eventModel;
          pages = [
            LoadingScreen(), // 0
            DistrictParticipantsData(eventParticipants: eventModel.eventParticipants, name: widget.credentials.name!,), // 1
            ClubParticipantsData(eventParticipants: eventModel.eventParticipants,club:  widget.credentials.name!,), // 2
          ];
        });

        return eventModel;
      } else {
        throw Exception('Event not found in Firebase');
      }
    } catch (e) {
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
            navigation
                ? leftSide(context)
                : Container(
              width: 50,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.blue[700],
                  leading: IconButton(
                    icon: Icon(
                      Icons.dehaze_sharp,
                    ),
                    onPressed: () {
                      setState(() {
                        navigation = !navigation;
                      });
                    },
                  ),
                ),
                backgroundColor: Colors.blue[700],

              ),
            ),
            Expanded(
              child: pages.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : pages[index],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget leftSide(BuildContext context) {
    return Row(
      children: [
        if (!navigation)
          Container(
            child: IconButton(
              onPressed: () {
                setState(() {
                  navigation = !navigation;
                });
              },
              icon: Icon(Icons.arrow_forward_ios),
            ),
          ),
        if (navigation)
          Container(
            width: 300,
            color: Color(0xffe3ecfa),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  // SizedBox(height: 10),
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
                            // District Participants
                            Container(
                              color: isDistrictsColor,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: MaterialButton(
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_city, size: 20, color: Color(0xffb0ccf8)),
                                          SizedBox(width: 8),
                                          Text("Districts",
                                              style: TextStyle(
                                                  color: Color(0xff244c8c),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400)),
                                          Expanded(child: SizedBox()),
                                          SizedBox(width: 16),
                                        ],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          changePageIndex(1);
                                        });
                                        _toggleItem("Districts");
                                      },
                                      hoverColor: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(color: Colors.white, height: 0),

                            // Club Participants
                            Container(
                              color: isClubsColor,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: MaterialButton(
                                      child: Row(
                                        children: [
                                          Icon(Icons.people, size: 20, color: Color(0xffb0ccf8)),
                                          SizedBox(width: 8),
                                          Text("Clubs",
                                              style: TextStyle(
                                                  color: Color(0xff244c8c),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400)),
                                          Expanded(child: SizedBox()),
                                          SizedBox(width: 16),
                                        ],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          changePageIndex(2);
                                        });
                                        _toggleItem("Clubs");
                                      },
                                      hoverColor: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Divider(color: Colors.white, height: 0),

                            //Logout
                            Container(
                              color: isDashboardColor,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: MaterialButton(
                                      child: Row(
                                        children: [
                                          Icon(Icons.logout, size: 20, color: Color(0xffb0ccf8)),
                                          SizedBox(width: 8),
                                          Text("Logout",
                                              style: TextStyle(
                                                  color: Color(0xff244c8c),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400)),
                                          Expanded(child: SizedBox()),
                                          SizedBox(width: 16),
                                        ],
                                      ),
                                      onPressed: () {
                                        //TODO logout
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => LoginApp()),
                                        );
                                      },
                                      hoverColor: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
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
