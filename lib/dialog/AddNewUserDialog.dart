import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import '../models/UsersModel.dart';
import '../utils/Constants.dart';
import '../utils/Controllers.dart';
import '../utils/DateFormatter.dart';
import '../utils/Widgets.dart';
import '../utils/MessageHelper.dart';
import 'dart:html' as html;

class AddNewUserDialog extends StatelessWidget {
  final Function(Users) updateUser;

  AddNewUserDialog({required this.updateUser}); // Constructor

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Register New Skater"),
        backgroundColor: Colors.white,
        content: Center(
          child: Container(
            width: 800,
            padding: const EdgeInsets.all(15),
            child: AddNewUserDialogForm(updateUser: updateUser,),
          ),
        ),
      );
  }
}

class AddNewUserDialogForm extends StatefulWidget {
  final Function(Users) updateUser;

  AddNewUserDialogForm({super.key, required this.updateUser});

  @override
  AddNewUserDialogFormState createState() {
    return AddNewUserDialogFormState();
  }
}

class AddNewUserDialogFormState extends State<AddNewUserDialogForm> {
  final _formKey = GlobalKey<FormState>();

  Uint8List? _profilePhotoData;
  Uint8List? _documentData;

  html.File? _profilePhotoFile;
  html.File? _documentFile;

  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedClub;
  String? _selectedBloodGroup;
  String? _selectedGender;
  String? _selectedCategory;

  List<Map<String, dynamic>> _clubsList = [];

  TextEditingController _nameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _schoolController = TextEditingController();
  TextEditingController _affiliationNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _contactNumberController = TextEditingController();
  TextEditingController _aadharController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _pickedProfilePhotoController = TextEditingController();
  TextEditingController _pickedDocumentController = TextEditingController();


  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    _fetchClubsData();
  }


  Future<void> _uploadToFirebase() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        );
      },
    );

    String contactNumber = _contactNumberController.text;

    DatabaseReference ref = database.ref().child('skaters/$contactNumber/');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      Navigator.pop(context);

      showErrorDialog('Contact number already exists');

      return;
    }

    String? profileImageUrl;
    String? docFileUrl;
    if (kIsWeb && _profilePhotoFile != null) {
      profileImageUrl = await uploadFileToStorage('', _profilePhotoFile!.name, isWeb: true, webFile: _profilePhotoFile);
    }

    if (kIsWeb && _documentFile != null) {
      docFileUrl = await uploadFileToStorage('', _documentFile!.name, isWeb: true, webFile: _documentFile);
    }

    String skaterID = await generateSkaterID(_selectedState!, _selectedDistrict!);

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
      'password': _passwordController.text,
      'approval': 'Pending',
    });

    Navigator.pop(context);
    Navigator.pop(context);
    sendPlayerRegistration(playerId: skaterID, name: _nameController.text, phoneNumber: '91${_contactNumberController.text}', email: _emailController.text,);
    showSuccessDialog("Registration completed successfully");
  }

  Future<void> _fetchClubsData() async {
    DatabaseReference ref = database.ref().child('clubs/');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> clubsData = snapshot.value as Map;
      List<Map<String, dynamic>> tempList = [];

      clubsData.forEach((key, value) {
        Map<String, dynamic> club = {
          'clubname': value['clubname'] ?? '',
          'district': value['district'] ?? '',
          'state': value['state'] ?? '',
        };
        tempList.add(club);
      });

      setState(() {
        _clubsList = tempList;
      });
    }
  }

  bool _validateFields() {
    if (!_formKey.currentState!.validate()) return false;


    if (!isValidEmail(_emailController.text)) {

      showErrorDialog('Invalid email format.');

      return false;
    }

    if (!isValidPhoneNumber(_contactNumberController.text)) {
      showErrorDialog('Contact number must be a 10-digit number.');
      return false;
    }

    return true;
  }

  void _handleSubmit() {
    if (_validateFields()) _uploadToFirebase();
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Success"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: buildColumnWithFields([
                    buildTitleAndField('Name', 'Enter name', controller: _nameController),
                    const SizedBox(height: 16),
                    buildTitleAndField('Date of Birth', 'Enter date of birth',
                        controller: _dobController, inputFormatters: [DateInputFormatter()]),
                    const SizedBox(height: 16),
                    buildTitleAndDropdown('Select Gender', 'Select Gender',
                        ['Male','Female'], _selectedGender, (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        }),
                    const SizedBox(height: 16),
                    buildTitleAndDropdown('Select State', 'Select state',
                        Constants().states.map((e) => e.name).toList(), _selectedState, (value) {
                          setState(() {
                            _selectedState = value;
                            _selectedDistrict = null;
                          });
                        }),
                    const SizedBox(height: 16),
                    buildTitleAndDropdown('Select District', 'Select district',
                        Constants().districts
                            .where((element) => element.state.toLowerCase() == _selectedState?.toLowerCase())
                            .map((e) => e.name)
                            .toList(),
                        _selectedDistrict, (value) {
                          setState(() {
                            _selectedDistrict = value;
                            _selectedClub = null;
                          });
                        }),
                    const SizedBox(height: 16),
                    buildTitleAndDropdown('Select Club', 'Select club',
                        _clubsList
                            .where((element) => element['district'] == _selectedDistrict)
                            .map<String>((e) => e['clubname'] as String)
                            .toList(),
                        _selectedClub, (value) {
                          setState(() {
                            _selectedClub = value;
                          });
                        }),
                    const SizedBox(height: 16),
                    buildTitleAndDropdown('Blood Group', 'Select blood group',
                        ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'],
                        _selectedBloodGroup, (value) {
                          setState(() {
                            _selectedBloodGroup = value;
                          });
                        }),
                    const SizedBox(height: 16),
                    buildTitleAndDropdown('Skate Category', 'Select skate category',
                        ['Beginner', 'Inline', 'Quad', 'Fancy'],
                        _selectedCategory, (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }),
                    const SizedBox(height: 16),
                    buildPhotoUploadButton('Upload Profile Photo', _pickedProfilePhotoController, (file) {
                      setState(() {
                        _profilePhotoFile = file;
                        _pickedProfilePhotoController.text = file.name;
                      });
                    }),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildColumnWithFields([
                    buildTitleAndField('Residential Address', 'Enter address',
                        isMultiline: true, controller: _addressController),
                    const SizedBox(height: 16),
                    buildTitleAndField('Email ID', 'Enter email ID', controller: _emailController),
                    const SizedBox(height: 16),
                    buildTitleAndField('Contact Number', 'Enter contact number',
                        controller: _contactNumberController),
                    const SizedBox(height: 16),
                    buildTitleAndField('School Name',
                        'Enter school name',
                        controller: _schoolController),
                    const SizedBox(height: 16),
                    buildTitleAndField('School Affiliation Number',
                        'Enter school affiliation number',
                        controller: _affiliationNumberController),
                    const SizedBox(height: 16),
                    buildTitleAndField('Aadhar/Birth Certificate Number',
                        'Enter Aadhar/Birth certificate number',
                        controller: _aadharController),

                    const SizedBox(height: 16),
                    buildFileUploadButton('Upload Aadhaar/Birth Certificate', _pickedDocumentController, (file) {
                      setState(() {
                        _documentFile = file;
                        _pickedDocumentController.text = file.name;
                      });
                    }),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _handleSubmit,
                  child: Text('Register', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
