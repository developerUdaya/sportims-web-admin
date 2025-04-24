
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morphing_text/morphing_text.dart';
import 'package:lottie/lottie.dart';

import 'package:http/http.dart' as http;
import '../clubApp/ClubApp.dart';
import '../districtApp/DistrictApp.dart';
import '../main.dart';
import '../models/UserCredentialsModel.dart';
import '../officialApp/OfficialsApp.dart';
import '../organiserApp/OrganisersApp.dart';
import '../player/PlayerDashboard.dart';
import '../registration/ClubRegistrationForm.dart';
import '../registration/DistrictSecretaryRegistration.dart';
import '../registration/SkaterRegistration.dart';
import '../widgets/CustomAppBar.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.blue,
          // textTheme: TextTheme(
          //   bodyText1: TextStyle(color: Colors.blueGrey[900]), // Blue-black text color
          //   bodyText2: TextStyle(color: Colors.blueGrey[900]), // Blue-black text color
          // ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.blue, // White button text color
            ),
          ),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.blueAccent
              )
          ),
          scaffoldBackgroundColor: Colors.white

      ),
      home: Scaffold(
        body: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isSignIn = true;
  bool _isLoading = false;
  String? _verificationId;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  void toggleForm() {
    setState(() {
      isSignIn = !isSignIn;
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> validateLogin(String username, String password) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref();
    DataSnapshot userSnapshot;

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _dbRef.child('users/$username').get();

      if (snapshot.exists) {
        if (snapshot.child('password').value == password) {
          // Log access in the Firebase Realtime Database
          await _logAccess(username);

          var role = snapshot.child("role").value as String?;
          if (role != null) {
            UserCredentials credentials = UserCredentials.fromJson(Map<dynamic,dynamic>.from(snapshot.value as Map));
            print(credentials.toJson());

            switch (role) {
              case "admin":

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp(userCredentials: credentials,)),
                );
                break;
              case "district":
              // District specific logic

              userSnapshot = await userRef.child('districtSecretaries/$username/approval').get();
              if(userSnapshot.exists?userSnapshot.value as String =="Approved":false){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DistrictApp(
                    credentials: credentials,
                  )),
                );
              }else{
                showErrorDialog('User not approved, Kindly wait for approval');
              }

                break;
              case "club":
              // Club specific logic
                userSnapshot = await userRef.child('clubs/$username/approval').get();
                if(userSnapshot.exists?userSnapshot.value as String =="Approved":false){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClubApp(
                      credentials: credentials,
                    )),
                  );
                }else{
                  showErrorDialog('User not approved, Kindly wait for approval');
                }
                break;
              case "official":
              // Official specific logic
              if(credentials.status!) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      OfficialsApp(
                        credentials: credentials,
                      )),
                );
              }else{
                showErrorDialog('Event Official status disabled, contact admin');
              }
                break;
              case "organiser":
              // Organiser specific logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrganisersApp(credentials: credentials,)),
                );
                break;

              default:
                _showSnackBar("Unknown role");
            }
          } else {
            _showSnackBar("Role is not defined for the user.");
          }
        } else {
          _showSnackBar('Invalid password');
        }
      } else {
        _showSnackBar("User Not Found");
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logAccess(String username) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _dbRef.child("accessLog/$timestamp").set('$username accessed the system.');
    await _dbRef.child("users/$username/accessLog/$timestamp").set('Accessed the system.');
  }

  Future<void> sendOTP(BuildContext context) async {

        if (_phoneController.text.trim().length == 12) {
      showAadhaarDialog();
    } else {
    // Save the context of the dialog for later use
    BuildContext? dialogContext;

    // Show the progress indicator dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context; // Assign dialog context
        return const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        );
      },
    );

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+91" + _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // await _auth.signInWithCredential(credential);
          //
          // // Close the dialog when verification is completed
          // if (dialogContext != null) {
          //   Navigator.pop(dialogContext!);
          // }
          // _navigateToSkaterHome();
        },
        verificationFailed: (FirebaseAuthException e) {
          // Close the dialog on verification failure
          if (dialogContext != null) {
            Navigator.pop(dialogContext!);
          }
          _showSnackBar('Failed to verify phone number: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });

          // Close the dialog once code is sent
          if (dialogContext != null) {
            Navigator.pop(dialogContext!);
          }

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return OTPDialog(verificationId: verificationId, userMobileNumber: _phoneController.text,); // Display OTP dialog
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      // Close the dialog on error
      if (dialogContext != null) {
        Navigator.pop(dialogContext!);
      }
      _showSnackBar('Error sending OTP: $e');
    }
  }
  }
 
 
  Future<void> sendAadhaarOTP(String aadhaar, String mobile) async {
    final url = 'http://103.174.10.153:4381/generate-otp/$aadhaar/$mobile/';
    BuildContext? dialogContext;

    // Show the progress indicator dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context; // Assign dialog context
        return const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        );
      },
    );

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        print(response.body);
        final verificationId = jsonDecode(response.body)['reference_id'].toString() ?? '';
        Navigator.pop(dialogContext!); // Close the progress dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AadhaarOTPDialog(verificationId: verificationId, userMobileNumber: mobile,aadhaarNumber: aadhaar,); // Display Aadhaar OTP dialog
          },
        );
      } else {
        Navigator.pop(dialogContext!); // Close the progress dialog
        _showSnackBar('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      Navigator.pop(dialogContext!); // Close the progress dialog
      _showSnackBar('Error sending OTP: $e');
    }
  }
  Future<void> verifyAadhaarOTP(String verificationId, String otp, String aadhaar, String mobile) async {
    final url = 'http://103.174.10.153:4381/verify-aadhaar-otp/$verificationId/aadhaar/$mobile/$aadhaar';
    final body = jsonEncode({'otp': otp});
    BuildContext? dialogContext;

    // Show the progress indicator dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context; // Assign dialog context
        return const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        );
      },
    );

    try {
      final response = await http.post(Uri.parse(url), body: body, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        Navigator.pop(dialogContext!); // Close the progress dialog
        _navigateToSkaterHome();
      } else {
        Navigator.pop(dialogContext!); // Close the progress dialog
        _showSnackBar('Failed to verify OTP. Please try again.');
      }
    } catch (e) {
      Navigator.pop(dialogContext!); // Close the progress dialog
      _showSnackBar('Error verifying OTP: $e');
    }
  }

  void showAadhaarDialog() {
    final TextEditingController aadhaarController = TextEditingController();
    final TextEditingController mobileController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Aadhaar and Mobile Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: aadhaarController,
                decoration: InputDecoration(labelText: 'Aadhaar Number'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: mobileController,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                sendAadhaarOTP(aadhaarController.text, mobileController.text);
              },
              child: Text('Send OTP'),
            ),
          ],
        );
      },
    );
  }

  


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  void _navigateToSkaterHome() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(userMobileNumber: _phoneController.text,)));
  }
  void showUsersDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 250,
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.blueAccent],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10)
              ),
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Registration?',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    VectorCardButton(
                      imageUrl: 'skater.json',
                      label: 'Skater',
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context){
                              double screenWidth = MediaQuery.sizeOf(context).width;
                              return AlertDialog(
                                content: Container(
                                    width: screenWidth>600?400:screenWidth,
                                    child: SkaterRegistration(dialogContext: context,)
                                ),
                                contentPadding: EdgeInsets.all(0),
                              );
                            }
                        );

                      },
                    ),
                    SizedBox(width: 10,),

                    VectorCardButton(
                      imageUrl: 'district-secretary.json',
                      label: 'District \n Secretary',
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context){
                              double screenWidth = MediaQuery.sizeOf(context).width;
                              return AlertDialog(
                                content: Container(
                                    width: screenWidth>600?600:screenWidth,
                                    child: DistrictSecretaryRegistration(dialogContext: context,)),
                                contentPadding: EdgeInsets.all(0),
                              );
                            }
                        );

                      },
                    ),
                    SizedBox(width: 10,),

                    VectorCardButton(
                      imageUrl: 'club.json',
                      label: 'Club',
                      onTap: () {

                        showDialog(
                            context: context,
                            builder: (context){
                              double screenWidth = MediaQuery.sizeOf(context).width;
                              return AlertDialog(
                                content: Container(
                                    width: screenWidth>600?600:screenWidth,
                                    child: ClubRegistration(dialogContext: context,)),
                                contentPadding: EdgeInsets.all(0),
                              );
                            }
                        );
                      },
                    ),
                    SizedBox(width: 10,),
                  ],
                ),
              ],
            ),
          ),
          contentPadding: EdgeInsets.all(0),
        );
      },
    );
  }



  static const List<String> officialsText = [
    "Welcome",
    "Welcome back!",
  ];

  List<Widget> animations = [
    ScaleMorphingText(
      texts: officialsText,
      loopForever: false,
      textStyle: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double val = screenWidth >= 1200
        ? 400.0
        : screenWidth >= 950
        ? 400.0
        : screenWidth >= 800
        ? 400.0
        : screenWidth >= 780
        ? 385.0
        : screenWidth >= 750
        ? 370.0
        : screenWidth >= 725
        ? 360.0
        : screenWidth >= 700
        ? 350.0
        : screenWidth >= 675
        ? 335.0
        : screenWidth >= 650
        ? 320.0
        : screenWidth >= 620
        ? 310.0
        : screenWidth - 50;
    return Scaffold(
      backgroundColor: Color(0xff2196F3FF),
      body: LayoutBuilder(

        builder: (context, constraints) {
          if (constraints.maxWidth > 620) {
            return Column(
               mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomAppBar(),
                SizedBox(height: 50,),
                Container(
                  width: 800,
                  height: 500,
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        left: isSignIn ? 0.0 : val,
                        right: isSignIn ? val : 0.0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: isSignIn?Radius.circular(0):Radius.circular(10),
                              bottomRight: isSignIn?Radius.circular(0):Radius.circular(10),
                              bottomLeft: isSignIn?Radius.circular(10):Radius.circular(0),
                              topLeft: isSignIn?Radius.circular(10):Radius.circular(0),

                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Image.asset(
                                  'assets/logo.jpg',
                                  width: 200,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  isSignIn ? 'Sign in' : 'Sign up',
                                  style: GoogleFonts.roboto(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'Enter your account details',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 20),
                                CustomTextField(label: isSignIn?'Username':'Registered Mobile Number', controller:isSignIn?_usernameController: _phoneController,),
                                if (isSignIn)SizedBox(height: 20),
                                if (isSignIn)CustomTextField(
                                    label: 'Password', obscureText: true, controller: _passwordController,),
                                // SizedBox(height: 10),
                                // if (isSignIn)
                                //   TextButton(
                                //     onPressed: () {},
                                //     child: Text('Forgot your password?'),
                                //   ),

                                SizedBox(height: 10),

                                ElevatedButton(
                                  onPressed: () {
                                    isSignIn?validateLogin(_usernameController.text,_passwordController.text):sendOTP(context);

                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 100, vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(isSignIn ? 'SIGN IN' : 'Send OTP'),
                                ),

                                SizedBox(height:10),
                                TextButton(
                                  onPressed: () {
                                    toggleForm();
                                  },
                                  child: Text(isSignIn?'Skater Login?':'Officials Login?'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: Duration(milliseconds: 300),
                        left: isSignIn ? val : 0.0,
                        right: isSignIn ? 0.0 : val,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.lightBlueAccent],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            borderRadius: BorderRadius.only(
                              topRight: isSignIn?Radius.circular(10):Radius.circular(0),
                              bottomRight: isSignIn?Radius.circular(10):Radius.circular(0),
                              bottomLeft: isSignIn?Radius.circular(0):Radius.circular(10),
                              topLeft: isSignIn?Radius.circular(0):Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              animations[0],
                              SizedBox(height: 40),
                              Text(
                                isSignIn
                                    ? 'Enter your personal details and start journey with us'
                                    : 'To keep connected with us please login with your personal info',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'To keep connected with us please login with your personal info',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 40),


                              AnimatedButton(
                                onTap: () {
                                  showUsersDialog();
                                },
                                label: 'New Registration',
                                icon: Icons.ac_unit,
                                buttonColor: Colors.white,

                              )

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50,),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('New Registration?',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        ),
                      ),
                      SizedBox(height: 10,),
                      Row(

                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          VectorCardButton(
                            imageUrl: 'skater.json',
                            label: 'Skater',
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    double screenWidth = MediaQuery.sizeOf(context).width;
                                    return AlertDialog(
                                      content: Container(
                                          width: screenWidth>600?400:screenWidth,
                                          child: SkaterRegistration(dialogContext: context,)
                                      ),
                                      contentPadding: EdgeInsets.all(0),
                                    );
                                  }
                              );

                            },
                          ),
                          SizedBox(width: 10,),

                          VectorCardButton(
                            imageUrl: 'district-secretary.json',
                            label: 'District \n Secretary',
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context){
                                    double screenWidth = MediaQuery.sizeOf(context).width;
                                    return AlertDialog(
                                      content: Container(
                                          width: screenWidth>600?600:screenWidth,
                                          child: DistrictSecretaryRegistration(dialogContext: context,)),
                                      contentPadding: EdgeInsets.all(0),
                                    );
                                  }
                              );

                            },
                          ),
                          SizedBox(width: 10,),

                          VectorCardButton(
                            imageUrl: 'club.json',
                            label: 'Club',
                            onTap: () {

                              showDialog(
                                  context: context,
                                  builder: (context){
                                    double screenWidth = MediaQuery.sizeOf(context).width;
                                    return AlertDialog(
                                      content: Container(
                                          width: screenWidth>600?600:screenWidth,
                                          child: ClubRegistration(dialogContext: context,)),
                                      contentPadding: EdgeInsets.all(0),
                                    );
                                  }
                              );
                            },
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Mobile view
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Toggle section
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey<bool>(!isSignIn),
                        padding: EdgeInsets.all(32),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.pink, Colors.red],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isSignIn ? 'Hello, Friend!' : 'Welcome Back!',
                              style: GoogleFonts.roboto(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              isSignIn
                                  ? 'Enter your personal details and start journey with us'
                                  : 'To keep connected with us please login with your personal info',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: toggleForm,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, backgroundColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 20),
                                side: BorderSide(color: Colors.white, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(isSignIn ? 'SIGN UP' : 'SIGN IN'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sign in / Sign up section
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey<bool>(isSignIn),
                        padding: EdgeInsets.all(32),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://sport-ims.in/public/websiteAssets/logo.jpg',
                              width: 200,
                            ),
                            SizedBox(height: 20),

                            Text(
                              isSignIn ? 'Sign in' : 'Sign up',
                              style: GoogleFonts.roboto(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),

                            Text(
                              'Enter your account details',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 20),
                            CustomTextField(label: 'Email', controller: _usernameController,),
                            SizedBox(height: 20),
                            CustomTextField(
                                label: 'Password', obscureText: true, controller: _passwordController,),
                            if (!isSignIn) ...[
                              SizedBox(height: 20),
                              CustomTextField(label: 'Confirm Password', obscureText: true, controller: _passwordController,),
                            ],
                            SizedBox(height: 10),
                            // if (isSignIn)
                            //   TextButton(
                            //     onPressed: () {},
                            //     child: Text('Forgot your password?'),
                            //   ),
                            // SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(isSignIn ? 'SIGN IN' : 'SIGN UP'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

}

class SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SocialButton({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color,
      child: Icon(icon, color: Colors.white),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final TextEditingController controller;


  const CustomTextField({
    required this.label,
    this.obscureText = false, required this.controller,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
      ),
    );
  }
}


class CustomDialogButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const CustomDialogButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  _CustomDialogButtonState createState() => _CustomDialogButtonState();
}

class _CustomDialogButtonState extends State<CustomDialogButton> {
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => setState(() => isPressed = true),
            onTapUp: (_) {
              setState(() => isPressed = false);
              widget.onTap();
            },
            onTapCancel: () => setState(() => isPressed = false),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              transform: isPressed ?( Matrix4.identity()..scale(0.9)) : Matrix4.identity(),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isHovered ? widget.color.withOpacity(0.8) : widget.color,
                boxShadow: isPressed
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.transparent,
                child: Icon(widget.icon, size: 30, color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(widget.label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 16),
      ],
    );
  }
}


class AnimatedButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final Color? buttonColor;
  final Color? textColor;
  final VoidCallback onTap;

  const AnimatedButton({
    required this.label,
    required this.icon,
    required this.buttonColor,
    required this.onTap,
    this.textColor,
  });

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) {
          setState(() => isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => isPressed = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          transform: isPressed
              ? (Matrix4.identity()..scale(0.95))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: isHovered
                ? (widget.buttonColor?.withOpacity(0.5) ?? Colors.red.withOpacity(0.8))
                : (widget.buttonColor ?? Colors.red),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isPressed
                ? []
                : [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 32),
          child: widget.label != null
              ? Text(
            widget.label!,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.textColor ?? Colors.blue,
            ),
          )
              : Icon(widget.icon, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}


class VectorCardButton extends StatefulWidget {
  final String imageUrl;
  final String label;
  final VoidCallback onTap;

  const VectorCardButton({
    required this.imageUrl,
    required this.label,
    required this.onTap,
  });

  @override
  _VectorCardButtonState createState() => _VectorCardButtonState();
}

class _VectorCardButtonState extends State<VectorCardButton> {
  bool isHovered = false;
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) {
          setState(() => isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => isPressed = false),
        child: Tooltip(
          message: "Click here create new ${widget.label} account",
          waitDuration: const Duration(seconds: 1),
          preferBelow: false,
          enableTapToDismiss: true,
          child: AnimatedContainer(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 120,
            width: 120,
            duration: const Duration(milliseconds: 200),
            transform: isPressed
                ? (Matrix4.identity()..scale(0.95))
                : isHovered
                ? (Matrix4.identity()..scale(1.1))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color:  Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: isPressed
                  ? []
                  : [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: isHovered ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Lottie.asset(
                  widget.imageUrl,
                  height: 50,
                  width: 50,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class OTPDialog extends StatefulWidget {
  final String verificationId; // Add verificationId as a parameter to the OTPDialog
  final String userMobileNumber;

  OTPDialog({required this.verificationId, required this.userMobileNumber});

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _navigateToSkaterHome() async {
    DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('skaters/${widget.userMobileNumber}/approval/');
    DataSnapshot snapshot = await  dbRef.get();
    if(snapshot.value!=null){
      if(snapshot.value=="Approved"){
        Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(userMobileNumber: widget.userMobileNumber,))); // Navigate to PlayerScreen
      }
      else{
        showErrorDialog('Skater not approved, Kindly wait for approval');
      }
    }
    else{
      showErrorDialog('Skater not Registered, Kindly register new account');
    }
  }
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  // Concatenate the values of the OTP fields to create the complete OTP
  String get _otp {
    return _controllers.map((controller) => controller.text).join();
  }

  void _nextField(String value, int index) {
    if (value.length == 1 && index < _focusNodes.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
  }

  void _previousField(String value, int index) {
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Future<void> _submitOTP() async {
    if (_otp.length == 6) {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, // Use the verificationId passed from the parent widget
          smsCode: _otp,
        );

        // Use Firebase Auth to sign in with the credential
        await FirebaseAuth.instance.signInWithCredential(credential);
        _navigateToSkaterHome();
      } catch (e) {
        _showSnackBar('Invalid OTP. Please try again.');
      }
    } else {
      _showSnackBar('Please enter a valid 6-digit OTP.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 400,
        height: 250,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Column(
          children: [
            const Text(
              'Enter Received OTP',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(
                  width: 40,
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _nextField(value, index);
                      _previousField(value, index);
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedButton(
                  label: 'Cancel',
                  icon: null,
                  buttonColor: Colors.grey,
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                AnimatedButton(
                  label: 'Submit',
                  icon: null,
                  buttonColor: Colors.blueAccent,
                  textColor: Colors.white,
                  onTap: _submitOTP, // Call the _submitOTP function when submitting the OTP
                ),
              ],
            )
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(0),
    );
  }
}



  class AadhaarOTPDialog extends StatefulWidget {
    final String verificationId;
    final String userMobileNumber;
    final String aadhaarNumber;

    AadhaarOTPDialog({required this.verificationId, required this.userMobileNumber, required this.aadhaarNumber});

    @override
    _AadhaarOTPDialogState createState() => _AadhaarOTPDialogState();
  }

  class _AadhaarOTPDialogState extends State<AadhaarOTPDialog> {
    final TextEditingController _otpController = TextEditingController();

    void _showSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> _submitOTP() async {
      if (_otpController.text.length == 6) {
        try {
          final url = 'http://103.174.10.153:4381/verify-aadhaar-otp/${widget.verificationId}/aadhaar/${widget.userMobileNumber}/${_otpController.text}';
          final response = await http.post(Uri.parse(url));
          if (response.statusCode == 200) {
            Navigator.pop(context); // Close the OTP dialog
            _navigateToSkaterHome();
          } else {
            _showSnackBar('Failed to verify OTP. Please try again.');
          }
        } catch (e) {
          _showSnackBar('Error verifying OTP: $e');
        }
      } else {
        _showSnackBar('Please enter a valid 6-digit OTP.');
      }
    }

    Future<void> _navigateToSkaterHome() async {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref().child('skaters/${widget.userMobileNumber}/approval/');
      DataSnapshot snapshot = await dbRef.get();
      if (snapshot.value != null) {
        if (snapshot.value == "Approved") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(userMobileNumber: widget.userMobileNumber))); // Navigate to PlayerScreen
        } else {
          showErrorDialog('Skater not approved, Kindly wait for approval');
        }
      } else {
        showErrorDialog('Skater not Registered, Kindly register new account');
      }
    }

    void showErrorDialog(String message) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        content: Container(
          width: 400,
          height: 250,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Column(
            children: [
              const Text(
                'Enter Received OTP',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  counterText: "",
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _submitOTP,
                    child: Text('Submit'),
                  ),
                ],
              )
            ],
          ),
        ),
        contentPadding: const EdgeInsets.all(0),
      );
    }
  }

