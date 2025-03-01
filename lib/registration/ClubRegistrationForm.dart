import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

import 'package:morphing_text/morphing_text.dart';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

import 'package:morphing_text/morphing_text.dart';

import '../loginApp/LoginApp.dart';
import '../utils/Constants.dart';
import '../utils/Controllers.dart';
import '../utils/MessageHelper.dart';
import '../utils/Widgets.dart';

class ClubRegistration extends StatelessWidget {
  final BuildContext dialogContext;

  ClubRegistration({required this.dialogContext});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: ClubRegistrationForm(dialogContext: dialogContext),
        ),
      ),
    );
  }
}

class ClubRegistrationForm extends StatefulWidget {
  final BuildContext dialogContext;

  ClubRegistrationForm({required this.dialogContext});

  @override
  ClubRegistrationFormState createState() {
    return ClubRegistrationFormState();
  }
}

class ClubRegistrationFormState extends State<ClubRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _masterNameController = TextEditingController();
  final TextEditingController _coachNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _societyCertificateNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();

  Uint8List? _societyCertificateData;
  String? _societyCertificateName;
  String? _selectedState;
  String? _selectedDistrict;

  String? _verificationId;


  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  @override
  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _clubNameController.dispose();
    _masterNameController.dispose();
    _coachNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    _societyCertificateNumberController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }

  void _pickSocietyCertificate() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );
    setState(() {
      _societyCertificateData = result?.files.first.bytes;
      _societyCertificateName = result != null ? result.files.first.name : 'No file selected';
    });
  }

  bool isValidEmail(String email) {
    RegExp regex = RegExp(
      r'^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$',
      caseSensitive: false,
      multiLine: false,
    );
    return regex.hasMatch(email);
  }

  bool isValidContactNumber(String contactNumber) {
    RegExp regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(contactNumber);
  }

  Future<void> _uploadFilesAndData() async {
    String clubName = _clubNameController.text.trim();
    String masterName = _masterNameController.text.trim();
    String coachName = _coachNameController.text.trim();
    String email = _emailController.text.trim();
    String contactNumber = _contactNumberController.text.trim();
    String address = _addressController.text.trim();
    String societyCertificateNumber = _societyCertificateNumberController.text.trim();
    String password = _passwordController.text.trim();
    String reEnterPassword = _reEnterPasswordController.text.trim();

    // Validate fields
    if (clubName.isEmpty ||
        masterName.isEmpty ||
        coachName.isEmpty ||
        email.isEmpty ||
        contactNumber.isEmpty ||
        address.isEmpty ||
        societyCertificateNumber.isEmpty ||
        _societyCertificateData == null ||
        _selectedState == null ||
        _selectedDistrict == null ||
        password.isEmpty ||
        reEnterPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields and upload documents')),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (!isValidContactNumber(contactNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit contact number')),
      );
      return;
    }

    if (password != reEnterPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters long')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ));
      },
    );

    // Proceed with file upload and data submission
    try {
      // Generate unique filename for the uploaded file
      String societyCertificateFileName = DateTime.now().millisecondsSinceEpoch.toString() + "_" + _societyCertificateName!;

      // Upload file to Firebase Storage (assume _firebaseStorage instance is available)
      Reference societyCertificateRef = _firebaseStorage.ref().child('club_documents/$societyCertificateFileName');
      await societyCertificateRef.putData(_societyCertificateData!);

      // Get download URL
      String societyCertificateUrl = await societyCertificateRef.getDownloadURL();

      // Prepare data for Firebase Realtime Database (assume _databaseReference instance is available)
      final formData = {
        'id':await generateClubID(_selectedState!, _selectedDistrict!),
        'clubName': clubName,
        'masterName': masterName,
        'coachName': coachName,
        'email': email,
        'contactNumber': contactNumber,
        'address': address,
        'societyCertificateNumber': societyCertificateNumber,
        'docUrl': societyCertificateUrl, // Uncomment when Firebase code is implemented
        'state': _selectedState,
        'district': _selectedDistrict,
        'regDate': DateFormat('yyyy-MM-dd').format(DateTime.now()), // Current date
        'approval': 'Pending',
        'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // Current timestamp
        'status': false,
        'updatedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // Current timestamp
        'password': password, // Store password securely (consider hashing)
      };



      // Upload metadata to Firebase Realtime Database
       await _databaseReference.child('clubs').child(formData['id'] as String).set(formData); // Uncomment when Firebase code is implemented
       await _databaseReference.child('users').child(formData['id'] as String)
           .set({
            "username":formData['id'] as String,
            "password":password,
            "status":false,
            "role":"club"
             });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data uploaded successfully')),
      );

      sendRegistrationSuccessful(name: clubName!, role: 'Club User <br> Username : ${formData['id'] as String} <br> password : $password <br> ', companyName: 'Sport-IMS', phoneNumber: contactNumber!, email: email!);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Registration Completed'),
            content: Text('Your Club Registration has been successfully completed, kindly wait for the approval'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(widget.dialogContext);
                  Navigator.pop(widget.dialogContext);
                  Navigator.pop(widget.dialogContext);
                  Navigator.pop(widget.dialogContext);
                },
                child: Text("Ok"),
              ),
            ],
          );
        },
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload data: $e')),
      );
    }
  }


  Future<void> _verifyOtp(String otp) async {
    try {
      // Create a PhoneAuthCredential with the OTP code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // On successful verification, proceed to save data
      _uploadFilesAndData();
    } catch (e) {
      // Handle incorrect OTP
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect OTP')),
      );
    }
  }

  void _showOtpField() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Enter OTP"),
          content: OtpTextField(
            numberOfFields: 6,
            keyboardType: TextInputType.number,
            borderColor: const Color(0xFF512DA8),
            showFieldAsBox: true,
            onSubmit: (String otp) {
              _verifyOtp(otp);
            }, // When all fields are filled
          ),
          actions: [
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
              onTap: (){}, // Call the _submitOTP function when submitting the OTP
            ),
          ],
        );
      },
    );
  }

// Function to initiate phone number verification
  Future<void> _verifyPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${_contactNumberController.text}', // Add your country code
      verificationCompleted: (PhoneAuthCredential credential) async {
        // // On auto verification complete
        // await FirebaseAuth.instance.signInWithCredential(credential);
        // // Proceed with saving the form
        // _uploadToFirebase();
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Failed: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // Store the verification ID and prompt for OTP input
        setState(() {
          _verificationId = verificationId;
        });
        _showOtpField();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Handle timeout
        _verificationId = verificationId;
      },
    );
  }

  static const List<String> text = [
    "Club",
    "Club Registration",
  ];

  List<Widget> animations = [
    ScaleMorphingText(
      texts: text,
      loopForever: false,
      textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.black),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarOpacity: 1,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Container(
          margin: EdgeInsets.only(left: 80),
          child: animations[0],
        ),
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //   },
        //   icon: Icon(Icons.arrow_back_rounded),
        // ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: buildTitleAndField('Name of the Club', 'Enter club name', controller: _clubNameController),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: buildTitleAndField('Master Name', 'Enter master name', controller: _masterNameController),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: buildTitleAndField('Coach Name', 'Enter coach name', controller: _coachNameController),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: buildTitleAndDropdown('Select State', 'Select state',
                        Constants().states.map((e) => e.name).toList(), _selectedState, (value) {
                          setState(() {
                            _selectedState = value;
                            _selectedDistrict = null;
                          });
                        }),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: buildTitleAndDropdown(
                        'Select District', 'Select district',
                        Constants().districts.where((element) => element.state.toLowerCase() == _selectedState?.toLowerCase(),).map((e) => e.name).toList(),
                        _selectedDistrict, (value) {
                      setState(() {
                        _selectedDistrict = value;
                      });
                    }),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: buildTitleAndField('Club Official Email ID', 'Enter official email ID', controller: _emailController),
                  ),
                ],
              ),
              SizedBox(height: 16),
              buildTitleAndField('Address of the Club', 'Enter club address', isMultiline: true, controller: _addressController),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: buildTitleAndField('Club Contact Number', 'Enter contact number', controller: _contactNumberController),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: buildTitleAndField('Society Certificate Number', 'Enter society certificate number', controller: _societyCertificateNumberController),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Society Certificate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _pickSocietyCertificate,
                  icon: Icon(Icons.upload_file, color: Colors.white),
                  label: Text(
                    'Upload Document',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blueAccent,
                    side: BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              if (_societyCertificateName != null) ...[
                SizedBox(height: 8),
                Text(
                  _societyCertificateName!,
                  style: TextStyle(color: Colors.black87),
                ),
              ],
              SizedBox(height: 8),
              Text(
                'Only JPEG and PDFs are accepted.',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: buildTitleAndField('Create Password', 'Enter password', controller: _passwordController),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: buildTitleAndField('Re-enter Password', 'Re-enter password', controller: _reEnterPasswordController),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {

                        String clubName = _clubNameController.text.trim();
                        String masterName = _masterNameController.text.trim();
                        String coachName = _coachNameController.text.trim();
                        String email = _emailController.text.trim();
                        String contactNumber = _contactNumberController.text.trim();
                        String address = _addressController.text.trim();
                        String societyCertificateNumber = _societyCertificateNumberController.text.trim();
                        String password = _passwordController.text.trim();
                        String reEnterPassword = _reEnterPasswordController.text.trim();

                        // Validate fields
                        if (clubName.isEmpty ||
                            masterName.isEmpty ||
                            coachName.isEmpty ||
                            email.isEmpty ||
                            contactNumber.isEmpty ||
                            address.isEmpty ||
                            societyCertificateNumber.isEmpty ||
                            _societyCertificateData == null ||
                            _selectedState == null ||
                            _selectedDistrict == null ||
                            password.isEmpty ||
                            reEnterPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please fill all required fields and upload documents')),
                          );
                          return;
                        }

                        if (!isValidEmail(email)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter a valid email address')),
                          );
                          return;
                        }

                        if (!isValidContactNumber(contactNumber)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter a valid 10-digit contact number')),
                          );
                          return;
                        }

                        if (password != reEnterPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Passwords do not match')),
                          );
                          return;
                        }

                        if (password.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Password must be at least 6 characters long')),
                          );
                          return;
                        }

                        _verifyPhoneNumber();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Processing Data')),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Text('Next', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                        Icon(Icons.arrow_forward_rounded, color: Colors.blueAccent),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
