import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sport_ims/utils/MessageHelper.dart';
import '../models/Constants.dart';
import '../models/DistrictModel.dart';
import '../models/EventModel.dart';
import '../models/StateModel.dart';
import '../models/EventOrganiser.dart';
import '../models/UserCredentialsModel.dart';
import '../utils/Controllers.dart';
import '../utils/Widgets.dart';

class AddNewEventOrganiserDialog extends StatefulWidget {
  final Function(EventOrganiser) updateEventOrganiser;

  AddNewEventOrganiserDialog({required this.updateEventOrganiser});

  @override
  _AddNewEventOrganiserDialogState createState() => _AddNewEventOrganiserDialogState();
}

class _AddNewEventOrganiserDialogState extends State<AddNewEventOrganiserDialog> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Dropdown selections
  String? selectedEvent;
  String? selectedId;

  bool obscurePassword = true;

  List<EventModel> events = [];
  List<States> states = Constants().states;
  List<District> allDistrict = Constants().districts;
  List<District> district = Constants().districts.where((d) => d.state.contains("Tamil Nadu")).toList();

  @override
  void initState() {
    super.initState();
    _fetchEventModels();
  }

  // Fetch events data from Firebase
  Future<void> _fetchEventModels() async {
    List<EventModel> fetchedEventModels = await getEventModels();
    setState(() {
      events.addAll(fetchedEventModels);
    });
  }

  Future<List<EventModel>> getEventModels() async {
    List<EventModel> events = [];
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('events/pastEvents');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        EventModel event = EventModel.fromJson(Map<String, dynamic>.from(child.value as Map));
        if(!event.deleteStatus) {
          events.add(event);
        }
      }
    }
    return events;
  }

  Future<void> saveEventOrganiserData() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if validation fails
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    String id = await _generateEventOrganiserID();
    EventOrganiser newEventOrganiser = EventOrganiser(
      id: id,
      name: nameController.text,
      userName: userNameController.text,
      password: passwordController.text,
      eventId: selectedId!,
      eventName: selectedEvent!,
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
      approval: 'Pending',
    );

    try {

      if(await checkUsernameExists(userNameController.text)){
        // User already exists, show error message
        Navigator.pop(context); // Close the progress dialog
        showErrorDialog("User ID '${userNameController.text}' already exists. Please choose another User ID.");
        return;
      }


      DatabaseReference eventOrganisersRef = FirebaseDatabase.instance.ref().child('eventOrganisers/${newEventOrganiser.id}/');
      await eventOrganisersRef.set(newEventOrganiser.toJson());

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
        name: newEventOrganiser.name,
      ).toJson());

      widget.updateEventOrganiser(newEventOrganiser);
      Navigator.pop(context); // Close the progress dialog
      Navigator.pop(context); // Close the form dialog

      // sendEventOfficialRegistrationSuccessful(name: newEventOrganiser.name, role: 'Event Organiser ', eventName: newEventOrganiser.eventName, eventDate: eventDate, eventVenue: eventVenue, userName: userName, password: password, companyName: companyName, phoneNumber: phoneNumber, email: email)
      showSuccessDialog("Event Organiser data saved successfully");
    } catch (e) {
      Navigator.pop(context); // Close the form dialog

      showErrorDialog("Error saving event organiser data: $e");
    }


  }

  Future<String> _generateEventOrganiserID() async {
    final ref = FirebaseDatabase.instance.ref().child('eventOrganisers');
    final snapshot = await ref.get();

    int eventOrganiserCount = snapshot.children.length;
    String uniqueId = (eventOrganiserCount + 1).toString().padLeft(4, '0');
    return 'ORG$uniqueId';
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Add New Event Organiser'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildColumnWithFields([
                  buildTitleAndField('Name', 'Enter Name', controller: nameController),
                  const SizedBox(height: 16),
                  buildTitleAndField('User Name', 'Enter User Name', controller: userNameController),
                  const SizedBox(height: 16),
                  buildPasswordField('Password', 'Enter Password', controller: passwordController),
                  const SizedBox(height: 16,),
                  buildTitleAndDropdown('Select Event', 'Choose Event', events.map((e) => e.eventName).toList(), selectedEvent, (newValue) {
                    setState(() {
                      selectedEvent = newValue;
                      selectedId = events.firstWhere((event) => event.eventName == newValue).id;
                    });
                  }),
                ]),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Save'),
          onPressed: saveEventOrganiserData,
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
