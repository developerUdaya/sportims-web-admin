import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:path/path.dart' as path;
import 'package:sport_ims/utils/MessageHelper.dart';
import '../loginApp/LoginApp.dart';
import '../utils/Constants.dart';
import '../utils/Controllers.dart';
import '../utils/Widgets.dart';
import '../utils/Controllers.dart';
import '../utils/DateFormatter.dart';
import '../utils/Widgets.dart'; // Import this for handling file paths

class SkaterRegistration extends StatelessWidget {
  final BuildContext dialogContext;
  SkaterRegistration({required this.dialogContext}); // Constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: 1000,

          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            borderRadius: BorderRadius.circular(10),
          ),
          child: SkaterRegistrationForm(dialogContext: dialogContext),
        ),
      ),
    );
  }
}

class SkaterRegistrationForm extends StatefulWidget {
  BuildContext dialogContext;
  SkaterRegistrationForm({super.key, required this.dialogContext});

  @override
  SkaterRegistrationFormState createState() {
    return SkaterRegistrationFormState();
  }
}

class SkaterRegistrationFormState extends State<SkaterRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  Uint8List? _profilePhotoData;
  String? _profilePhotoName;
  Uint8List? _documentData;
  String? _documentName;
  PlatformFile? _profilePhotoFile; // To store file details
  PlatformFile? _documentFile;

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedClub;
  String? _selectedBloodGroup;
  String? _selectedGender;
  String? _selectedCategory;

  String? _verificationId;

  bool profileImageError = false;
  bool docFileError = false;

  List<Map<String, dynamic>> _clubsList = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _affiliationNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();

  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();

    _fetchClubsData();
  }

  void _pickProfilePhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    setState(() {
      _profilePhotoName =
      result != null ? result.files.first.name : 'No file selected';
      _profilePhotoData = result != null ? result.files.first.bytes : null;
      _profilePhotoFile = result?.files.first;

    });
  }

  void _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [ 'pdf'],
    );
    setState(() {
      _documentName =
      result != null ? result.files.first.name : 'No file selected';
      _documentData = result?.files.first.bytes;
      _documentFile = result?.files.first;
    });
  }

  Future<void> _uploadToFirebase() async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ));
      },
    );

    String contactNumber = _contactNumberController.text;

    // Check if contact number already exists
    DatabaseReference ref = database.ref().child('skaters/$contactNumber');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number already exists')),
      );

      Navigator.pop(widget.dialogContext);
      return;
    }

    String? profileImageUrl;
    String? docFileUrl;


// Assuming _profilePhotoFile and _documentFile are of type PlatformFile

    if (_profilePhotoData != null && _profilePhotoFile != null) {
      // Get the original file extension of the profile photo
      String profileFileExtension = path.extension(_profilePhotoFile!.name);
      String profileFileName = 'profile_$contactNumber$profileFileExtension';

      TaskSnapshot uploadProfileSnapshot = await storage
          .ref()
          .child('skaters/$contactNumber/$profileFileName')
          .putData(_profilePhotoData!);

      profileImageUrl = await uploadProfileSnapshot.ref.getDownloadURL();
    }

    if (_documentData != null && _documentFile != null) {
      // Get the original file extension of the document
      String documentFileExtension = path.extension(_documentFile!.name);
      String documentFileName = 'document_$contactNumber$documentFileExtension';

      TaskSnapshot uploadDocumentSnapshot = await storage
          .ref()
          .child('skaters/$contactNumber/$documentFileName')
          .putData(_documentData!);

      docFileUrl = await uploadDocumentSnapshot.ref.getDownloadURL();
    }

    String skaterID= await generateSkaterID(_selectedState!,_selectedDistrict!);

    // Upload data to Firebase Realtime Database
    ref.set({
      'skaterID': skaterID,
      'name': _nameController.text,
      'address': _addressController.text,
      'state': _selectedState,
      'district': _selectedDistrict,
      'school': _schoolController.text,
      'schoolAffiliationNumber': _affiliationNumberController.text,
      'club': _selectedClub,
      'email': _emailController.text,
      'contactNumber': contactNumber,
      'bloodGroup': _selectedBloodGroup,
      'gender': _selectedGender,
      'skateCategory': _selectedCategory,
      'aadharBirthCertificateNumber': _aadharController.text,
      'dateOfBirth': _dobController.text,
      'profileImageUrl': profileImageUrl,
      'docFileUrl': docFileUrl,
      'regDate': DateTime.now().toIso8601String(),
      'approval': 'Pending'
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration completed successfully')),
    );

    sendPlayerRegistration(playerId: skaterID, name: _nameController.text, phoneNumber: '91$contactNumber', email: _emailController.text);


    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Completed'),
            content: const Text('Your Skater Registration has been successfully Completed, Kindly wait for the approval'),
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


    // Navigator.pop(context);
  }

  // Fetch clubs data from Firebase
  Future<void> _fetchClubsData() async {
    DatabaseReference ref = database.ref().child('clubs/');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> clubsData = snapshot.value as Map;
      List<Map<String, dynamic>> tempList = [];

      print("clubs");
      print(clubsData.toString());

      clubsData.forEach((key, value) {
        // Check if 'approval' exists and is 'Approved'
        if (value['approval'] != null && value['approval'] == 'Approved') {
          // Check if either 'clubname' or 'clubName' exists
          String? clubName = value['clubname'] ?? value['clubName'];
          if (clubName != null) {
            Map<String, dynamic> club = {
              'clubname': clubName,
              'district': value['district'] ?? '',
              'state': value['state'] ?? '',
            };
            tempList.add(club);
          }
        }
      });

      setState(() {
        _clubsList = tempList;
      });
    }
  }

// Method to validate all fields
  bool _validateFields() {
    // Check if the form fields are valid
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    // Check if required fields are not empty
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedState == null ||
        _selectedDistrict == null ||
        _schoolController.text.isEmpty ||
        _affiliationNumberController.text.isEmpty ||
        _selectedClub == null ||
        _emailController.text.isEmpty ||
        _contactNumberController.text.isEmpty ||
        _selectedBloodGroup == null ||
        _selectedGender == null ||
        _selectedCategory == null ||
        _aadharController.text.isEmpty ||
        _profilePhotoData == null ||
        _documentData == null) {
      // Show an alert or error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields and upload necessary documents.')),
      );
      return false;
    }

    // Check if the email format is valid
    if (!isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format.')),
      );
      return false;
    }

    // Check if the contact number is valid
    if (!isValidPhoneNumber(_contactNumberController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact number must be a 10-digit number.')),
      );
      return false;
    }

    return true;
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
      _uploadToFirebase();
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
        // On auto verification complete
        await FirebaseAuth.instance.signInWithCredential(credential);
        // Proceed with saving the form
        _uploadToFirebase();
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

// Method to handle form submission
  void _handleSubmit() {
    if(_profilePhotoFile==null){
      setState(() {
        profileImageError = true;
      });
    }else{
      setState(() {
        profileImageError = false;
      });
    }

    if(_documentFile==null){
      setState(() {
        docFileError = true;
      });
    }else{
      setState(() {
        docFileError = false;
      });
    }

      if (_validateFields()) {
        if(!docFileError && !profileImageError){
          // Initiate phone number verification before saving
          _verifyPhoneNumber();
        }
      }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarOpacity: 1,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Container(
            // margin: const EdgeInsets.only(left: 50),
            child: const Text("Skater Registration")),
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(widget.dialogContext);
        //   },
        //   icon: const Icon(Icons.arrow_back_rounded),
        // ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildTitleAndField('Name', 'Enter name',
                    controller: _nameController),
                const SizedBox(width: 16),

                //TODO ADD CALNEDAR OPTION ALONG WITH TEXT FIELD
                 buildTitleAndField('Date of Birth ',
                     'Enter date of birth (DD-MM-YYYY)', controller: _dobController,
                   inputFormatters: [DateInputFormatter()],
                             
                 ),
                const SizedBox(height: 16),
                buildTitleAndField('Residential Address', 'Enter address',
                    isMultiline: true, controller: _addressController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: buildTitleAndDropdown('Select State', 'Select state',
                          Constants().states.map((e) => e.name).toList(), _selectedState, (value) {
                            setState(() {
                              _selectedState = value;
                              _selectedDistrict=null;
                            });
                          }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildTitleAndDropdown('Select District',
                          'Select district', Constants().districts.where((element) => element.state.toLowerCase()==_selectedState?.toLowerCase(),).map((e) => e.name).toList(),
                          _selectedDistrict, (value) {
                            setState(() {
                              _selectedDistrict = value;
                              _selectedClub=null;
                            });
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildTitleAndField('Name of School/College', 'Enter school name',
                    controller: _schoolController),
                const SizedBox(height: 16),
                buildTitleAndField('School Affiliation Number',
                    'Enter school affiliation number',
                    controller: _affiliationNumberController),
                const SizedBox(height: 16),
                buildTitleAndDropdown('Select Club', 'Select club',
                    _clubsList
                        .where((element) => element['district'] == _selectedDistrict)
                        .map<String>((e) => e['clubname'] as String) // Explicitly cast to String
                        .toList(),
                    _selectedClub, (value) {
                      setState(() {
                        _selectedClub = value;
                      });
                    }),
                const SizedBox(height: 16),
                buildTitleAndField('Email ID', 'Enter email ID',
                    controller: _emailController),
                const SizedBox(height: 16),
                buildTitleAndField('Contact Number', 'Enter contact number',
                    controller: _contactNumberController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: buildTitleAndDropdown('Blood Group', 'Select blood group',
                          ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'],
                          _selectedBloodGroup, (value) {
                            setState(() {
                              _selectedBloodGroup = value;
                            });
                          }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildTitleAndDropdown('Gender', 'Select gender',
                          ['Male', 'Female', 'Other'], _selectedGender, (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildTitleAndDropdown('Category', 'Select category',
                    ['Beginner', 'Fancy', 'Quad', 'Inline'], _selectedCategory,
                        (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }),
                const SizedBox(height: 16),
                buildTitleAndField('Aadhar/Birth Certificate Number ',
                    'Enter Aadhar/Birth certificate number',
                    controller: _aadharController),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickProfilePhoto,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: _profilePhotoData != null
                          ? Image.memory(_profilePhotoData!)
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, size: 40, color: Colors.grey),
                          TextButton(
                            onPressed: _pickProfilePhoto,
                            child: const Text('Drop your image or browse'),
                          ),
                          const Text(
                            'JPEG or PNGs only • 8MB max',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if(profileImageError)const Text(
                            'please upload profile photo',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload Document',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _pickDocument,
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text(
                      'Upload Document',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                if(docFileError)const Text(
                  'please upload aadhaar/birth certificate',
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                if (_documentName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _documentName!,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
                const SizedBox(height: 8),
                const Text(
                  'Only JPEG and PDFs are accepted.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
            
                      onPressed: () {
            
                        _handleSubmit();
                      },
                      child: const Row(
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
      ),
    );
  }
}

