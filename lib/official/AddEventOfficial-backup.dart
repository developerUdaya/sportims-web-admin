import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/EventModel.dart';
import '../models/EventOfficialModel.dart';
import '../models/UserCredentialsModel.dart';
import '../utils/Widgets.dart'; // Import the custom widgets

class AddEventOfficial extends StatefulWidget {
  final Function(EventOfficialModel) updateEventOfficialModels;

  AddEventOfficial({required this.updateEventOfficialModels});

  @override
  _AddEventOfficialState createState() => _AddEventOfficialState();
}

class _AddEventOfficialState extends State<AddEventOfficial> {
  final _formKey = GlobalKey<FormState>();

  html.File? advertisementFile;
  html.File? bannerFile;

  String? selectedEvent;
  String? selectedId;

  bool obscurePassword = true;

  List<EventModel> events = [];

  EventOfficialModel? eventOfficialModel;
  final TextEditingController officialNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool certificateStatus = false;

  @override
  void initState() {
    super.initState();
    _getEventModels();
    eventOfficialModel = EventOfficialModel(
      id: '',
      officialName: '',
      userName: '',
      password: '',
      eventId: '',
      eventName: '',
      content: '',
      imgUrl: '',
      createdAt: '',
      updatedAt: '',
      cetificateStatus: false,
    );
  }

  Future<void> _getEventModels() async {
    List<EventModel> fetchedEventModels = await getEventModels();
    setState(() {
      events.addAll(fetchedEventModels);
    });
  }

  Future<List<EventModel>> getEventModels() async {
    List<EventModel> events = [];
    final ref = FirebaseDatabase.instance.ref().child('events/pastEvents');
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        EventModel event = EventModel.fromJson(Map<String, dynamic>.from(child.value as Map));
        events.add(event);
      }
    }
    return events;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Exit if form validation fails
    }

    eventOfficialModel!.createdAt = DateTime.now().toString();
    eventOfficialModel!.content = "";
    eventOfficialModel!.officialName = officialNameController.text;
    eventOfficialModel!.userName = userNameController.text;
    eventOfficialModel!.password = passwordController.text;
    eventOfficialModel!.eventName = selectedEvent!;
    eventOfficialModel!.eventId = selectedId!;
    eventOfficialModel!.id = await _generateEventOfficialID();
    eventOfficialModel!.cetificateStatus = certificateStatus;
    eventOfficialModel!.updatedAt = DateTime.now().toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await submitEventDetails();
    } catch (e) {
      Navigator.pop(context);
      showErrorDialog("Error uploading images: $e");
    }
  }

  Future<void> submitEventDetails() async {
    try {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('eventOfficials/${eventOfficialModel!.id}/');
      await usersRef.set(eventOfficialModel!.toJson());
      DatabaseReference userCredentialRef = FirebaseDatabase.instance.ref().child('users/${eventOfficialModel!.userName}/');
      userCredentialRef.set(UserCredentials(
        createdAt: DateTime.now().toString(),
        eventId: eventOfficialModel!.eventId,
        username: eventOfficialModel!.userName,
        password: eventOfficialModel!.password,
        status: true,
        accessLog: [],
        mobileNumber: '',
        role: 'official',
        name: eventOfficialModel!.userName,
      ).toJson());

      Navigator.pop(context);
      Navigator.pop(context);
      widget.updateEventOfficialModels(eventOfficialModel!);
      showSuccessDialog("Event Official data saved successfully");
    } on FirebaseException catch (e) {
      Navigator.pop(context);
      showErrorDialog("Error saving event Official data: ${e.message}");
    } catch (e) {
      Navigator.pop(context);
      showErrorDialog("Error saving event Official data: $e");
    }
  }

  Future<String> _generateEventOfficialID() async {
    final ref = FirebaseDatabase.instance.ref().child('eventOfficials/pastEvents');
    final snapshot = await ref.get();

    int userCount = snapshot.children.length;
    String uniqueId = (userCount + 1).toString().padLeft(4, '0'); // Pads the ID to 4 digits

    return 'OFF$uniqueId';
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
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event Official'),
        backgroundColor: const Color(0xffb0ccf8),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              width: width - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildColumnWithFields([
                          buildTitleAndField('Official Name', 'Enter Official Name', controller: officialNameController),
                          const SizedBox(height: 16),
                          buildPasswordField('Password', 'Enter Password', controller: passwordController),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: buildColumnWithFields([
                          buildTitleAndField('User Name', 'Enter User Name', controller: userNameController),
                          const SizedBox(height: 16),
                          buildTitleAndDropdown('Select Event', 'Choose Event', events.map((e) => e.eventName).toList(), selectedEvent, (newValue) {
                            setState(() {
                              selectedEvent = newValue;
                              selectedId = events.firstWhere((event) => event.eventName == newValue).id;
                            });
                          }),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MaterialButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    color: Colors.black87,
                    onPressed: _submitForm,
                    hoverColor: Colors.black,
                    child: const Text('Submit',style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
