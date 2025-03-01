import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/Constants.dart';
import '../models/DistrictModel.dart';
import '../models/EventModel.dart';
import '../models/StateModel.dart';
import '../models/EventOrganiser.dart';
import '../models/UserCredentialsModel.dart';
import '../utils/Controllers.dart';
import '../utils/Widgets.dart';

class EditEventOrganiserDialog extends StatefulWidget {
  final Function(EventOrganiser) updateEventOrganiser;
  final EventOrganiser eventOrganiser;

  EditEventOrganiserDialog({required this.updateEventOrganiser, required this.eventOrganiser});

  @override
  _EditEventOrganiserDialogState createState() => _EditEventOrganiserDialogState();
}

class _EditEventOrganiserDialogState extends State<EditEventOrganiserDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? selectedEvent;
  String? selectedId;

  List<EventModel> events = [];

  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _fetchEventModels().then((_) {
      // After fetching the events, validate the selected event
      if (events.isNotEmpty && !events.any((event) => event.eventName == selectedEvent)) {
        setState(() {
          selectedEvent = events.first.eventName; // Set the first event as default if selectedEvent doesn't exist
          selectedId = events.first.id;
        });
      }
    });
    // Initialize fields with the values from the eventOrganiser being edited
    setState(() {
      nameController = TextEditingController(text: widget.eventOrganiser.name);
      userNameController = TextEditingController(text: widget.eventOrganiser.userName);
      passwordController = TextEditingController(text: widget.eventOrganiser.password);
      selectedEvent = widget.eventOrganiser.eventName;
      selectedId = widget.eventOrganiser.eventId;
    });
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

    // Create a new EventOrganiser object with the updated values
    EventOrganiser newEventOrganiser = EventOrganiser(
      id: widget.eventOrganiser.id,
      name: nameController.text,
      userName: userNameController.text,
      password: passwordController.text,
      eventId: selectedId!,
      eventName: selectedEvent!,
      createdAt: widget.eventOrganiser.createdAt,
      updatedAt: DateTime.now().toString(),
      approval: widget.eventOrganiser.approval,
    );

    if(widget.eventOrganiser.userName==userNameController.text?false:await checkUsernameExists(userNameController.text)){
      // User already exists, show error message
      Navigator.pop(context); // Close the progress dialog
      showErrorDialog("User ID '${userNameController.text}' already exists. Please choose another User ID.");
      return;
    }

    try {
      // Update the Event Organiser data in the 'eventOrganisers' node
      DatabaseReference eventOrganisersRef = FirebaseDatabase.instance.ref().child('eventOrganisers/${newEventOrganiser.id}/');
      await eventOrganisersRef.set(newEventOrganiser.toJson());

      if(newEventOrganiser.userName!=widget.eventOrganiser.userName){
        DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users/${newEventOrganiser.userName}/');
        usersRef.remove();
      }


      // Update the UserCredentials data in the 'users' node
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users/${newEventOrganiser.userName}/');
      await usersRef.set(UserCredentials(
        createdAt: newEventOrganiser.createdAt,
        eventId: newEventOrganiser.eventId,
        username: newEventOrganiser.userName,
        password: newEventOrganiser.password,
        status: true,
        accessLog: [],
        mobileNumber: '',
        role: 'organiser',
        name: newEventOrganiser.userName,
      ).toJson());

      widget.updateEventOrganiser(newEventOrganiser);
      Navigator.pop(context); // Close the progress dialog
      Navigator.pop(context); // Close the form dialog
      showSuccessDialog("Event Organiser data updated successfully");

    } catch (e) {
      Navigator.pop(context); // Close the progress dialog
      showErrorDialog("Error updating event organiser data: $e");
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
      title: Text('Edit Event Organiser'),
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
                  buildTitleAndField('User Name', 'Enter User Name', controller: userNameController,readOnly: true),
                  const SizedBox(height: 16),
                  buildPasswordField('Password', 'Enter Password', controller: passwordController),
                  const SizedBox(height: 16,),
                  buildTitleAndDropdown('Select Event', 'Choose Event', events.map((e) => e.eventName).toSet().toList(), selectedEvent, (newValue) {
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
