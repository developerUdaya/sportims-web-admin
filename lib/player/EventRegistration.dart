import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'package:sport_ims/models/PaymentReportModel.dart';
import 'package:sport_ims/player/EventParticipantDetailsPage.dart';
import 'package:sport_ims/utils/Controllers.dart';
import 'package:sport_ims/utils/MessageHelper.dart';

import '../models/EventModel.dart';
import '../models/EventParticipantsModel.dart';
import '../models/EventRaceModel.dart';
import '../models/UsersModel.dart';
import '../utils/Widgets.dart';

class EventParticipantsForm extends StatefulWidget {
  final Users user;
  final EventModel event;

  EventParticipantsForm({required this.user, required this.event});

  @override
  _EventParticipantsFormState createState() => _EventParticipantsFormState();
}

class _EventParticipantsFormState extends State<EventParticipantsForm> {
  List<RaceAgeGroup> filteredRaceAgeGroups = [];
  List<String> selectedRaces = [];
  int minEventsRequired = 0;

  Set<String> uniqueRaceNames = Set();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    filterRaceAgeGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Let’s get you started',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        leading: IconButton(
          icon:Icon(Icons.arrow_back_ios),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },),
      ),
      body: Theme(
        data: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.light(
                primary: Colors.blue
            ),
        ),
        child: Stepper(
          onStepTapped: (value) {
            setState(() {
              _currentStep = value;
            });
          },
          currentStep: _currentStep,
          onStepContinue: _currentStep < 2
              ? () => setState(() => _currentStep += 1)
              : null, // Proceed to the next step
          onStepCancel: _currentStep > 0
              ? () => setState(() => _currentStep -= 1)
              : null, // Go back to the previous step
          controlsBuilder: (BuildContext context, ControlsDetails details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  if (_currentStep < 2)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: details.onStepContinue,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text('Next', style: TextStyle(fontSize: 16,color: Colors.white)),
                      ),
                    ),
                  if (_currentStep == 2)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: saveParticipant,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text('Submit', style: TextStyle(fontSize: 16,color: Colors.white)),
                      ),
                    ),
                  SizedBox(width: 16),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text('Back'),
                    ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: General Details
            Step(
              title: Text('General Details'),
              isActive: _currentStep >= 0,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skater Profile',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            // Profile Picture
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(widget.user.profileImageUrl),
                            ),
                            SizedBox(width: 16),
                            // User Details (non-editable)
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  buildColumnWithFields([
                                    nonEditableField('Name', widget.user.name),
                                    nonEditableField('Club', widget.user.club),
                                    nonEditableField('State', widget.user.state),]
                                  ),

                    buildColumnWithFields([
                                  nonEditableField('District', widget.user.district),
                                  nonEditableField('Date of Birth', widget.user.dateOfBirth),
                                  nonEditableField('Skate Category', widget.user.skateCategory),])
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Step 2: Event Details
            Step(
              title: Text('Event Details'),
              isActive: _currentStep >= 1,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Details
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Details',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),

                        nonEditableField('Event Name', widget.event.eventName),
                        nonEditableField('Event Date', DateFormat('yyyy-MM-dd').format(widget.event.eventDate)),
                        nonEditableField('Location', widget.event.place),
                        SizedBox(height: 8),
                        nonEditableField('Current Age', calculateAgeInDetail(widget.user.dateOfBirth, formatDate(widget.event.ageAsOn.toString()))),

                        nonEditableField('Age as On ${formatDate(widget.event.ageAsOn.toString())}', calculateAge(widget.user.dateOfBirth, widget.event.ageAsOn).toString()),
                        SizedBox(height: 16),
                        // Race Selection Section
                        if (filteredRaceAgeGroups.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Races (Min: $minEventsRequired)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(height: 16),
                              Wrap(
                                children: uniqueRaceNames.map((race) {
                                  return CheckboxListTile(
                                    title: Text(race),
                                    value: selectedRaces.contains(race),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedRaces.add(race);
                                        } else {
                                          selectedRaces.remove(race);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Step 3: Pricing and Submit
            Step(
              title: Text('Pricing and Submit'),
              isActive: _currentStep >= 2,
              content: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary of User and Event Details
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          nonEditableField('Name', widget.user.name),
                          nonEditableField('Event Name', widget.event.eventName),
                          nonEditableField('Races', selectedRaces.join(', ')),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Payment Section
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sub Total',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          nonEditableField('Price', (double.parse( widget.event.regAmount)*selectedRaces.length).toString()), // Example price
                          nonEditableField('Total', (double.parse( widget.event.regAmount)*selectedRaces.length).toString()), // Example total
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nonEditableField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  void filterRaceAgeGroups() {
    if (widget.user == null || widget.event == null) return;

    // Calculate skater age based on dateOfBirth and event ageAsOn date
    DateTime dob = DateFormat('yyyy-MM-dd').parse(widget.user.dateOfBirth);
    DateTime ageAsOn = widget.event.ageAsOn;
    int age = ageAsOn.year - dob.year;
    if (ageAsOn.month < dob.month || (ageAsOn.month == dob.month && ageAsOn.day < dob.day)) {
      age--;
    }

    // Function to parse the "below" or "above" age group categories
    bool doesAgeMatchGroup(String ageGroup) {
      if (ageGroup.startsWith("below")) {
        int maxAge = int.parse(ageGroup.split(" ")[1]);
        return age < maxAge;
      } else if (ageGroup.startsWith("above")) {
        int minAge = int.parse(ageGroup.split(" ")[1]);
        return age >= minAge;
      }
      return false;
    }

    // Set to store unique race names and avoid duplicates

    setState(() {
      filteredRaceAgeGroups = widget.event.eventRaceModel
          .where((raceModel) =>
      raceModel.categoryName == widget.user.skateCategory &&
          raceModel.raceAgeGroup.any((group) => doesAgeMatchGroup(group.ageGroup)))
          .expand((raceModel) => raceModel.raceAgeGroup)
          .toList();

      // Manually iterate over race groups and add only unique races
      filteredRaceAgeGroups.forEach((raceGroup) {
        raceGroup.eventRaces.forEach((race) {
          if (race.selected && !uniqueRaceNames.contains(race.race)) {
            uniqueRaceNames.add(race.race);  // Add to set if it's not already there
          }
        });
      });

      if (filteredRaceAgeGroups.isNotEmpty) {
        minEventsRequired = filteredRaceAgeGroups[0].maxEvents;
      }
    });

    if(minEventsRequired==0||minEventsRequired==null){

      Future.delayed(Duration(seconds: 3), () {
        showExitDialog("You are not eligible for this event. ${filteredRaceAgeGroups.toJSBox}");
      });

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

  void showExitDialog(String message) {
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void showPaymentFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Failure Animation
                Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_4cnpnice.json',
                  height: 150,
                  repeat: false,
                ),
                SizedBox(height: 16),
                // Failure Message
                Text(
                  'Payment Failed!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Unfortunately, your payment could not be processed. Please try again later.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                // Retry Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    child: Text('Retry'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void showPaymentSuccessDialog(BuildContext context, EventParticipantsModel newParticipant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Animation
                Lottie.asset(
                  'payment-success.json',
                  height: 150,
                  repeat: false,
                ),
                SizedBox(height: 16),
                // Success Message
                Text(
                  'Payment Successful!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  'Thank you for your payment. Your transaction has been successfully completed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16,color: Colors.black),
                ),
                SizedBox(height: 24),
                // Close Button
                ElevatedButton(

                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventParticipantDetailsPage(participant: newParticipant, eventModel: widget.event),));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    child: Text('Okay',style: TextStyle(color: Colors.white),),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void saveParticipant() async {
    if(selectedRaces.length<minEventsRequired || selectedRaces.length==0){
      showErrorDialog('Select minimum $minEventsRequired races');
      return;
    }

    if (widget.user == null || widget.event == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    // Reference to Firebase Realtime Database
    DatabaseReference dbRef = FirebaseDatabase.instance.ref();

    String eventParticipantID = await generateEventParticipantsID(widget.event.id);
    // Firebase path for event participants
    String participantsPath = 'events/pastEvents/${widget.event.id}/eventParticipants/$eventParticipantID';
    String participantsCountPath = 'events/pastEvents/${widget.event.id}/eventParticipants/';
    String skaterPath = 'skaters/${widget.user.contactNumber}/events/${widget.event.id}/';

    // Fetch the existing participants to calculate the next chest number
    DataSnapshot snapshot = await dbRef.child(participantsCountPath).get();
    int participantCount = snapshot.children.length;

    // Generate the chest number based on the _eventPrefixName
    String eventPrefix = widget.event.eventPrefixName;

    // Determine how to handle the prefix and generate the chest number
    String chestNumber;
    if (eventPrefix.startsWith(RegExp(r'[A-Z]{3}$'))) {
      // Scenario 1: Prefix is like "SLM" -> "SLM0001", "SLM0002", etc.
      chestNumber = eventPrefix + (participantCount + 1).toString().padLeft(4, '0');
    }
    else {
      // Scenario 2: Prefix is like "NKL001" -> "NKL002", "KRR0001" -> "KRR0002", etc.
      String numericPart = RegExp(r'\d+$').firstMatch(eventPrefix)?.group(0) ?? '0';
      String prefixPart = eventPrefix.replaceAll(RegExp(r'\d+$'), '');
      int nextNumber = int.parse(numericPart) + participantCount;
      chestNumber = prefixPart + nextNumber.toString().padLeft(numericPart.length, '0');
    }

    // Create EventParticipantsModel instance and populate with data
    EventParticipantsModel newParticipant = EventParticipantsModel(
      id: eventParticipantID, // Firebase will generate a unique ID
      skaterId: widget.user.skaterID,
      chestNumber: chestNumber, // Calculated chest number
      name: widget.user.name,
      age: calculateAge(widget.user.dateOfBirth, widget.event.ageAsOn).toString(),
      dob: widget.user.dateOfBirth,
      gender: widget.user.gender,
      imgUrl: widget.user.profileImageUrl,
      eventName: widget.event.eventName,
      eventID: widget.event.id,
      skaterCategory: widget.user.skateCategory,
      raceCategory: selectedRaces,
      paymentStatus: 'Pending', // Example: integrate payment if needed
      paymentAmount: (double.parse( widget.event.regAmount)*selectedRaces.length).toString(), // Example: adjust the payment amount
      paymentId: '',
      paymentOrderId: '',
      paymentMode: '',
      createdAt: DateTime.now().toIso8601String(),
      club: widget.user.club,
      district: widget.user.district,
      state: widget.user.state,
      deleteStatus: false,
    );


    String paymentReportID = await generatePaymentID();


    PaymentReport paymentReport = PaymentReport(id: paymentReportID, skaterName: widget.user.name, skaterId: widget.user.skaterID, orderId: '${widget.event.id}$chestNumber', paymentRefId: paymentReportID, amount:  (double.parse( widget.event.regAmount)*selectedRaces.length).toString(), dateTime: DateTime.now().toString(), paymentMode: "Razorpay", paymentStatus: "Success", eventName: widget.event.eventName, eventId: widget.event.id, createAt: DateTime.now().toString(), updatedAt: '');

    // Push the new participant data to Firebase
    await dbRef.child(participantsPath).set(newParticipant.toJson());
    await dbRef.child(skaterPath).set(newParticipant.toJson());
    await dbRef.child('paymentReports/${paymentReportID}/').set(paymentReport.toJson());

    Navigator.pop(context);

    sendEventRegistrationSuccessful(playerName: widget.user.name, eventName: widget.event.eventName, date: formatDate(widget.event.eventDate.toString()), location: widget.event.place, phoneNumber: '91${widget.user.contactNumber}', email: widget.user.email);
    sendPaymentConfirmation(name: widget.user.name, productServiceEvent: widget.event.eventName, amount: paymentReport.amount, transactionId: paymentReport.paymentRefId, paymentDate: paymentReport.dateTime, companyName: "SPORT-IMS", contactInformation: widget.user.address, phoneNumber: '+91${widget.user.contactNumber}', email: widget.user.email, attachmentFileName: '');
    
    showPaymentSuccessDialog(context,newParticipant);
    // Show a success message or handle UI feedback
    print('Participant Registered with chestNumber: $chestNumber');
  }
}
