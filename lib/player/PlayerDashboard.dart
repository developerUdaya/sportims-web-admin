import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/models/UserCredentialsModel.dart';
import 'package:sport_ims/player/EventsData.dart';
import 'package:sport_ims/player/RegisteredEventsPage.dart';
import 'package:sport_ims/player/SkaterDashboardPage.dart';

import '../firebase_options.dart';
import '../loginApp/LoginApp.dart';
import '../models/EventModel.dart';
import '../models/EventParticipantsModel.dart';
import '../models/UsersModel.dart';
import '../utils/Controllers.dart';
import 'SkaterProfile.dart';

class PlayerScreen extends StatelessWidget {

  String userMobileNumber;

  PlayerScreen({required this.userMobileNumber});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Player',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(color: Colors.blueAccent,fontSize: 26,fontWeight: FontWeight.w200)
        ),
        primarySwatch: Colors.blue,
      ),
      home: PlayerDashboardScreen(userMobileNumber: userMobileNumber,),
    );
  }
}

class PlayerDashboardScreen extends StatefulWidget {
  String userMobileNumber;
  PlayerDashboardScreen({required this.userMobileNumber});

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  int _currentPage = 0;
  String _currentTitle = 'Dashboard';
  int _hoveredIndex = -1; // To track the hovered item

  Users? skater;
  List<EventModel> allEvents = [];
  List<EventParticipantsModel> registeredEvents = [];


  List pages = [];

  void changePage(int page, String title) {
    if (page == 4) {
      // Ensure that the navigator is in a proper state before replacing the current route
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginApp()),
          );
        }
      });
      return;
    }
    setState(() {
      _currentPage = page;
      _currentTitle = title;
    });

  }

// Fetch clubs data from Firebase
  Widget buildDrawerItem({required int index, required String title}) {
    bool isSelected = _currentPage == index;
    bool isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredIndex = -1;
        });
      },
      child: ListTile(
        hoverColor: Colors.blueAccent.shade100.withOpacity(0.3),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300), // Smooth animation duration
          width: isSelected || isHovered ? 20.0 : 10.0, // Longer line for the current page or hovered item
          height: 2.0,
          color: isSelected ? Colors.blue : (isHovered ? Colors.blueAccent : Colors.grey),
        ),
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300), // Smooth animation duration
          style: TextStyle(
            color: isSelected ? Colors.blue : (isHovered ? Colors.blueAccent : Colors.black),
            fontWeight: isSelected || isHovered ? FontWeight.bold : FontWeight.normal,
          ),
          child: Text(title),
        ),
        onTap: () {
          changePage(index, title);
          Navigator.pop(context);
        },
      ),
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSkaterDataAndEvents();
  }

  // Fetch skater data and all events from Firebase
  Future<void> fetchSkaterDataAndEvents() async {

    try {
      // Fetch skater data using the mobile number
      Users skaterData = await fetchSkaterByMobileNumber(widget.userMobileNumber);

      // Fetch all events
      List<EventModel> eventsList = await fetchEventsFromFirebase();

      print("All event list");
      print(eventsList.map((e) => e.id,));

      // Fetch registered events of the skater
      List<EventParticipantsModel> registeredEventList = await fetchRegisteredEvents(widget.userMobileNumber);

      // Filter events based on skater's registered event IDs
      List<EventModel> filteredEvents = eventsList.where((event) {
        return registeredEventList.any((regEvent) => regEvent.eventID == event.id);
      }).toList();

      setState(() {
        skater = skaterData;
        allEvents = filteredEvents;
        registeredEvents = registeredEventList;

          pages = [
            SkaterDashboardPage(skater: skater!, events: eventsList,),
            EventsData(
              events: eventsList.where(
                    (element) => element.eventDate.isAfter(DateTime.now().subtract(Duration(days: 1))),
              ).toList(),
              user: skater!,
            ),
            RegisteredEventsPage(allEvents: allEvents,registeredEvents: registeredEventList,skater: skater,),
            SkaterProfilePage(skater: skater!),

            // ProductMenuPage(),
            // PaymentHistoryPage(),
            // LoginPage()
          ];

      });
    } catch (e) {
      print('Failed to load events: $e');
      setState(() {
      });
    }
  }

  // Fetch skater data using mobile number as the key
  Future<Users> fetchSkaterByMobileNumber(String mobileNumber) async {
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('skaters/$mobileNumber');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      return Users.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
    } else {
      throw Exception('Skater with mobile number $mobileNumber not found.');
    }
  }

  // Fetch all events from the path 'events/pastEvents'
  Future<List<EventModel>> fetchEventsFromFirebase() async {
    List<EventModel> eventsList = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('events/pastEvents');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        EventModel event = EventModel.fromJson(Map<String, dynamic>.from(child.value as Map));
        if(!event.deleteStatus){
          eventsList.add(event);
        }
      }
    }
    return eventsList;
  }

  // Fetch skater's registered events using the path 'skaters/{mobilenumber}/events'
  Future<List<EventParticipantsModel>> fetchRegisteredEvents(String mobileNumber) async {
    List<EventParticipantsModel> registeredEventList = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('skaters/$mobileNumber/events');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        EventParticipantsModel regEvent = EventParticipantsModel.fromJson(Map<String, dynamic>.from(child.value as Map));
        registeredEventList.add(regEvent);
      }
    }
    return registeredEventList;
  }

  EventModel? findEventById(String eventID) {
    try {
      return allEvents.firstWhere((event) => event.id == eventID);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(_currentTitle,style: const TextStyle(color: Colors.white),),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.grey.shade300,
            ), // Change this icon to customize
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
        actions: [

          Text(skater!=null?'Hello, ${skater!.name}!':'',style: const TextStyle(color: Colors.white),),
          const SizedBox(width: 20,),
          if(skater!=null)CircleAvatar(
            foregroundImage: NetworkImage(skater!.profileImageUrl),

          ),
          const SizedBox(width: 20,),

        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'logo.jpg', // Ensure this path is correct and the image is added to your pubspec.yaml
                    width: 170, // Adjust width as needed
                    height: 120, // Adjust height as needed
                  ),
                  

                ],
              ),
            ),

            buildDrawerItem(index: 0, title: 'Dashboard'),
            buildDrawerItem(index: 1, title: 'Events'),
            buildDrawerItem(index: 2, title: 'Registered Events'),
            buildDrawerItem(index: 3, title: 'Profile'),
            buildDrawerItem(index: 4, title: 'Logout'),
          ],
        ),
      ),
      body: pages.length>0&&skater!=null?pages[_currentPage]:const Center(child: CircularProgressIndicator(color: Colors.blue,)),
    );
  }
}
