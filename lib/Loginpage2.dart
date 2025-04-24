import 'package:flutter/material.dart';
import 'package:sport_ims/Dashboard.dart';
import 'package:sport_ims/main.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _showSnackBarWithDelay() {
    // Delay for 3 seconds (3000 milliseconds) before showing the SnackBar
    Future.delayed(Duration(seconds: 3), () {
      final snackBar = SnackBar(
        content: Text('Invalid Credentials'),
        duration: Duration(seconds: 2),
      );

      // Show the SnackBar using the ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 300,
              margin: EdgeInsets.only(top: 60),

              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 59,
                          margin: EdgeInsetsDirectional.symmetric(vertical: 20),
                          color: Color(0xffe3df74),
                          child: Center(
                            child: Text(
                              'Sport',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff244c8c),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 59,
                          color: Color(0xff244c8c),
                          child: Center(
                            child: Text(
                              'IMS',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    TextFormField(

                      cursorColor: Colors.black,
                      decoration: InputDecoration(

                        hintText: 'Username',

                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      cursorColor: Colors.black,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    // DropdownButtonFormField(
                    //   items: ['Option 1', 'Option 2', 'Option 3']
                    //       .map((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),
                    //     );
                    //   }).toList(),
                    //   decoration: InputDecoration(
                    //     hintText: 'Select Option',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   onChanged: (value) {
                    //     // Handle dropdown value change
                    //   },
                    // ),
                    // SizedBox(height: 20),
                     ElevatedButton(
                        onPressed: () {
                          // _startLoading();
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => MyApp()));


                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                        ),
                        child: _isLoading?CircularProgressIndicator():Container(
                            width: 200,
                            height: 40,
                            alignment: Alignment.center,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )
                        )
                    ),
                    // SizedBox(height: 20),
                    // TextButton(
                    //   onPressed: () {
                    //     showDialog(
                    //       context: context,
                    //       barrierDismissible: false,
                    //       builder: (BuildContext context) {
                    //         return Center(child: CircularProgressIndicator());
                    //       },
                    //     );

                    //   },
                    //   child: Text('Forgot Password?',
                    //   style: TextStyle(
                    //     color: Colors.black
                    //   ),),

                    // ),
                    SizedBox(height: 20),
                    if(showInvalid)Text("Invalid Credentials",style: TextStyle(color: Colors.red),)
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text("Don't have an account? "),
                    //     TextButton(
                    //       onPressed: (
                    //
                    //           ) {
                    //
                    //       },
                    //       child: Text('Sign Up',
                    //       style: TextStyle(
                    //         color: Colors.black
                    //       ),),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }

  bool _isLoading = false;
  bool showInvalid = false;

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });

    // Simulate a delay for loading (e.g., fetching data or performing an operation)
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isLoading = false;
        showInvalid = true;

      });


      _showDialog();
      // Optionally show a SnackBar when loading is complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('The project\'s quota for this operation has been exceeded.'),
          duration: Duration(seconds: 2),
        ),
      );


    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create the dialog content
        return AlertDialog(
          title: Text('Auto-Close Dialog'),
          content: Text('This dialog will close automatically after 3 seconds.'),
        );
      },
    );

    // Automatically close the dialog after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the dialog
    });
  }
}



