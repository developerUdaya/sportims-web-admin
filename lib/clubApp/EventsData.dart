import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'EventDetailsPage2.dart';
import '../models/EventModel.dart';

class EventsData extends StatefulWidget {
  const EventsData({Key? key}) : super(key: key);

  @override
  State<EventsData> createState() => _EventsDataState();
}

class _EventsDataState extends State<EventsData> {
  List<EventModel> pastEvents = [];
  bool _isLoading = true;
  bool _isSearching = false;
  List<EventModel> searchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    List<EventModel> events = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('events/pastEvents');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        try {
          EventModel event = EventModel.fromJson(Map<String, dynamic>.from(child.value as Map));

          if(!event.deleteStatus){
            events.add(event);
          }
        } catch (e) {
          print(e);
        }
      }
    }

    setState(() {
      pastEvents = events;
      searchResults = events;
      _isLoading = false;
    });
  }

  // Search functionality
  void _searchEvents(String value) {
    setState(() {
      searchResults = pastEvents
          .where((event) => event.eventName.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // Show event details dialog
  void showEventDetailsDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EventDetailsPage(eventModel: event);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events",style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
        actions: [
          // Container(
          //     width: 500,
          //     alignment: Alignment.centerRight,
          //     child: Text("Hello, ",style: TextStyle(color: Colors.white,fontSize: 18,overflow: TextOverflow.ellipsis),)),

          IconButton(
            icon: Icon(Icons.search,color: Colors.white,),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),

        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search events...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _searchEvents,
              ),
            ),
          Expanded(
            child: Container(
              color: Color(0xfff5f6fa),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    final event = searchResults[index];
                    return GestureDetector(
                      onTap: () => showEventDetailsDialog(event),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Event Date Display
                            Column(
                              children: [
                                Text(
                                  _formatMonth(event.eventDate.toString()),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                Text(
                                  _formatDay(event.eventDate.toString()),
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 20),
                            // Event Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.eventName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    event.instruction,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate.replaceAll('-', ''));
    return _getMonthAbbreviation(dateTime.month);
  }

  String _formatDay(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate.replaceAll('-', ''));
    return dateTime.day.toString();
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
