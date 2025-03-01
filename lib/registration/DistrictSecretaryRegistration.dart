import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart'; // For date formatting

import 'package:morphing_text/morphing_text.dart';

import '../loginApp/LoginApp.dart';
import '../utils/Constants.dart';
import '../utils/Controllers.dart';
import '../utils/MessageHelper.dart';
import '../utils/Widgets.dart';


class DistrictSecretaryRegistration extends StatelessWidget {

  final BuildContext dialogContext;
  DistrictSecretaryRegistration({required this.dialogContext});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white
      ),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.all(15),
          // margin: EdgeInsets.all(15),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
          ),
          child: DistrictSecretaryRegistrationForm(dialogContext: dialogContext,),
        ),
      ),
    );
  }
}


class DistrictSecretaryRegistrationForm extends StatefulWidget {
  BuildContext dialogContext;
  DistrictSecretaryRegistrationForm({required this.dialogContext});

  @override
  DistrictSecretaryRegistrationFormState createState() {
    return DistrictSecretaryRegistrationFormState();
  }
}

class DistrictSecretaryRegistrationFormState extends State<DistrictSecretaryRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aadharNumberController = TextEditingController();
  final TextEditingController _societyCertificateNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reEnterPasswordController = TextEditingController();

  Uint8List? _societyCertificateData;
  Uint8List? _aadharDocumentData;
  String? _societyCertificateName;
  String? _aadharDocumentName;
  String? _selectedState;
  String? _selectedDistrict;

  String? _verificationId;

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    // Initialize other necessary states if needed
  }

  @override
  void dispose() {
    // Dispose of controllers to avoid memory leaks
    _nameController.dispose();
    _addressController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _aadharNumberController.dispose();
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
      _societyCertificateName = result != null ? result.files.first.name : 'No file selected';
      _societyCertificateData = result?.files.first.bytes;

    });
  }

  void _pickAadharDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );
    setState(() {
      _aadharDocumentName = result != null ? result.files.first.name : 'No file selected';
      _aadharDocumentData = result?.files.first.bytes;

    });
  }


  Future<void> _uploadFilesAndData() async {
    // Extract values from the controllers


   String _name = _nameController.text.trim();
   String _address = _addressController.text.trim();
   String _contactNumber = _contactNumberController.text.trim();
   String _email = _emailController.text.trim();
   String _aadharNumber = _aadharNumberController.text.trim();
   String _societyCertificateNumber = _societyCertificateNumberController.text.trim();
   String password = _passwordController.text.trim();
   String reEnterPassword = _reEnterPasswordController.text.trim();
    // Check if all required fields are filled
    if (
    _name!.isEmpty ||
        _address!.isEmpty ||
        _contactNumber!.isEmpty ||
        _email!.isEmpty ||
        _societyCertificateNumber!.isEmpty ||
        _societyCertificateData==null||
        _aadharDocumentData==null ||
        _selectedState == null ||
        _selectedDistrict == null
    ) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and upload documents')),
      );

      return;
    }

    // Validate email and contact number
    if (!isValidEmail(_email!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (!isValidPhoneNumber(_contactNumber!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit contact number')),
      );
      return;
    }


    // Validate passwords
    if (password != reEnterPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );

      return;
    }

    if (password.length < 6) { // Example minimum length check
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters long')),
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
      // Generate unique filenames for the uploaded files
      String societyCertificateFileName = DateTime.now().millisecondsSinceEpoch.toString() + "_" + _societyCertificateName!;
      String aadharDocumentFileName = DateTime.now().millisecondsSinceEpoch.toString() + "_" + _aadharDocumentName!;

      // Upload files to Firebase Storage
      Reference societyCertificateRef = _firebaseStorage.ref().child('documents/$societyCertificateFileName');
      Reference aadharDocumentRef = _firebaseStorage.ref().child('documents/$aadharDocumentFileName');

      await societyCertificateRef.putData(_societyCertificateData!);
      await aadharDocumentRef.putData(_aadharDocumentData!);

      // Get download URLs
      String societyCertificateUrl = await societyCertificateRef.getDownloadURL();
      String aadharDocumentUrl = await aadharDocumentRef.getDownloadURL();

      String districtSecretaryID = await generateDistrictSecretaryID(_selectedState!,_selectedDistrict!);
      // Prepare data for Firebase Realtime Database
      final formData = {
        'id': districtSecretaryID,
        'name': _name,
        'address': _address,
        'contactNumber': _contactNumber,
        'email': _email,
        'adharNumber': _aadharNumber,
        'societyCertificateNumber': _societyCertificateNumber,
        'docUrl': societyCertificateUrl, // Assuming docUrl is for the society certificate
        'aadhaarUrl': aadharDocumentUrl, // Assuming docUrl is for the Aadhaar document
        'districtName': _selectedDistrict,
        'stateName': _selectedState,
        'regDate': DateFormat('yyyy-MM-dd').format(DateTime.now()), // Current date
        'approval': 'Pending',
        'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // Current timestamp
        'status': true,
        'updatedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()), // Current timestamp
        'password': password, // Store password securely (consider hashing)
      };

      // Upload metadata to Firebase Realtime Database
      await _databaseReference.child('districtSecretaries').child(formData['id'] as String).set(formData);
      await _databaseReference.child('users').child(districtSecretaryID)
          .set({
        "username":districtSecretaryID,
        "password":password,
        "status":false,
        "role":"district"
      });

      sendRegistrationSuccessful(name: _name, role: 'District Secretary <br>  Username : $districtSecretaryID <br>  password : $password <br> ', companyName: 'Sport-IMS', phoneNumber: _contactNumber, email: _email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data uploaded successfully')),
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Completed'),
            content: const Text('Your District Secretary Registration has been successfully Completed, Kindly wait for the approval'),
            actions: [
              TextButton(onPressed: (){
                Navigator.pop(widget.dialogContext);
                Navigator.pop(widget.dialogContext);
                Navigator.pop(widget.dialogContext);
                Navigator.pop(widget.dialogContext);
              }, child:const Text("Ok"))
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
    "District Secretary",
    "District Secretary Registration",
  ];

  List<Widget> animations = [
    ScaleMorphingText(
      texts: text,
      loopForever: false,
      textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.black),
    ),
  ];

  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarOpacity: 1,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Container(
          margin: EdgeInsets.only(left: 120),
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
                    child: buildTitleAndField('Name (As per Aadhar)', 'Enter name', controller: _nameController),
                  ),
                ],
              ),
              SizedBox(height: 16),
              buildTitleAndField('Official Communication Address', 'Enter address', isMultiline: true, controller: _addressController),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: buildTitleAndDropdown('Select State', 'Select state',
                        Constants().states.map((e) => e.name).toList(), _selectedState, (value) {
                          setState(() {
                            _selectedState = value;
                            _selectedDistrict = null;
                          });
                        }),
                  ),
                  SizedBox(width: 16),
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
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: buildTitleAndField('Email', 'Enter email', controller: _emailController),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: buildTitleAndField('Contact Number', 'Enter contact number', controller: _contactNumberController),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: buildTitleAndField('Society Certificate Number', 'Enter society certificate number', controller: _societyCertificateNumberController),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: buildTitleAndField('Aadhar Number', 'Enter Aadhar number', controller: _aadharNumberController),
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
              Text(
                'Aadhar Document',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _pickAadharDocument,
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
              if (_aadharDocumentName != null) ...[
                SizedBox(height: 8),
                Text(
                  _aadharDocumentName!,
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
                    child: buildTitleAndField('Re-Enter Password', 'Re-enter password', controller: _reEnterPasswordController),
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


                        String _name = _nameController.text.trim();
                        String _address = _addressController.text.trim();
                        String _contactNumber = _contactNumberController.text.trim();
                        String _email = _emailController.text.trim();
                        String _aadharNumber = _aadharNumberController.text.trim();
                        String _societyCertificateNumber = _societyCertificateNumberController.text.trim();
                        String password = _passwordController.text.trim();
                        String reEnterPassword = _reEnterPasswordController.text.trim();
                        // Check if all required fields are filled
                        if (
                        _name!.isEmpty ||
                            _address!.isEmpty ||
                            _contactNumber!.isEmpty ||
                            _email!.isEmpty ||
                            _societyCertificateNumber!.isEmpty ||
                            _societyCertificateData==null||
                            _aadharDocumentData==null ||
                            _selectedState == null ||
                            _selectedDistrict == null
                        ) {

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all required fields and upload documents')),
                          );

                          return;
                        }

                        // Validate email and contact number
                        if (!isValidEmail(_email!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid email address')),
                          );
                          return;
                        }

                        if (!isValidPhoneNumber(_contactNumber!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid 10-digit contact number')),
                          );
                          return;
                        }


                        // Validate passwords
                        if (password != reEnterPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Passwords do not match')),
                          );

                          return;
                        }

                        if (password.length < 6) { // Example minimum length check
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password must be at least 6 characters long')),
                          );

                          return;
                        }

                        _verifyPhoneNumber();

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
