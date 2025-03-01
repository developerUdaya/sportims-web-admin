import 'package:flutter/material.dart';
import 'package:sport_ims/Dashboard.dart';
import 'package:sport_ims/main.dart';
import 'package:sport_ims/player-old/Profile.dart';

import 'Dashboard2.dart';
import 'RegistrationEvents2.dart';


class Player extends StatefulWidget {
  @override
  State<Player> createState() => _PlayerState();
}

int index =0;
List pages = [Dashboard2(),Profile(),
  RegistrationEvents2(),Profile(),
 ];


class _PlayerState extends State<Player> {
  bool isDashboard2 = false;
  bool isEvents2 = false;
  bool isRegistrationEvents2 = false;
  bool isProfile = false;

  static const Color bgLightBlue =  Color(0xffe3ecfa);
  static const Color bgDarkBlue = Color(0xffcbdcf7);

  late Color isDashboard2Color = bgLightBlue,
      isEvents2Color = bgLightBlue,
      isRegistrationEvents2Color= bgLightBlue,
      isProfileColor=bgLightBlue;

  void _toggleItem(String itemName) {
    setState(() {
      isDashboard2 = itemName == 'Dashboard' ? !isDashboard2 : false;

      isEvents2 = itemName == 'Events' ? !isEvents2 : false;
      isRegistrationEvents2 = itemName == 'Events Details' ? !isRegistrationEvents2 : false;
      isProfile = itemName == 'EventOganizer' ? !isProfile : false;

      isDashboard2Color = isDashboard2 ? bgDarkBlue : bgLightBlue;
      isEvents2Color = isEvents2 ? bgDarkBlue : bgLightBlue;
      isRegistrationEvents2Color = isRegistrationEvents2 ? bgDarkBlue : bgLightBlue;

      isProfileColor = isProfile? bgDarkBlue : bgLightBlue;
    });
  }
  bool isDropdownOpen = false;
  bool isDropdownOpen1 = false;
  bool isDropdownOpen2 = false;
  bool isDropdownOpen3 = false;
  bool isDropdownOpen4 = false;
  bool isDropdownOpen5 = false;
  bool isDropdownOpen6 = false;
  bool isDropdownOpen7 = false;


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              navigation?leftSide(context):Container(
                width: 30,
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                    ),
                    onPressed: (){
                      setState(() {
                        navigation = !navigation;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: pages[index],
              ),
            ],
          ),
        )
    );
  }


  @override
  Widget leftSide(BuildContext context) {
    return Row(
      children: [
        if(!navigation)Container(
          child: IconButton(
            onPressed: () {
              setState(() {
                navigation = !navigation;
              });
            },
            icon: Icon(Icons.arrow_forward_ios),
          ),
        ),
        if(navigation)Container(
          width: 300,
          color: Colors.white70,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView(

              scrollDirection: Axis.vertical,
              children: [

                SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: SizedBox(width: 0,)),
                        Container(
                          margin: EdgeInsetsDirectional.symmetric(vertical: 10),
                          width: 60, // Adjusted width
                          color: Color(0xffe3df74), // Change the second color here
                          child: Center(
                            child: Text(
                              'Sport',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff244c8c), //
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsetsDirectional.symmetric(vertical: 10),

                          width: 60, // Adjusted width
                          color: Color(0xff244c8c), //
                          child: Center(
                            child: Text(
                              'IMS',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, //
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox(width: 0,)),

                        Container(
                          child: IconButton(

                            onPressed: () {
                              setState(() {
                                navigation = !navigation;
                              });
                            },
                            icon: Icon(Icons.menu),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  color: Colors.grey,
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

                                //DashBoard
                                Container(
                                  color: isDashboard2Color,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        child: MaterialButton(
                                          child: Row(
                                            children: [
                                              // Reduce the size of the icon and change its color
                                              Icon(Icons.dashboard, size: 20, color: Color(0xffb0ccf8)),
                                              SizedBox(width: 8,),
                                              Text(
                                                "Dashboard",
                                                style: TextStyle(
                                                  color: Color(0xff244c8c),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              // Expanded(child: SizedBox()),
                                              // Icon(Icons.arrow_drop_down),
                                              // SizedBox(width: 16),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              isDropdownOpen = !isDropdownOpen;
                                              isDropdownOpen = false;
                                              isDropdownOpen1 = false;
                                              isDropdownOpen2 = false;
                                              isDropdownOpen3 = false;
                                              isDropdownOpen4 = false;
                                              isDropdownOpen5 = false;
                                              isDropdownOpen6 = false;
                                            });
                                            _toggleItem("Dashboard");
                                            changePageIndex(0);
                                          },
                                          hoverColor: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //Master
                                Container(
                                  color: isEvents2Color,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        child: MaterialButton(
                                          child: Row(
                                            children: [
                                              // Reduce the size of the icon and change its color
                                              Icon(Icons.extension, size: 20, color: Color(0xffb0ccf8)),
                                              SizedBox(width: 8,),
                                              Text(
                                                "Events",
                                                style: TextStyle(
                                                  color: Color(0xff244c8c),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              Expanded(child: SizedBox()),
                                              // You can keep the dropdown icon as is
                                              // Icon(isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                                              SizedBox(width: 16),
                                            ],
                                          ),
                                          onPressed: (){
                                            setState(() {
                                              isDropdownOpen = !isDropdownOpen;
                                              isDropdownOpen1 = false;
                                              isDropdownOpen2 = false;
                                              isDropdownOpen3 = false;
                                              isDropdownOpen4 = false;
                                              isDropdownOpen5 = false;
                                              isDropdownOpen6 = false;
                                            });
                                            _toggleItem("Events2");
                                            changePageIndex(1);
                                          },
                                          hoverColor: Colors.blueAccent,
                                        ),
                                      ),

                                      if (isEvents2)
                                        Column(
                                          children: [

                                          ],
                                        ),
                                    ],
                                  ),
                                ),

                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),

                                //Approval
                                Container(
                                  color: isRegistrationEvents2Color,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.file_open,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("RegistrationEvents",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                // Icon(isDropdownOpen1 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen1 = !isDropdownOpen1;
                                                isDropdownOpen = false;
                                                isDropdownOpen2 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen5 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              _toggleItem("RegistrationEvents");
                                              changePageIndex(2);

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),

                                      if (isRegistrationEvents2)
                                        Column(
                                            children: [

                                            ]

                                        )],
                                  ),
                                ),
                                Divider(
                                  color: Colors.white,
                                  height: 0,
                                ),
                                Container(
                                  color: isProfileColor,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          child: MaterialButton(
                                            child: Row(
                                              children: [
                                                Icon(Icons.face,size: 20,color:Color(0xffb0ccf8)),
                                                SizedBox(width: 8,),

                                                Text("Profile",style: TextStyle(
                                                    color: Color(0xff244c8c),fontSize: 16,fontWeight:  FontWeight.w400
                                                )),Expanded(child: SizedBox()),
                                                // Icon(isDropdownOpen2 ? Icons.arrow_drop_up : Icons.arrow_drop_down),

                                                SizedBox(width: 16,)
                                              ],

                                            ),

                                            onPressed: (){
                                              setState(() {
                                                isDropdownOpen2 = !isDropdownOpen2;
                                                isDropdownOpen = false;
                                                isDropdownOpen1 = false;
                                                isDropdownOpen3 = false;
                                                isDropdownOpen4 = false;
                                                isDropdownOpen5 = false;
                                                isDropdownOpen6 = false;
                                              });
                                              _toggleItem("Profile");
                                              changePageIndex(3);

                                            },
                                            hoverColor: Colors.blueAccent,
                                          )
                                      ),

                                      if (isProfile)
                                        Column(
                                            children: [
                                                                                          ]

                                        )],
                                  ),
                                ),


                                //Events

                                //Events Details


                                //Official




                              ])

                      ),

                    )) ],
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
