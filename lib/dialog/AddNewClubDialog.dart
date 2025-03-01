import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/utils/MessageHelper.dart';

import '../models/Constants.dart';
import '../models/DistrictModel.dart';
import '../models/StateModel.dart';
import '../models/ClubsModel.dart';
import '../models/UserCredentialsModel.dart';
import '../utils/Controllers.dart';
import '../utils/Widgets.dart';

class AddNewClubDialog extends StatefulWidget {
  final Function(Club) updateClubs;

  AddNewClubDialog({required this.updateClubs});

  @override
  _AddNewClubDialogState createState() => _AddNewClubDialogState();
}

class _AddNewClubDialogState extends State<AddNewClubDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController clubNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController coachNameController = TextEditingController();
  TextEditingController masterNameController = TextEditingController();
  TextEditingController regDateController = TextEditingController();
  TextEditingController societyCertificateController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController pickedSocietyCertificateFileName = TextEditingController();

  String? selectedState;
  String? selectedDistrict;
  bool obscurePassword = true;

  List<States> states = Constants().states;
  List<District> allDistrict = Constants().districts;
  List<District> district = Constants().districts.where((d) => d.state.contains("Tamil Nadu")).toList();

  html.File? _pickedSocietyCertificate;

  void _filterDistrictByState(String stateName) {
    setState(() {
      district = allDistrict.where((d) => d.state.contains(stateName)).toList();
      selectedDistrict = district.isNotEmpty ? district.first.name : null;
    });
  }

  Future<void> saveClubData() async {
    if (_pickedSocietyCertificate == null) {
      showSnackBar("Please upload the society certificate");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(child: CircularProgressIndicator()),
    );

    if (await doesNumberExist(contactController.text)) {
      Navigator.pop(context);
      showErrorDialog("Mobile Number Already Exists");
      return;
    }

    // Upload file to Firebase Storage
    String societyCertFileUrl = '';
    if (kIsWeb && _pickedSocietyCertificate != null) {
      societyCertFileUrl = await uploadFileToStorage('', _pickedSocietyCertificate!.name, isWeb: true, webFile: _pickedSocietyCertificate);
    }

    if (societyCertFileUrl.isEmpty) {
      Navigator.pop(context);
      showErrorDialog("Error uploading society certificate");
      return;
    }

    Club newClub = Club(
      id: await generateClubID(selectedState!, selectedDistrict!),
      clubName: clubNameController.text,
      address: addressController.text,
      state: selectedState!,
      district: selectedDistrict!,
      contactNumber: contactController.text,
      email: emailController.text,
      coachName: coachNameController.text,
      masterName: masterNameController.text,
      password: passwordController.text,
      aadharNumber: societyCertificateController.text,
      regDate: DateFormat('dd-MM-yyyy').format(DateTime.now()),
      docUrl: societyCertFileUrl,
      approval: 'Pending',
    );

    try {
      DatabaseReference clubsRef = FirebaseDatabase.instance.ref().child('clubs/${newClub.id}/');
      await clubsRef.set(newClub.toJson());

      DatabaseReference userCredentialRef = FirebaseDatabase.instance.ref().child('users/${newClub.id}/');
      await userCredentialRef.set(UserCredentials(
        createdAt: DateTime.now().toString(),
        eventId: "",
        username: newClub.id,
        password: passwordController.text,
        status: true,
        accessLog: [],
        mobileNumber: newClub.contactNumber,
        role: 'club',
        name: newClub.clubName,
      ).toJson());

      Navigator.pop(context);
      Navigator.pop(context);
      widget.updateClubs(newClub);

      sendRegistrationSuccessful(name: newClub.clubName!, role: 'Club User <br> Username : ${newClub.id} <br> password : ${newClub.password} <br> ', companyName: 'Sport-IMS', phoneNumber: newClub.contactNumber!, email: newClub.email!);
      showSuccessDialog("Club data saved successfully");
    } catch (e) {
      Navigator.pop(context);
      showErrorDialog("Error saving club data: $e");
    }
  }

  Future<bool> doesNumberExist(String enteredNumber) async {
    final ref = FirebaseDatabase.instance.ref('clubs');
    final query = ref.orderByKey().equalTo(enteredNumber).limitToFirst(1);
    final snapshot = await query.get();
    return snapshot.value != null ? (snapshot.value as Map).isNotEmpty : false;
  }

  void showSnackBar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
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
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Add New Club'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildColumnWithFields([
                  buildTitleAndField('Club Name', 'Enter Club Name', controller: clubNameController),
                  const SizedBox(height: 18),
                  buildTitleAndField('Email', 'Enter Email', controller: emailController),
                  const SizedBox(height: 18),
                  buildTitleAndDropdown('Select State', 'Choose State', states.map((state) => state.name).toList(), selectedState, (newValue) {
                    setState(() {
                      selectedState = newValue;
                      selectedDistrict = allDistrict.where((district) => district.state.contains(newValue!)).toList().first.name;
                    });
                    _filterDistrictByState(newValue!);
                  }),
                  const SizedBox(height: 18),
                  buildTitleAndDropdown('Select District', 'Choose District', district.map((d) => d.name).toList(), selectedDistrict, (newValue) {
                    setState(() {
                      selectedDistrict = newValue;
                    });
                  }),
                  const SizedBox(height: 18),
                  buildTitleAndField('Society Certificate Number', 'Enter Certificate Number', controller: societyCertificateController),

                  const SizedBox(height: 18),
                  buildFileUploadButton('Upload Society Certificate', pickedSocietyCertificateFileName, (file) {
                    setState(() {
                      _pickedSocietyCertificate = file;
                      pickedSocietyCertificateFileName.text = file.name;
                    });
                  }),
                ]),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: buildColumnWithFields([
                  buildTitleAndField('Address', 'Enter Address', controller: addressController, isMultiline: true),
                  const SizedBox(height: 18),
                  buildTitleAndField('Contact Number', 'Enter Contact Number', controller: contactController, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  const SizedBox(height: 18),
                  buildTitleAndField('Coach Name', 'Enter Coach Name', controller: coachNameController),
                  const SizedBox(height: 18),
                  buildTitleAndField('Master Name', 'Enter Master Name', controller: masterNameController),
                  const SizedBox(height: 18),
                  buildPasswordField('Password', 'Enter Password', controller: passwordController),
                ]),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Save'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (!isValidEmail(emailController.text)) {
                showErrorDialog("Enter Valid Email");
                return;
              }

              if (!isValidPhoneNumber(contactController.text)) {
                showErrorDialog("Enter Valid Mobile number");
                return;
              }

              saveClubData();
            }
          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }


  Widget buildPasswordField(String title, String hintText, {required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            suffixIcon: IconButton(
              icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password cannot be empty';
            }
            return null;
          },
        ),
      ],
    );
  }

}
