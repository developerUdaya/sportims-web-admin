import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/models/EventOrganiser.dart';

import '../models/Constants.dart';
import '../models/DistrictModel.dart';
import '../models/EventModel.dart';
import '../models/StateModel.dart';

//import 'package:provider/provider.dart';

import '../models/UserCredentialsModel.dart';

class AddNewOfficialEventOrganiserDialog extends StatefulWidget {
  Function(EventOrganiser) updateEventOrganiser;
  EventModel eventModel;

  AddNewOfficialEventOrganiserDialog({required this.updateEventOrganiser, required this.eventModel});
  @override
  _AddNewOfficialEventOrganiserDialogState createState() => _AddNewOfficialEventOrganiserDialogState();
}

class _AddNewOfficialEventOrganiserDialogState extends State<AddNewOfficialEventOrganiserDialog> {

  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //Add new eventOrganiser variables Initialize variables for dropdown selections
  String? selectedEvent;
  String? selectedId;

  bool _isObscure = true;

  List<EventModel> events = [];
  List<States> states = Constants().states;
  List<District> allDistrict = Constants().districts;
  List<District> district = Constants().districts.where((d) => d.state.contains("Tamil Nadu")).toList();
  List<EventModel> filteredEventModels = [];


  void showSnackBar(String msg){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<String> _generateEventOrganiserID() async {
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('eventOrganisers');
    final snapshot = await ref.get();

    int eventOrganiserCount = snapshot.children.length;
    String uniqueId = (eventOrganiserCount + 1).toString().padLeft(4, '0');  // Pads the ID to 5 digits

    return 'ORG$uniqueId';
  }


  Future<void> saveEventOrganiserData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    String id =  await _generateEventOrganiserID();
    EventOrganiser newEventOrganiser = EventOrganiser(
      id:id,
      name: nameController.text,
      userName: userNameController.text,
      password: passwordController.text,
      eventId: selectedId!,
      eventName: selectedEvent!,
      createdAt: DateTime.now().toString(),
      updatedAt:  DateTime.now().toString(),
      approval: 'Pending',
    );

    try{
      DatabaseReference eventOrganisersRef = FirebaseDatabase.instance.ref().child('eventOrganisers/${newEventOrganiser.id}/');
      await eventOrganisersRef.set(newEventOrganiser.toJson());
      // Show success dialog
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users/${newEventOrganiser.userName}/');
      usersRef.set(UserCredentials(
          createdAt: DateTime.now().toString(),
          eventId: newEventOrganiser.eventId,
          username: newEventOrganiser.userName,
          password: newEventOrganiser.password,
          status: true,
          accessLog: [],
          mobileNumber: '',
          role: 'organiser',
          name: newEventOrganiser.userName).toJson());
      widget.updateEventOrganiser(newEventOrganiser);
      Navigator.pop(context);
      showSuccessDialog("EventOrganiser data saved successfully");
    } catch (e) {
      // Show error dialog
      showErrorDialog("Error saving eventOrganiser data: $e");
    }
    Navigator.pop(context);

    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getEventModels();
    // getEventOrganiser();
  }

  Future<void> _getEventModels() async {
    setState(() {
      events.add(widget.eventModel);
      filteredEventModels.add(widget.eventModel);
    });
  }


  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text('Add New Event Organiser'),
      content: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [
              // Text fields
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: userNameController,
                decoration: InputDecoration(labelText: 'User Name'),
              ),
            TextFormField(
              controller: passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                ),
              ),
            ),

              DropdownButtonFormField<String>(
                value: selectedEvent,
                onChanged: (newValue) {
                  setState(() {
                    selectedEvent = newValue;
                    // Find the corresponding EventModel and set selectedId
                    selectedId = events.firstWhere((event) => event.eventName == newValue).id;
                  });
                },
                items: events.map<DropdownMenuItem<String>>((EventModel value) {
                  return DropdownMenuItem<String>(
                    value: value.eventName,
                    child: Text(value.eventName),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Event'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an event';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Save'),
          onPressed: () async {
            // Handle the save logic here
            saveEventOrganiserData();

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
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    return formatter.format(date);
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phoneNumber);
  }


}


