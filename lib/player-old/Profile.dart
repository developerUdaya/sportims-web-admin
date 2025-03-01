import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
  int _selectedRadio = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xffcbdcf7),
        appBar: AppBar(
          title: Text("PROFILE"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                width: double.infinity, // Full width
                height: 1000, // Height of the clipRRect
                color: Colors.white, // Adjust the color as needed
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("Name:")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          width: 350,
                          child: Expanded(
            
                            child: TextFormField(
            
                              decoration: InputDecoration(
                                labelText: 'Enter your name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("Residental\nAddress:")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          width: 350,
                          child: Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Enter your email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("School:")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          width: 350,
                          child: Expanded(
            
                            child: TextFormField(
            
                              decoration: InputDecoration(
                                labelText: 'Enter your name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("Club:")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(55, 0, 0, 0),
                          width: 350,
                          child: Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Enter your email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
            
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("Email:")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                          width: 350,
                          child: Expanded(
            
                            child: TextFormField(
            
                              decoration: InputDecoration(
                                labelText: 'Enter your name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("Conatct\nNumber:")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(48, 0, 0, 0),
                          width: 350,
                          child: Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Enter your email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
            
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("State:")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                          width: 350,
                          child: Expanded(
            
                            child: TextFormField(
            
                              decoration: InputDecoration(
                                labelText: 'Enter your name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
            
            
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("District:")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          width: 350,
                          child: Expanded(
            
                            child: TextFormField(
            
                              decoration: InputDecoration(
                                labelText: 'Enter your name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
            
            
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("DateOf\nBirth:")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          width: 350,
                          child: Expanded(
            
                            child: TextFormField(
            
                              decoration: InputDecoration(
                                labelText: 'Enter your name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                            child: Text("Photo")),
            
            
                      ],
                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("Skaters Category")),
                        SizedBox(width: 10),

                        Container(
                            padding: EdgeInsets.fromLTRB(300, 0, 0, 0),
                            child: Text("AdharNumber")),
                        SizedBox(width: 10),
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                          width: 350,
                          child: Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Enter your email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(30, 0, 0, 50),
                      child: Column(
                        children: [
                          Row(

                            children: [
                              Radio(
                                value: 1,
                                groupValue: _selectedRadio,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRadio = value as int;
                                  });
                                },
                              ),
                              Text('Beginer'),
                            ],
                          ),
                          Row(

                            children: [
                              Radio(
                                value: 2,
                                groupValue: _selectedRadio,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRadio = value as int;
                                  });
                                },
                              ),
                              Text('Fancy'),
                            ],
                          ),
                          Row(

                            children: [
                              Radio(
                                value: 2,
                                groupValue: _selectedRadio,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRadio = value as int;
                                  });
                                },
                              ),
                              Text('Quad'),
                            ],
                          ),
                          Row(

                            children: [
                              Radio(
                                value: 2,
                                groupValue: _selectedRadio,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRadio = value as int;
                                  });
                                },
                              ),
                              Text('Inline'),
                            ],
                          ),
                        ],
                      ),

                    ),
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                            child: Text("Aadhar")),
                        SizedBox(width: 10),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 750, 30),
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
      ),
    );
  }
}
