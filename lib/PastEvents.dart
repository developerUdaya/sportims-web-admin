import 'package:flutter/material.dart';
import 'package:sport_ims/events/Events.dart';

class PastEvents extends StatefulWidget {
  const PastEvents({Key? key}) : super(key: key);

  @override
  State<PastEvents> createState() => _PastEventsState();
}

class _PastEventsState extends State<PastEvents> {
  bool addNewState = false; // Define addNewState variable here

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Past Events"),
          backgroundColor: Color(0xffb0ccf8),
        ),

        body: Center(
          child: SingleChildScrollView(
            child: Container(
              color: Color(0xffcbdcf7),

              padding: EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 10),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(

                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
                            child: Text(
                              'Events Date:',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
                            child: Text(
                              'September 17, 2022',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(150, 30, 0, 30),
                            child: Text(
                              'Events Place:',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(5, 30, 0, 30),
                            child: Text(
                              'Chennai Formula Racing Circuit',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
                            child: Text(
                              'Age Group:',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
                            child: Text(
                              'Your age group here',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(150, 30, 0, 30),
                            child: Text(
                              'Events Description:',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(5, 30, 0, 30),
                            child: Text(
                              'September 17, 2022 @ 1:00 pm - 2:00 pm\nVenue Chennai Formula Racing Circuit.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(30),
                        child: Container(
                          width: 350,
                          height: 350,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage('https://media.istockphoto.com/id/1146517111/photo/taj-mahal-mausoleum-in-agra.jpg?s=612x612&w=0&k=20&c=vcIjhwUrNyjoKbGbAQ5sOcEzDUgOfCsm9ySmJ8gNeRk='), // Replace URL with your image URL
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 225),
                          Container(
                            width: 200,
                            child: ElevatedButton(

                              onPressed: () {
                                // Add onPressed logic for the first button
                              },
                              child: Text('Result'),
                            ),
                          ),
                          SizedBox(width: 100),
                          Container(
                            width: 200,

                            child: ElevatedButton(
                              onPressed: () {
                                // Add onPressed logic for the second button
                              },
                              child: Text('Certificate'),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(width: 10),
                          Padding(
                            padding: EdgeInsets.all(35),
                            child: MaterialButton(
                              onPressed: () {
                                // Handle back button press
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Events()),
                                );
                              },
                              child: Row(
                                children: [
                                  SizedBox(width: 5),
                                  Text(
                                    'Back',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
