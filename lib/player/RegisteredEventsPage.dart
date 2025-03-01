import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:sport_ims/utils/Widgets.dart';
import '../models/EventParticipantsModel.dart';
import '../models/EventModel.dart';
import '../models/UsersModel.dart';
import 'EventParticipantDetailsPage.dart';

class RegisteredEventsPage extends StatefulWidget {
  Users? skater; // Store skater information
  List<EventModel> allEvents = [];
  List<EventParticipantsModel> registeredEvents = [];

  RegisteredEventsPage({required this.skater, required this.allEvents, required this.registeredEvents});

  @override
  _RegisteredEventsPageState createState() => _RegisteredEventsPageState();
}

class _RegisteredEventsPageState extends State<RegisteredEventsPage> {
  Users? skater; // Store skater information
  List<EventModel> allEvents = [];
  List<EventParticipantsModel> registeredEvents = [];

  @override
  void initState() {
    super.initState();
    skater = widget.skater;
    allEvents = widget.allEvents;
    registeredEvents = widget.registeredEvents;

    print("object");
    print(allEvents.map((e) => e.id,));

  }


  EventModel? findEventById(String eventID) {
    try {
      print(allEvents.map((e) => e.id,));
      return allEvents.firstWhere((event) => event.id == eventID);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
           registeredEvents.isEmpty
          ? Center(
        child: Text(
          'No registered events found',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              for (EventParticipantsModel regEvent in registeredEvents)
                buildEventCard(regEvent),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEventCard(EventParticipantsModel regEvent) {
    // Get full event details based on the eventID
    EventModel? event = findEventById(regEvent.eventID);
    print("event!.id");
    print( regEvent.eventID);

    print(event!.id);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventParticipantDetailsPage(participant: regEvent, eventModel: event,),
              ),
            );

          },
          child: GlassmorphismCalendarEventCard(event!, regEvent)),
    );
  }


// Helper widget to display a row of information with a title and value
  Widget buildInfoText(String title, String value) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$title ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
              fontSize: 16, // Reduced font size for labels
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16, // Reduced font size for values
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  // Format event date to a readable string
  String formatEventDate(String? date) {
    if (date == null) return 'N/A';
    DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }

  void _viewCertificate(EventParticipantsModel event) {
    // You can implement viewing the certificate functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing certificate for ${event.eventName}')),
    );
  }
}
