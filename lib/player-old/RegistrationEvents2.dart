import 'package:flutter/material.dart';
class RegistrationEvents2 extends StatefulWidget {
  const RegistrationEvents2({super.key});

  @override
  State<RegistrationEvents2> createState() => _RegistrationEvents2State();
}

class _RegistrationEvents2State extends State<RegistrationEvents2> {
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
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
          title: Text("Registration Events"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: SingleChildScrollView(
          child: Column(
            children:[
              Container(
              padding: EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: double.infinity, // Full width
                  height: 250, // Height of the clipRRect
                  color: Colors.white, // Adjust the color as needed
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
                            child: Text(
          
                              'CHENNAI SPEED 2023',
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
                              'LOCATON : ',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: Text(
                              ' SHENOY NAGAR SKATING RINK',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Row(
          
                        children: [
          
          
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 30),
          
          
                            child: Text(
                              'EVENTS DATE : ',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: Text(
                              '10/12/2023',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(180, 0, 0, 30),
                            child: Text(
                              'CHEST NO : ',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: Text(
                              '01',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(180, 0, 0, 30),
          
          
                            child: Text(
                              'RACE DETAILS : ',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                            child: Text(
                              'RINK3,RINK4',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
          
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 735, 30),
                        child: MaterialButton(
          
                          onPressed: () {
                            // Add your onPressed logic here
                          },
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: Text('VIEW CERTIFICATE'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
              Container(

                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      width: double.infinity, // Full width
                      height: 250, // Height of the clipRRect
                      color: Colors.white, // Adjust the color as needed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
                                child: Text(
                  
                                  '1ST TAMILNADU SKATERS & SKATING COACHES CHAMPIONS',
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
                                  'LOCATON : ',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                                child: Text(
                                  ' SSR SKATING RINK,GERUGAMBAKKAM,CHENNAI',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Row(
                  
                            children: [
                  
                  
                              Container(
                                padding: EdgeInsets.fromLTRB(30, 0, 0, 30),
                  
                  
                                child: Text(
                                  'EVENTS DATE : ',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                                child: Text(
                                  '19/02/2024',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(180, 0, 0, 30),
                                child: Text(
                                  'CHEST NO : ',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                                child: Text(
                                  '010',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(180, 0, 0, 30),
                  
                  
                                child: Text(
                                  'RACE DETAILS : ',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                                child: Text(
                                  '500DM,1000M,3000M',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                  
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 735, 30),
                            child: MaterialButton(
                  
                              onPressed: () {
                                // Add your onPressed logic here
                              },
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: Text('VIEW CERTIFICATE'),
                            ),
                          ),
                  
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    width: double.infinity, // Full width
                    height: 250, // Height of the clipRRect
                    color: Colors.white, // Adjust the color as needed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
                              child: Text(

                                'TRINELVELI DISTRICT ROLLER SPORTS CHAMPIONSHIP',
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
                                'LOCATON : ',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                              child: Text(
                                'S C A D INTERNATIONAL SCHOOL CHERANMAHADEVI',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Row(

                          children: [


                            Container(
                              padding: EdgeInsets.fromLTRB(30, 0, 0, 30),


                              child: Text(
                                'EVENTS DATE : ',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                              child: Text(
                                '21/01/2024',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(180, 0, 0, 30),
                              child: Text(
                                'CHEST NO : ',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                              child: Text(
                                '01',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(180, 0, 0, 30),


                              child: Text(
                                'RACE DETAILS : ',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                              child: Text(
                                'RINK3,RINK4',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),

                          ],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 735, 30),
                          child: MaterialButton(

                            onPressed: () {
                              // Add your onPressed logic here
                            },
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: Text('VIEW CERTIFICATE'),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),

      ),
    );
  }
}
