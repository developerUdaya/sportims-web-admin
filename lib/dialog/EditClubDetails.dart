import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/ClubsModel.dart';
import '../models/StateModel.dart';
import '../models/DistrictModel.dart';
import '../models/Constants.dart';
import '../models/UserCredentialsModel.dart';
import '../utils/Widgets.dart';

class EditClubDialog extends StatefulWidget {
  final Club club;
  final Function(Club) updateClub;

  EditClubDialog({required this.club, required this.updateClub});

  @override
  _EditClubDialogState createState() => _EditClubDialogState();
}

class _EditClubDialogState extends State<EditClubDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  TextEditingController clubNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController coachNameController = TextEditingController();
  TextEditingController masterNameController = TextEditingController();

  // Dropdown selections
  String? selectedState;
  String? selectedDistrict;

  List<States> states = Constants().states;
  List<District> allDistrict = Constants().districts;
  List<District> district = [];

  @override
  void initState() {
    super.initState();
    initializeFields();
  }

  // Initialize fields and dropdowns based on the provided club data
  void initializeFields() {
    setState(() {
      clubNameController.text = widget.club.clubName!;
      addressController.text = widget.club.address!;
      emailController.text = widget.club.email!;
      contactController.text = widget.club.contactNumber!;
      coachNameController.text = widget.club.coachName!;
      masterNameController.text = widget.club.masterName!;

      selectedState = widget.club.state;
      _filterDistrictByState(selectedState!);
      selectedDistrict = widget.club.district;
    });
  }

  // Filter districts based on the selected state
  void _filterDistrictByState(String stateName) {
    setState(() {
      district = allDistrict.where((d) => d.state == stateName).toList();
      if (district.isNotEmpty) {
        selectedDistrict = district.first.name;
      }
    });
  }

  // Save club data to Firebase and update the parent widget
  Future<void> saveClubData() async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
    );

    // Check if the contact number already exists in the database
    if (await doesNumberExist(contactController.text)) {
      Navigator.pop(context);
      showErrorDialog("Mobile Number Already Exists");
      return;
    }

    // Create a new Club object
    Club updatedClub = Club(
      id: widget.club.id,
      clubName: clubNameController.text,
      address: addressController.text,
      state: selectedState!,
      district: selectedDistrict!,
      contactNumber: contactController.text,
      email: emailController.text,
      coachName: coachNameController.text,
      masterName: masterNameController.text,
      aadharNumber: widget.club.aadharNumber,
      regDate: widget.club.regDate,
      docUrl: widget.club.docUrl,
      approval: 'Pending',
    );

    try {
      // Update the Club data in the 'clubs' node
      DatabaseReference clubsRef = FirebaseDatabase.instance.ref().child('clubs/${updatedClub.id}/');
      await clubsRef.set(updatedClub.toJson());

      // Update UserCredentials if necessary
      DatabaseReference userCredentialRef = FirebaseDatabase.instance.ref().child('users/${updatedClub.id}/');
      await userCredentialRef.update({
        'name': updatedClub.clubName,
        'mobileNumber': updatedClub.contactNumber,
      });

      Navigator.pop(context); // Close the progress dialog
      widget.updateClub(updatedClub); // Update the parent widget

      showSuccessDialog("Club data updated successfully");

    } catch (e) {
      Navigator.pop(context);
      showErrorDialog("Error updating club data: $e");
    }
  }

  // Check if the contact number already exists in the database
  Future<bool> doesNumberExist(String enteredNumber) async {
    final ref = FirebaseDatabase.instance.ref('clubs');
    final query = ref.orderByKey().equalTo(enteredNumber).limitToFirst(1);
    final snapshot = await query.get();
    return snapshot.exists;
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

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
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
      backgroundColor: Colors.white,
      title: Text('Edit Club'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildColumnWithFields([
                  buildTitleAndField('Club Name', 'Enter Club Name', controller: clubNameController),
                  const SizedBox(height: 16),
                  buildTitleAndField('Email', 'Enter Email ID', controller: emailController),
                  const SizedBox(height: 16),
                  buildTitleAndDropdown('Select State', 'Choose State', states.map((e) => e.name).toList(), selectedState, (value) {
                    setState(() {
                      selectedState = value;
                      _filterDistrictByState(value!);
                    });
                  }),
                  const SizedBox(height: 16),
                  buildTitleAndDropdown('Select District', 'Choose District', district.map((e) => e.name).toList(), selectedDistrict, (value) {
                    setState(() {
                      selectedDistrict = value;
                    });
                  }),
                ]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: buildColumnWithFields([
                  buildTitleAndField('Address', 'Enter Address', controller: addressController, isMultiline: true),
                  const SizedBox(height: 16),
                  buildTitleAndField('Contact Number', 'Enter Contact Number', controller: contactController, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  const SizedBox(height: 16),
                  buildTitleAndField('Coach Name', 'Enter Coach Name', controller: coachNameController),
                  const SizedBox(height: 16),
                  buildTitleAndField('Master Name', 'Enter Master Name', controller: masterNameController),
                ]),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Save'),
          onPressed: saveClubData,
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
}
