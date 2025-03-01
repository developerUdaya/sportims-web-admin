import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sport_ims/models/ClubsModel.dart';

import '../models/Constants.dart';
import '../models/DistrictModel.dart';
import '../models/StateModel.dart';
import '../models/UsersModel.dart';

import 'dart:html' as html;

// import other necessary packages

class EditUserDialog extends StatefulWidget {
  final Users user;
  final List<Club> club;
  final Function(Users) updateUser;


  EditUserDialog({required this.user,required this.club,required this.updateUser});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  // Define all controllers and variables here
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController contactController;
  late TextEditingController schoolController;
  late TextEditingController schoolAffiliationController;
  late TextEditingController aadharController;
  late TextEditingController pickedImageFileName;
  late TextEditingController pickedDocumentFileName;
  late TextEditingController dateFieldController;

  List<Club> clubs = [];
  List<States> states = Constants().states;
  List<District> allDistrict = Constants().districts;
  List<District> district = Constants().districts;
  List<Club> filteredClubs = [];

  String? selectedState;
  String? selectedDistrict;
  String? selectedClub;
  String? selectedBloodGroup;
  String? selectedGender;
  String? selectedSkate;
  String? selectedDateOfBirth;

  String profileImageUrl = '';
  String docFileUrl = '';

  XFile? _pickedImage;
  PlatformFile? _pickedDocument;
  html.File? _pickedWebImage;
  html.File? _pickedWebDocument;

  Future<String> uploadFileToStorage(String path, String fileName, {bool isWeb = false, html.File? webFile}) async {


    try {

      if (isWeb && webFile != null) {

        final reader = html.FileReader();

        reader.readAsArrayBuffer(webFile!);

        await reader.onLoad.first;

        final storageRef = FirebaseStorage.instance.ref('events/${DateTime.now().toString()+fileName}');

        final snapshot = await storageRef.putBlob(webFile);


        return await snapshot.ref.getDownloadURL();

      } else {
        return '';
      }
    } catch (e) {
      return '';
    }

  }


  @override
  void initState() {
    super.initState();
    // Initialize controllers and variables
    nameController = TextEditingController(text: widget.user.name);
    addressController = TextEditingController(text: widget.user.address);
    emailController = TextEditingController(text: widget.user.email);
    contactController = TextEditingController(text: widget.user.contactNumber);
    schoolController = TextEditingController(text: widget.user.school);
    schoolAffiliationController = TextEditingController(text: widget.user.schoolAffiliationNumber);
    aadharController = TextEditingController(text: widget.user.aadharBirthCertificateNumber);
    pickedImageFileName = TextEditingController();
    pickedDocumentFileName = TextEditingController();
    dateFieldController = TextEditingController(text: widget.user.dateOfBirth);

    selectedState = widget.user.state;
    selectedDistrict = widget.user.district;
    selectedClub = widget.user.club;
    selectedBloodGroup = widget.user.bloodGroup;
    selectedGender = widget.user.gender;
    selectedSkate = widget.user.skateCategory;
    selectedDateOfBirth = widget.user.dateOfBirth.substring(0, 10);

    profileImageUrl = widget.user.profileImageUrl;
    docFileUrl = widget.user.docFileUrl;

    clubs = widget.club;

    print(selectedClub);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // Text fields and other input elements
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextFormField(
                controller: schoolController,
                decoration: InputDecoration(labelText: 'School'),
              ),
              TextFormField(
                controller: schoolAffiliationController,
                decoration: InputDecoration(labelText: 'School Affiliation Number'),
              ),
              TextFormField(
                controller: aadharController,
                decoration: InputDecoration(labelText: 'Aadhaar Number'),
              ),
              // Dropdowns
              DropdownButtonFormField<String>(
                value: selectedState,
                onChanged: (newValue) {
                  _filterDistrictByState(newValue!);
                  setState(() {
                    selectedState = newValue;
                    selectedDistrict = allDistrict.where((element) => element.state.contains(newValue)).first.name;
                  });
                },
                items: states.map<DropdownMenuItem<String>>((States value) {
                  return DropdownMenuItem<String>(
                    value: value.name,
                    child: Text(value.name),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select State'),
              ),
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                onChanged: (newValue) {
                  print("111");
                  _filterClubsByDistrict(newValue!);
                  setState(() {
                    selectedDistrict = newValue;
                    selectedClub = clubs.where((club) => club.district!.contains(newValue)).first.clubName;
                  });
                },
                items: district.map<DropdownMenuItem<String>>((District value) {
                  return DropdownMenuItem<String>(
                    value: value.name,
                    child: Text(value.name),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select District'),
              ),
              DropdownButtonFormField<String>(
                value: selectedClub,
                onChanged: (newValue) {
                  setState(() {
                    selectedClub = newValue;
                  });
                },
                items: filteredClubs.map<DropdownMenuItem<String>>((Club value) {
                  return DropdownMenuItem<String>(
                    value: value.clubName,
                    child: Text(value.clubName ?? ""),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Club'),
              ),
              DropdownButtonFormField<String>(
                value: selectedBloodGroup,
                onChanged: (newValue) {
                  setState(() {
                    selectedBloodGroup = newValue;
                  });
                },
                items: <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Blood Group'),
              ),
              DropdownButtonFormField<String>(
                value: selectedGender,
                onChanged: (newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Gender'),
              ),
              DropdownButtonFormField<String>(
                value: selectedSkate,
                onChanged: (newValue) {
                  setState(() {
                    selectedSkate = newValue;
                  });
                },
                items: <String>['Beginner', 'Fancy', 'Quad', 'Inline']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Skate Type'),
              ),

              // Date of Birth
              TextFormField(
                controller: dateFieldController,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Select Date of Birth'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(selectedDateOfBirth!) ?? DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDateOfBirth = _formatDate(pickedDate);
                      dateFieldController.text = _formatDate(pickedDate);
                    });
                  }
                },
              ),

              // File upload buttons
              SizedBox(height: 10),
              TextFormField(
                controller: pickedImageFileName,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Upload Passport Size Photo',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.upload_file),
                    onPressed: () async {
                      if (kIsWeb) {
                        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                        uploadInput.accept = 'image/*';
                        uploadInput.click();

                        uploadInput.onChange.listen((e) {
                          final files = uploadInput.files!;
                          if (files.isNotEmpty) {
                            setState(() {
                              _pickedWebImage = files[0];
                              pickedImageFileName.text = _pickedWebImage!.name;
                            });
                          }
                        });
                      } else {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _pickedImage = image;
                            pickedImageFileName.text = image.name;
                          });
                        }
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please upload your passport size photo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: pickedDocumentFileName,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Upload Document',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.upload_file),
                    onPressed: () async {
                      if (kIsWeb) {
                        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
                        uploadInput.accept = '.pdf,.doc,.docx';
                        uploadInput.click();

                        uploadInput.onChange.listen((e) {
                          final files = uploadInput.files!;
                          if (files.isNotEmpty) {
                            setState(() {
                              _pickedWebDocument = files[0];
                              pickedDocumentFileName.text = _pickedWebDocument!.name;
                            });
                          }
                        });
                      } else {
                        final result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          setState(() {
                            _pickedDocument = result.files.first;
                            pickedDocumentFileName.text = _pickedDocument!.name;
                          });
                        }
                      }
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please upload your document';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Save'),
            onPressed: () async {
               showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Save'),
                    content: Text('Are you sure you want to save these changes?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);

                        },
                      ),
                      TextButton(
                        child: Text('Confirm'),
                        onPressed: () {
                          saveUser();

                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );


            },
          ),

          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
    );
  }

  Future<void> saveUser() async {
    String docFileUrl;
    String profileImageUrl;

    if (pickedDocumentFileName.text.isNotEmpty) {
      if (kIsWeb) {
        docFileUrl = await uploadFileToStorage('', _pickedWebDocument!.name, isWeb: true, webFile: _pickedWebDocument);
      } else {
        docFileUrl = await uploadFileToStorage(_pickedDocument!.path!, _pickedDocument!.name);
      }
    } else {
      docFileUrl = widget.user.docFileUrl;
    }

    if (pickedImageFileName.text.isNotEmpty) {
      if (kIsWeb) {
        profileImageUrl = await uploadFileToStorage('', _pickedWebImage!.name, isWeb: true, webFile: _pickedWebImage);
      } else {
        profileImageUrl = await uploadFileToStorage(_pickedImage!.path!, _pickedImage!.name);
      }
    } else {
      profileImageUrl = widget.user.profileImageUrl;
    }

    // Construct updated user data
    Users updatedUser = Users(
      skaterID: widget.user.skaterID,
      name: nameController.text,
      address: addressController.text,
      email: emailController.text,
      contactNumber: contactController.text,
      school: schoolController.text,
      schoolAffiliationNumber: schoolAffiliationController.text,
      aadharBirthCertificateNumber: aadharController.text,
      state: selectedState!,
      district: selectedDistrict!,
      club: selectedClub!,
      bloodGroup: selectedBloodGroup!,
      gender: selectedGender!,
      skateCategory: selectedSkate!,
      dateOfBirth: selectedDateOfBirth!,
      profileImageUrl: profileImageUrl,
      docFileUrl: docFileUrl,
      regDate: widget.user.regDate,
      approval: widget.user.approval,
    );

    // Save updated user to Firebase
    await FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(widget.user.contactNumber)
        .set(updatedUser.toJson());

    widget.updateUser(updatedUser);

    Navigator.pop(context);


  }

  // Date formatting helper
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Method to filter clubs based on selected district
  void _filterClubsByDistrict(String districtName) {
    setState(() {
      filteredClubs.clear();
      filteredClubs = clubs.where((club) => club.district!.contains(districtName) ).toList();
    });
  }

  void _filterDistrictByState(String stateName) {
    print("disrctict sorted");

    setState(() {
      district.clear();
      district = allDistrict.where((d) => d.state.contains(stateName)).toList();
     // selectedClub = clubs.where((club) => club.district!.contains(district.first.name) ).toList().first.clubName;

    });
  }

}

