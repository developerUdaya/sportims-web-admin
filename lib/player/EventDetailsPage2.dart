import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/loginApp/LoginApp.dart';

import '../models/EventModel.dart';
import '../models/EventRaceModel.dart';
import '../models/UsersModel.dart';
import 'EventRegistration.dart';

class EventDetailsPage extends StatefulWidget {
  final EventModel? eventModel;
  Users user;

  EventDetailsPage({required this.eventModel, required this.user});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  EventModel? get event => widget.eventModel;

  bool registerEventButton = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchEventRegistrationDetails();
  }

  Future<void> fetchEventRegistrationDetails() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot = await dbRef.child('skaters/${widget.user.contactNumber}/events/${widget.eventModel!.id}').get();
    if(snapshot.exists){
      setState(() {
        registerEventButton = false;
      });
    }else{
      setState(() {
        registerEventButton = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        backgroundColor:  Color(0xfff5f6fa),
        appBar: AppBar(
          title: Text('${event?.eventName} Event Details',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.blue[700],
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.white,), onPressed: () { Navigator.pop(context); },
          ),
          actions: [
            if(registerEventButton)AnimatedButton(
                label: 'Register Event',
                icon: null,
                textColor: Colors.white,
                buttonColor: Colors.greenAccent,
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => EventParticipantsForm(event:event!,user:widget.user),));
                }
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event != null) ...[
                  Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner Image
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          child: Image.network(
                            event!.bannerImage ?? "",
                            width: double.infinity,
                            fit: BoxFit.cover,
                            height: 600,
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event Name
                              Row(
                                children: [
                                  Icon(Icons.medical_information_outlined, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Event Name : ${event!.eventName}' ?? "",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              // Event Date
                              Row(
                                children: [
                                  Icon(Icons.event, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Event Date : ${DateFormat('yyyy-MM-dd').format(event!.eventDate!)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Event Place
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Event Place : ${event!.place ?? ""}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              //Event Prefix
                              Row(
                                children: [
                                  Icon(Icons.numbers, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Event Prefix : ${event!.eventPrefixName ?? ""}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Divider(),

                              // Description
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                event!.declaration ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 16),
                              Divider(),

                              // Instructions
                              Text(
                                'Instructions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                event!.instruction ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 16),
                              Divider(),

                              // Registration Details
                              Text(
                                'Registration Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),

                              // Registration Amount
                              Row(
                                children: [
                                  Icon(Icons.currency_rupee, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Registration fee : ₹ ${event!.regAmount}' ?? "",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Registration Start Date
                              Row(
                                children: [
                                  Icon(Icons.date_range, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Registration Start: ${DateFormat('yyyy-MM-dd').format(event!.regStartDate!)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),

                              // Registration End Date
                              Row(
                                children: [
                                  Icon(Icons.date_range, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Registration End: ${DateFormat('yyyy-MM-dd').format(event!.regCloseDate!)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),

                              // Age As On Date
                              Row(
                                children: [
                                  Icon(Icons.date_range, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Age As On : ${DateFormat('yyyy-MM-dd').format(event!.ageAsOn!)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Divider(),

                              // Advertisement Image
                              Text(
                                'Advertisement',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                height: 500,
                                padding: EdgeInsets.all(15),
                                child: Image.network(event!.advertisement ?? ""),
                              ),
                              SizedBox(height: 16),
                              Divider(),

                              // // Event Races
                              // Text(
                              //   'Event Races',
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              // SizedBox(height: 8),
                              // // Display Event Races
                              // Text(
                              //   event!.eventRaces!.map((e) => e).join(', '),
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //   ),
                              // ),                              SizedBox(height: 16),
                              // Divider(),
                              //
                              // // Age Categories
                              // Text(
                              //   'Age Categories',
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              // SizedBox(height: 8),
                              // // Display Age Categories
                              // Text(
                              //   event!.ageCategory.map((eventRace) => eventRace ?? "").join(', ') ?? "",
                              //   style: TextStyle(
                              //     fontSize: 16,
                              //   ),
                              // ),
                              // SizedBox(height: 16),
                              // Divider(),
                              //
                              // // Event Race Models
                              // Text(
                              //   'Event Race Models',
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                              // SizedBox(height: 8),
                              // // Display Event Race Models
                              // ListView.builder(
                              //   shrinkWrap: true,
                              //   itemCount: event?.eventRaceModel.where((element) => element.categoryName!="").toList().length,
                              //   itemBuilder: (context, index) {
                              //     List<EventRaceModel>? eventRaceModel = event?.eventRaceModel.where((element) => element.categoryName!="").toList();
                              //     return Card(
                              //       elevation: 4.0,
                              //       margin: EdgeInsets.symmetric(vertical: 8.0),
                              //       child: Padding(
                              //         padding: EdgeInsets.all(12.0),
                              //         child: Column(
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //           children: [
                              //             Text(
                              //               eventRaceModel![index]?.categoryName ?? "",
                              //               style: TextStyle(
                              //                 fontSize: 16,
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //             SizedBox(height: 8),
                              //             DataTable(
                              //               columns: [
                              //                 DataColumn(label: Text('Age Group')),
                              //                 DataColumn(label: Text('Max Events')),
                              //                 DataColumn(label: Text('Event Races')),
                              //               ],
                              //               rows: eventRaceModel![index]?.raceAgeGroup?.where((element) => element.maxEvents>0 ).toList().map((raceAgeGroup) {
                              //                 return DataRow(cells: [
                              //                   DataCell(Text(raceAgeGroup.ageGroup ?? "")),
                              //                   DataCell(Text(raceAgeGroup.maxEvents?.toString() ?? "")),
                              //                   DataCell(Text(raceAgeGroup.eventRaces?.map((eventRace) => eventRace.selected?eventRace.race:"").join(' ') ?? "")),
                              //                 ]);
                              //               }).toList() ?? [],
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // ),
                              SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Center(child: Text('No Event Details')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

