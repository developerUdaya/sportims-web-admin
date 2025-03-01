import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:sport_ims/models/EventModel.dart';

import '../models/UsersModel.dart';
import '../utils/Controllers.dart';
import '../utils/Widgets.dart';

class SkaterDashboardPage extends StatefulWidget {
  final Users skater;
  final List<EventModel> events;

  SkaterDashboardPage({required this.skater,required this.events});

  @override
  _SkaterDashboardPageState createState() => _SkaterDashboardPageState();
}

class _SkaterDashboardPageState extends State<SkaterDashboardPage> {
  int registeredEventsCount = 0;
  int upcomingEventsCount = 0;
  bool isBirthday = false;
  bool isBirthdayDialogShown = false;
  List<EventModel>? events;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Initialize the AudioPlayer

    _fetchEventCounts();
    _checkBirthday();
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Dispose the AudioPlayer to release resources
    super.dispose();
  }

  // Fetch event data to count registered and upcoming events
  Future<void> _fetchEventCounts() async {
    try {
      // Fetch registered events count
      final regEventsRef = FirebaseDatabase.instance.ref('skaters/${widget.skater.contactNumber}/events');
      final regEventsSnapshot = await regEventsRef.get();
      if (regEventsSnapshot.exists) {
        setState(() {
          registeredEventsCount = regEventsSnapshot.children.length;
        });
      }

      // Fetch upcoming events count
      setState(() {
        // events = widget.events;
        events = widget.events.where((element) => element.eventDate.isAfter(DateTime.now().subtract(Duration(days: 1)))).toList();
        upcomingEventsCount = events!.length;

      });
    } catch (e) {
      print('Error fetching event counts: $e');
    }
  }

  void _checkBirthday() {
    DateTime now = DateTime.now();
    DateTime? dob = _parseDate(widget.skater.dateOfBirth);
    if (dob != null && now.month == dob.month && now.day == dob.day) {
      setState(() {
        isBirthday = true;
      });
      _showBirthdayDialog();
    }
  }

  /// Parses a date string into a DateTime object using multiple date formats
  DateTime? _parseDate(String dateString) {
    // Define a list of date formats to try
    List<String> dateFormats = [
      'dd-MM-yyyy',
      'MM/dd/yyyy',
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'dd/MM/yyyy',
      'dd MMM yyyy',
      'yyyy MMM dd',
    ];

    for (String format in dateFormats) {
      try {
        return DateFormat(format).parseStrict(dateString);
      } catch (e) {
        // Continue to the next format if the parsing fails
        continue;
      }
    }
    // If all formats fail, return null
    print('Failed to parse date: $dateString');
    return null;
  }


  // Show birthday wishing dialog with animation
  Future<void> _showBirthdayDialog() async {
    if (isBirthday && !isBirthdayDialogShown) {
      setState(() {
        isBirthdayDialogShown = true;
      });

      await _audioPlayer.setAsset('assets/birthday.mp3'); // Add your audio file in assets
      _audioPlayer.play();


      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return Center(
              child: Lottie.asset(
                'birthday.json',
                width: 300,
                height: 300,
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    Navigator.of(context).pop();
                    setState(() {
                      isBirthdayDialogShown = false;
                    });
                    _audioPlayer.stop(); // Stop the sound after dialog is closed

                  });
                },
              ),
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingText(context),
            SizedBox(height: 16),
            _buildEventSummaryCard(),
            SizedBox(height: 24),
            if(events!=null)_buildEventsDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingText(BuildContext context) {
    // Get current time to generate greeting message with emojis
    String _getGreetingMessage() {
      DateTime now = DateTime.now();
      if (now.hour < 6) {
        return '🌄 Good Morning'; // Early Morning
      } else if (now.hour < 9) {
        return '🌅 Good Morning'; // Morning Sunrise
      } else if (now.hour < 12) {
        return '☀️ Good Morning'; // Morning Sun
      } else if (now.hour < 15) {
        return '🌤️ Good Afternoon'; // Early Afternoon
      } else if (now.hour < 17) {
        return '⛅ Good Afternoon'; // Late Afternoon
      } else if (now.hour < 20) {
        return '🌇 Good Evening'; // Early Evening Sunset
      } else if (now.hour < 22) {
        return '🌆 Good Evening'; // Nightfall
      } else {
        return '🌃 Good Evening'; // Late Night
      }
    }

    // Generate greeting message
    String greeting = isBirthday?'🎉 Happy Birthday':_getGreetingMessage();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AnimatedSwitcher(
        duration: Duration(seconds: 1), // Duration of the animation
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Text(
          '$greeting, ${widget.skater.name} 😃!',
          key: ValueKey<String>(greeting), // Key to distinguish text changes
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }


  // Widget to build event summary cards
  Widget _buildEventSummaryCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(width: 20,),
        _buildEventCard('Registered Events', registeredEventsCount, Colors.blue[600]!),
        SizedBox(width: 20,),

        _buildEventCard('Upcoming Events', upcomingEventsCount, Colors.green[600]!),
        SizedBox(width: 20,),

      ],
    );
  }

  // Widget to build a single event card
  Widget _buildEventCard(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8.0),
          boxShadow:[
            BoxShadow(color: Colors.black12,blurRadius: 5,offset: Offset(10, 10)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build upcoming event details section
  Widget _buildEventsDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Upcoming Events',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          SizedBox(height: 16),
          events!.length == 0
              ? Center(
            child: Text(
              'No upcoming events',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          )
              : ListView.builder(
            shrinkWrap: true, // Use this to prevent infinite height error
            physics: NeverScrollableScrollPhysics(),
            itemCount: events!.length,

            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                  child: GlassmorphismCalendarCard(events![index]))
              ;
            },
          ),
        ],
      ),
    );
  }


}

