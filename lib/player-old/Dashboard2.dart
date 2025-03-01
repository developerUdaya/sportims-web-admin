import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dashboard2 extends StatefulWidget {
  const Dashboard2({Key? key}) : super(key: key);

  @override
  State<Dashboard2> createState() => _Dashboard2State();
}

class _Dashboard2State extends State<Dashboard2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RightSide2(),
    );
  }
}

class RightSide2 extends StatefulWidget {
  @override
  State<RightSide2> createState() => _RightSide2State();
}

class _RightSide2State extends State<RightSide2> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xffcbdcf7),
        appBar: AppBar(
          title: Text("Dashboard"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              width: double.infinity, // Full width
              height: 200, // Height of the clipRRect
              color: Colors.white, // Adjust the color as needed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
                        child: Text(

                          'DASHBOARD',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),

                    ],
                  ),
                  Row(

                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(30, 0, 0, 30),


                        child: Text(
                          'No.Of Upcoming Events:0',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(450, 0, 0, 30),
                        child: Text(
                          'No.Of Upcoming Events:4',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  Row(

                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(30, 0, 0, 30),
                        child: MaterialButton(
                          onPressed: () {
                            // Add your onPressed logic here
                          },
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Text('VIEW'),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(550, 0, 0, 30),
                        child: MaterialButton(

                          onPressed: () {
                            // Add your onPressed logic here
                          },
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Text('VIEW'),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
