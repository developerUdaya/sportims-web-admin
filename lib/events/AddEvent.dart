import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/models/EventRaceModel.dart';

import 'dart:html' as html;
import 'dart:typed_data';

import '../utils/Widgets.dart';
import 'EventRaceSelectionTable.dart';
import '../firebase_options.dart';
import '../models/EventModel.dart';
import 'EventRaceForm.dart';


class EventCreationForm extends StatefulWidget {
  Function(EventModel) updateEventModels;

  EventCreationForm({required this.updateEventModels});

  @override
  _EventCreationFormState createState() => _EventCreationFormState();
}

class _EventCreationFormState extends State<EventCreationForm> {
  final GlobalKey<FormState> _formKeyWeb = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyMobile1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyMobile2 = GlobalKey<FormState>();



  final EventModel eventModel = EventModel(
    advertisement: '',
    bannerImage: '',
    certificateStatus: false,
    createdAt: DateTime.now(),
    declaration: '',
    eventDate: DateTime.now(),
    eventName: '',
    id: '',
    instruction: '',
    place: '',
    regAmount: '',
    eventPrefixName: '',
    ageCategory: [],
    participants: [],
    regCloseDate: DateTime.now(),
    regStartDate: DateTime.now(),
    updatedAt: DateTime.now(),
    visibility: false,
    result: [],
    eventRaceModel: [EventRaceModel(categoryName: '', raceAgeGroup: []),EventRaceModel(categoryName: '', raceAgeGroup: []),EventRaceModel(categoryName: '', raceAgeGroup: []),EventRaceModel(categoryName: '', raceAgeGroup: [])],
    eventRaces: [], ageAsOn: DateTime.now(), eventParticipants: [],
  );

  final TextEditingController advertisementController = TextEditingController();
  final TextEditingController bannerImageController = TextEditingController();
  bool certificateStatus = false;
  final TextEditingController createdAtController = TextEditingController();
  final TextEditingController eventRaceController = TextEditingController();
  final TextEditingController declarationController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController ageAsOnDateController = TextEditingController();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();
  final TextEditingController certificateContentController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController regAmountController = TextEditingController();
  final TextEditingController eventPrefixNameController = TextEditingController();
  final TextEditingController regCloseDateController = TextEditingController();
  final TextEditingController regStartDateController = TextEditingController();
  bool visibility = false;
  List<TextEditingController> raceControllers = [TextEditingController()];

  Uint8List? advertisementImage;
  Uint8List? bannerImage;
  Uint8List? certificateImage;

  html.File? advertisementFile;
  html.File? bannerFile;
  html.File? certificateFile;
  String certificateImgUrl='';
  String certificateImgContent='';


  List<String> oddAgeGroup= ["below 7","below 9","below 11","below 13","below 15","below 17","above 17"];
  List<String> evenAgeGroup= ["below 8","below 10","below 12","below 14","below 16","below 18","above 18"];

  List<String> ageGroup=["Odd","Even"];
  String? selectedAgeGroup;
  List<String>? selectedAgeGroupList=[];

  List<String>? eventRaces=[];

   EventRaceModel? beginnerEventRaceModel = EventRaceModel(categoryName: "Beginner", raceAgeGroup: []);
   EventRaceModel? fancyEventRaceModel = EventRaceModel(categoryName: "Fancy", raceAgeGroup: []);
   EventRaceModel? quadEventRaceModel = EventRaceModel(categoryName: "Quad", raceAgeGroup: []);
   EventRaceModel? inlineEventRaceModel = EventRaceModel(categoryName: "Inline", raceAgeGroup: []);

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


  Future<String> _generateEventID() async {
    final database = FirebaseDatabase.instance;
    final ref = database.ref().child('events/pastEvents');
    final snapshot = await ref.get();

    int userCount = snapshot.children.length;
    String uniqueId = (userCount + 1).toString().padLeft(4, '0');  // Pads the ID to 5 digits

    return 'EVNT$uniqueId';
  }

  Future<void> showAddRaceDialog(BuildContext context, List<String> races) async {
    print("Dialog triggered");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: EventRaceForm(eventRaces: races, updatedEventRaces: updateEventRace),
        );
      },
    );
  }
  void updateEventRace(List<String> races){
    setState(() {
      eventRaces = races;
      eventRaceController.text = races.toString();
      eventModel.eventRaces = races;
    });
  }

  void _pickImage(bool isAdvertisement) async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);
      reader.onLoadEnd.listen((e) {
        setState(() {
          if (isAdvertisement) {
            advertisementImage = reader.result as Uint8List;
            advertisementFile = files[0];
          } else {
            bannerImage = reader.result as Uint8List;
            bannerFile = files[0];
          }
        });
      });
    });
  }

  void _pickCertificateImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);
      reader.onLoadEnd.listen((e) {
        setState(() {

            certificateImage = reader.result as Uint8List;
            certificateFile = files[0];

        });
      });
    });
  }



  Future<void> _submitForm() async {
      // Save form data to eventModel
    bool isEmptyEventRaceModel(EventRaceModel model) {
      return model.categoryName.isEmpty && model.raceAgeGroup.isEmpty;
    }

    // Check if all EventRaceModel instances in eventModel.eventRaceModel are empty
    bool allEventRaceModelsEmpty = eventModel.eventRaceModel.every(isEmptyEventRaceModel);

    if (allEventRaceModelsEmpty) {
      showErrorDialog("At least select one event race category");
      return;
    }


      eventModel.certificateStatus = certificateStatus;
      eventModel.createdAt = DateTime.now();
      eventModel.declaration = declarationController.text;
      eventModel.eventDate = DateTime.parse(eventDateController.text);
      eventModel.eventName = eventNameController.text;
      //eventModel.id = idController.text;
      eventModel.instruction = instructionController.text;
      eventModel.place = placeController.text;
      eventModel.regAmount = regAmountController.text;
      eventModel.eventPrefixName = eventPrefixNameController.text;
      eventModel.regCloseDate = DateTime.parse(regCloseDateController.text);
      eventModel.regStartDate = DateTime.parse(regStartDateController.text);
      eventModel.updatedAt = DateTime.now();
      eventModel.visibility = visibility;
      eventModel.ageAsOn = DateTime.parse(ageAsOnDateController.text);

      // Save races from raceControllers
      eventModel.eventRaces = eventRaces!;

    if (eventModel.eventName.isEmpty ||
        eventModel.eventPrefixName.isEmpty ||
        eventModel.place.isEmpty ||
        eventModel.regAmount.isEmpty ||
        eventModel.declaration.isEmpty ||
        eventModel.instruction.isEmpty ||
        eventDateController.text.isEmpty ||
        regStartDateController.text.isEmpty ||
        regCloseDateController.text.isEmpty ||
        ageAsOnDateController.text.isEmpty||
        eventModel.eventRaceModel.every((race) => race.categoryName.isEmpty && race.raceAgeGroup.isEmpty)) {
      showErrorDialog("Please fill out all required fields");
      return;
    }
      // Handle form submission logic
      print('Event Name: ${eventModel.eventName}');
      print('Event Date: ${eventModel.eventDate}');
      print('Registration Amount: ${eventModel.regAmount}');
      for (var i = 0; i < raceControllers.length; i++) {
        print('Race ${i + 1}: ${raceControllers[i].text}');
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator(),),);
      // Call method to save the data to the database
    print(1);
      try {
        print(2);

        if (advertisementFile != null) {
          print(3);

          eventModel.advertisement = await uploadFileToStorage('events/advertisement', advertisementFile!.name, isWeb: true, webFile: advertisementFile);
        }
        else{
          eventModel.advertisement='';

        }
        if (bannerFile != null) {
          print(5);

          eventModel.bannerImage = await uploadFileToStorage('events/banner', bannerFile!.name, isWeb: true, webFile: bannerFile);
        }
        else{
          print(6);
          eventModel.bannerImage='';

        }
        print(7);



        eventModel.eventRaceModel=[beginnerEventRaceModel!,fancyEventRaceModel!,quadEventRaceModel!,inlineEventRaceModel!];
        // Submit event details to Firebase
        print("submitEventDetails");
        await submitEventDetails();
      } catch (e) {
        // Handle any errors during upload
        print('Error uploading files: $e');
        Navigator.pop(context);
        showErrorDialog("Error uploading images: $e");
      }
  }


  bool checkRaces(){
    if(eventRaces!.length==0 || eventRaces == null){
      return true;
    }
    return false;
  }


  bool checkSelectedAgeGroup(){
    if(selectedAgeGroupList!.length==0 || selectedAgeGroupList==null){
      return true;
    }
    return false;
  }

  void setBeginner(){
    List<EventRace> emptylist =[];
    beginnerEventRaceModel!.raceAgeGroup.clear();
    for (String ageGroupItem in selectedAgeGroupList!) {

      RaceAgeGroup raceAgeGroup = RaceAgeGroup(
          ageGroup: ageGroupItem,
          maxEvents: 0,
          eventRaces: emptylist
      );

      // Add specific races from eventRaces to the current RaceAgeGroup
      for (int i = 0; i < eventRaces!.length; i++) {
        EventRace eventRace = EventRace(race: eventRaces![i], selected: false);
        raceAgeGroup.eventRaces.add(eventRace);
      }

      raceAgeGroup.eventRaces = removeDuplicateEventRaces(raceAgeGroup.eventRaces);

      setState((){
        beginnerEventRaceModel!.raceAgeGroup.add(raceAgeGroup);
      });

    }


  }
  void setQuad(){
    List<EventRace> emptylist =[];
    quadEventRaceModel!.raceAgeGroup.clear();

    for (String ageGroupItem in selectedAgeGroupList!) {

      RaceAgeGroup raceAgeGroup = RaceAgeGroup(
          ageGroup: ageGroupItem,
          maxEvents: 0,
          eventRaces: emptylist
      );

      // Add specific races from eventRaces to the current RaceAgeGroup
      for (int i = 0; i < eventRaces!.length; i++) {
        EventRace eventRace = EventRace(race: eventRaces![i], selected: false);
        raceAgeGroup.eventRaces.add(eventRace);
      }

      raceAgeGroup.eventRaces = removeDuplicateEventRaces(raceAgeGroup.eventRaces);

      setState((){
        quadEventRaceModel!.raceAgeGroup.add(raceAgeGroup);
      });

    }
    
  }
  void setFancy(){
    List<EventRace> emptylist =[];
    fancyEventRaceModel!.raceAgeGroup.clear();

    for (String ageGroupItem in selectedAgeGroupList!) {

      RaceAgeGroup raceAgeGroup = RaceAgeGroup(
          ageGroup: ageGroupItem,
          maxEvents: 0,
          eventRaces: emptylist
      );

      // Add specific races from eventRaces to the current RaceAgeGroup
      for (int i = 0; i < eventRaces!.length; i++) {
        EventRace eventRace = EventRace(race: eventRaces![i], selected: false);
        raceAgeGroup.eventRaces.add(eventRace);
      }
      raceAgeGroup.eventRaces = removeDuplicateEventRaces(raceAgeGroup.eventRaces);

      setState((){
        fancyEventRaceModel!.raceAgeGroup.add(raceAgeGroup);
      });

    }


  }
  void setInline(){
    List<EventRace> emptylist =[];
    inlineEventRaceModel!.raceAgeGroup.clear();

    for (String ageGroupItem in selectedAgeGroupList!) {

      RaceAgeGroup raceAgeGroup = RaceAgeGroup(
          ageGroup: ageGroupItem,
          maxEvents: 0,
          eventRaces: emptylist
      );

      // Add specific races from eventRaces to the current RaceAgeGroup
      for (int i = 0; i < eventRaces!.length; i++) {
        EventRace eventRace = EventRace(race: eventRaces![i], selected: false);
        raceAgeGroup.eventRaces.add(eventRace);
      }

      raceAgeGroup.eventRaces = removeDuplicateEventRaces(raceAgeGroup.eventRaces);

      setState((){
        inlineEventRaceModel!.raceAgeGroup.add(raceAgeGroup);
      });

    }


  }

  void updateAgeGroup(){
    print("updateAgeGroup updateAgeGroup $selectedAgeGroupList");
    setBeginner();
    setQuad();
    setInline();
    setFancy();
  }

  List<EventRace> removeDuplicateEventRaces(List<EventRace> eventRaces) {
    final seenRaces = <String>{};
    return eventRaces.where((eventRace) {
      if (seenRaces.contains(eventRace.race)) {
        return false;
      } else {
        seenRaces.add(eventRace.race);
        return true;
      }
    }).toList();
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

  void updateEventRaceModel(List<RaceAgeGroup> raceAgeGroups, String category) {
    setState(() {
      switch (category) {
        case 'Beginner':
          beginnerEventRaceModel!.raceAgeGroup.clear();
          beginnerEventRaceModel!.raceAgeGroup=raceAgeGroups;
          eventModel.eventRaceModel[0]=beginnerEventRaceModel!;
          break;
        case 'Quad':
          quadEventRaceModel!.raceAgeGroup.clear();
          quadEventRaceModel!.raceAgeGroup=raceAgeGroups;
          eventModel.eventRaceModel[1]=quadEventRaceModel!;
          break;
        case 'Fancy':
          fancyEventRaceModel!.raceAgeGroup.clear();
          fancyEventRaceModel!.raceAgeGroup=raceAgeGroups;
          eventModel.eventRaceModel[2]=fancyEventRaceModel!;
          break;
        case 'Inline':
          inlineEventRaceModel!.raceAgeGroup.clear();
          inlineEventRaceModel!.raceAgeGroup=raceAgeGroups;
          eventModel.eventRaceModel[3]=inlineEventRaceModel!;
          break;
        default:
        // Handle unknown category
          print('Unknown category: $category');
      }
    });
  }

  void _showRaceTableDialog(EventRaceModel eventRaceModel) {
    print("EventRaceModel");
    print(eventRaceModel.raceAgeGroup.map((e) => e.ageGroup));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaginatedRaceTable(raceAgeGroups: eventRaceModel.raceAgeGroup, eventRaces: eventRaces!, updateEventRaceModel: updateEventRaceModel, category: eventRaceModel.categoryName, );
      },
    );
  }


  Future<void> submitEventDetails() async {
    print("submitEventDetails 1");

    try {
      print("submitEventDetails 2");

      eventModel.id = await _generateEventID();
      print("submitEventDetails 3");

      if(certificateFile != null){
        certificateImgUrl = await uploadFileToStorage('events/certificates', '${eventModel.id}_${certificateFile!.name}', isWeb: true, webFile: certificateFile);
      }
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('events/pastEvents/${eventModel.id}/');
      print("submitEventDetails 4");

      await usersRef.set(eventModel.toJson());
      await usersRef.child('certificateGenerateDetails/imageUrl/').set(certificateImgUrl);
      await usersRef.child('certificateGenerateDetails/imageContent/').set(certificateContentController.text);
      print("submitEventDetails 5");

      // Show success dialog
      Navigator.pop(context);
      Navigator.pop(context);
      print("submitEventDetails 6");

      widget.updateEventModels(eventModel);
      showSuccessDialog("Event data saved successfully");
    } on FirebaseException catch (e) {
      // Handle Firebase-specific exceptions
      print('FirebaseException: $e');
      Navigator.pop(context);
      print("submitEventDetails 7");

      showErrorDialog("Error saving event data: ${e.message}");
    } catch (e) {
      // Handle all other exceptions
      print('Exception: $e');
      Navigator.pop(context);

      showErrorDialog("Error saving event data: $e");
    }

    print("submitEventDetails 9");

  }

  bool? beginnerValue = false;
  bool? fancyValue = false;
  bool? quadValue = false;
  bool? inlineValue = false;

  @override
  void dispose() {
    advertisementController.dispose();
    bannerImageController.dispose();
    createdAtController.dispose();
    declarationController.dispose();
    eventDateController.dispose();
    eventNameController.dispose();
    idController.dispose();
    instructionController.dispose();
    certificateContentController.dispose();
    placeController.dispose();
    regAmountController.dispose();
    eventPrefixNameController.dispose();
    regCloseDateController.dispose();
    regStartDateController.dispose();
    for (var controller in raceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateAgeGroup();
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return MaterialApp(

      supportedLocales: [
        const Locale('en', 'US'),
        // add other supported locales here
      ],
      home: Scaffold(
        appBar: AppBar(
          title: Text('Create Event'),
          backgroundColor: Color(0xffb0ccf8),
          leading: IconButton(
            icon: Icon(Icons.arrow_back), onPressed: () { Navigator.pop(context); },
          ),
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child:width<600? Form(
            key: _formKeyWeb,
            child: ListView(
              children: <Widget>[
                //Event name
                TextFormField(
                  controller: eventNameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    eventModel.eventName = value!;
                  },
                ),
                SizedBox(height: 16.0),

                //Event races
                GestureDetector(
                  onTap: () {
                    showAddRaceDialog(context, eventRaces!);
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: eventRaceController,
                      decoration: InputDecoration(
                        labelText: 'Event Races',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),

                //event place
                TextFormField(
                  controller: placeController,
                  decoration: InputDecoration(
                    labelText: 'Place',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the place';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    eventModel.place = value!;
                  },
                ),
                SizedBox(height: 16.0),

                //Event Date
                TextFormField(
                  controller: eventDateController,
                  decoration: InputDecoration(
                    labelText: 'Event Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        eventDateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        eventModel.eventDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                //Reg Start Date
                TextFormField(
                  controller: regStartDateController,
                  decoration: InputDecoration(
                    labelText: 'Registration Start Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        regStartDateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        eventModel.regStartDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter registration start date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                //Reg Close date
                TextFormField(
                  controller: regCloseDateController,
                  decoration: InputDecoration(
                    labelText: 'Registration Close Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        regCloseDateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        eventModel.regCloseDate = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter registration close date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                //Age as on Date
                TextFormField(
                  controller: ageAsOnDateController,
                  decoration: InputDecoration(
                    labelText: 'Age as On',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        ageAsOnDateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        eventModel.ageAsOn = pickedDate;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter age as on date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),

                //event amount
                TextFormField(
                  controller: regAmountController,
                  decoration: InputDecoration(
                    labelText: 'Registration Amount',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter registration amount';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    eventModel.regAmount = value!;
                  },
                ),
                SizedBox(height: 16.0),


                //event prefix number
                TextFormField(
                  controller: eventPrefixNameController,
                  maxLines: 1,
                  // keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Event Prefix Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event prefix name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    eventModel.eventPrefixName = value!;
                  },
                ),
                SizedBox(height: 16.0),

                Text("Advertisement Image"),
                GestureDetector(
                  onTap: () => _pickImage(true),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: advertisementImage != null
                        ? Image.memory(advertisementImage!, fit: BoxFit.cover)
                        : Center(child: Text('Select Advertisement Image')),
                  ),
                ),
                SizedBox(height: 16.0),

                Text("Banner Image"),
                GestureDetector(
                  onTap: () => _pickImage(false),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: bannerImage != null
                        ? Image.memory(bannerImage!, fit: BoxFit.cover)
                        : Center(child: Text('Select Banner Image')),
                  ),
                ),
                SizedBox(height: 16.0),

                //Declaration
                Text("Declaration"),
                TextFormField(
                  controller: declarationController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10, //
                  minLines: 10, // Set initial size to show 10 lines
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter declaration';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    eventModel.declaration = value!;
                  },
                ),
                SizedBox(height: 16.0),

                //Instruction
                Text("Instruction"),
                TextFormField(
                  controller: instructionController,
                  decoration: InputDecoration(
                    // labelText: 'Instruction',
                    border: OutlineInputBorder(),
                  ),
                    maxLines: 10, //
                    minLines: 10,
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter instruction';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    eventModel.instruction = value!;
                  },
                ),

                SizedBox(height: 16.0),
                SwitchListTile(
                  title: Text('Certificate Status'),
                  value: certificateStatus,
                  onChanged: (bool value) {
                    setState(() {
                      certificateStatus = value;
                      eventModel.certificateStatus = value;
                    });
                  },
                ),

                SizedBox(height: 16.0),


                //certificate
                Text("Certificate Image"),
                GestureDetector(
                  onTap: () => _pickCertificateImage(),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: certificateImage != null
                        ? Image.memory(certificateImage!, fit: BoxFit.cover)
                        : Center(child: Text('Select Certificate Image')),
                  ),
                ),
                // SwitchListTile(
                //   title: Text('Visibility'),
                //   value: visibility,
                //   onChanged: (bool value) {
                //     setState(() {
                //       visibility = value;
                //       eventModel.visibility = value;
                //     });
                //   },
                // ),
                const SizedBox(height: 16.0),


                // Instruction
                buildNullTitleAndField(
                  'Certificate Content',
                  'Enter Certificate Content',
                  controller: certificateContentController,
                  isMultiline: true,
                ),
                const SizedBox(height: 16.0),



                DropdownButtonFormField<String>(
                  value: selectedAgeGroup,
                  onChanged: (newValue) async {
                     setState(() {
                      selectedAgeGroup = newValue;

                      if(newValue!.contains("Odd")){
                        selectedAgeGroupList = oddAgeGroup;
                        eventModel.ageCategory = oddAgeGroup;
                      }else{
                        selectedAgeGroupList = evenAgeGroup;
                        eventModel.ageCategory = evenAgeGroup;
                      }

                    });
                     updateAgeGroup();

                  },
                  items: ageGroup.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Select Age Group'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select age group';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.0),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if(checkSelectedAgeGroup()){
                            showErrorDialog("Please select age group");
                            return;
                          }

                          if(checkRaces()){
                            showErrorDialog("Please create Race for the event");
                            return;
                          }

                          setState(() {
                            if (beginnerEventRaceModel == null) {
                              _showRaceTableDialog(beginnerEventRaceModel!);
                            } else {
                              // beginnerEventRaceModel = null;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: beginnerValue,
                              onChanged: (bool? value) {
                                if(checkSelectedAgeGroup() || checkRaces()){
                                  return;
                                }

                                setState(() {
                                  beginnerValue= !beginnerValue!;
                                  if (value == true) {
                                    _showRaceTableDialog(beginnerEventRaceModel!);
                                  } else {
                                    //    beginnerEventRaceModel = null;
                                  }
                                });
                              },
                            ),
                            Text('Beginner Event Race'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if(checkSelectedAgeGroup()){
                            showErrorDialog("Please select age group");
                            return;
                          }

                          if(checkRaces()){
                            showErrorDialog("Please create Race for the event");
                            return;
                          }
                          setState(() {
                            if (fancyEventRaceModel == null) {
                              _showRaceTableDialog(fancyEventRaceModel!);
                            } else {
                              // fancyEventRaceModel = null;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: fancyValue,
                              onChanged: (bool? value) {
                                if(checkSelectedAgeGroup() || checkRaces()){
                                  return;
                                }
                                setState(() {
                                  fancyValue = !fancyValue!;
                                  if (value == true) {
                                    _showRaceTableDialog(fancyEventRaceModel!);
                                  } else {
                                    // fancyEventRaceModel = null;
                                  }
                                });
                              },
                            ),
                            Text('Fancy Event Race'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if(checkSelectedAgeGroup()){
                            showErrorDialog("Please select age group");
                            return;
                          }

                          if(checkRaces()){
                            showErrorDialog("Please create Race for the event");
                            return;
                          }
                          setState(() {
                            if (quadEventRaceModel == null) {
                              _showRaceTableDialog(quadEventRaceModel!);
                            } else {
                              // quadEventRaceModel = null;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: quadValue,
                              onChanged: (bool? value) {
                                if(checkSelectedAgeGroup() || checkRaces()){
                                  return;
                                }
                                setState(() {
                                  quadValue = !quadValue!;
                                  if (value == true) {
                                    _showRaceTableDialog(quadEventRaceModel!);
                                  } else {
                                    // quadEventRaceModel = null;
                                  }
                                });
                              },
                            ),
                            Text('Quad Event Race'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if(checkSelectedAgeGroup()){
                            showErrorDialog("Please select age group");
                            return;
                          }

                          if(checkRaces()){
                            showErrorDialog("Please create Race for the event");
                            return;
                          }
                          setState(() {
                            if (inlineEventRaceModel == null) {
                              _showRaceTableDialog(inlineEventRaceModel!);
                            } else {
                              // inlineEventRaceModel = null;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: inlineValue,
                              onChanged: (bool? value) {
                                if(checkSelectedAgeGroup() || checkRaces()){
                                  return;
                                }
                                setState(() {
                                  inlineValue = !inlineValue!;
                                  if (value == true) {
                                    _showRaceTableDialog(inlineEventRaceModel!);
                                  } else {
                                    // inlineEventRaceModel = null;
                                  }
                                });
                              },
                            ),
                            Text('Inline Event Race'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {

                    _submitForm();
                  },
                  child: Text('Submit'),
                ),
                SizedBox(height: 50,)

              ],
            ),
          ):
          SingleChildScrollView(
            child: Container(
              width: width - 100,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: width * .05),
                      Expanded(
                        child: Form(
                          key: _formKeyMobile1,
                          child: Column(
                            children: <Widget>[
                              // Event Name
                              buildTitleAndField(
                                'Event Name',
                                'Enter event name',
                                controller: eventNameController,
                              ),
                              const SizedBox(height: 16.0),

                              // Event Races
                              GestureDetector(
                                onTap: () {
                                  showAddRaceDialog(context, eventRaces!);
                                },
                                child: AbsorbPointer(
                                  child: buildTitleAndField(
                                    'Event Races',
                                    'Select event races',
                                    controller: eventRaceController,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Place
                              buildTitleAndField(
                                'Place',
                                'Enter place',
                                controller: placeController,
                              ),
                              const SizedBox(height: 16.0),

                              // Event Prefix Number
                              buildTitleAndField(
                                'Event Prefix Number',
                                'Enter prefix number',
                                controller: eventPrefixNameController,
                                // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                              const SizedBox(height: 16.0),

                              // Declaration
                              buildTitleAndField(
                                'Declaration',
                                'Enter declaration',
                                controller: declarationController,
                                isMultiline: true,
                              ),
                              const SizedBox(height: 16.0),

                              // Banner Image
                              Text("Banner Image"),
                              GestureDetector(
                                onTap: () => _pickImage(false),
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: bannerImage != null
                                      ? Image.memory(bannerImage!, fit: BoxFit.cover)
                                      : Center(child: Text('Select Banner Image')),
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Certificate Status Switch
                              SwitchListTile(
                                title: Text('Certificate Status'),
                                value: certificateStatus,
                                onChanged: (bool value) {
                                  setState(() {
                                    certificateStatus = value;
                                    eventModel.certificateStatus = value;
                                  });
                                },
                              ),


                              const SizedBox(height: 16.0),

                              Text("Certificate Image"),
                              GestureDetector(
                                onTap: () => _pickCertificateImage(),
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: certificateImage != null
                                      ? Image.memory(certificateImage!, fit: BoxFit.cover)
                                      : Center(child: Text('Select Certificate Image')),
                                ),
                              ),

                              const SizedBox(height: 16.0),

                              // Age Group Dropdown
                              buildTitleAndDropdown(
                                'Select Age Group',
                                'Choose an age group',
                                ageGroup,
                                selectedAgeGroup,
                                    (newValue) {
                                  setState(() {
                                    selectedAgeGroup = newValue;

                                    if (newValue!.contains("Odd")) {
                                      selectedAgeGroupList = oddAgeGroup;
                                      eventModel.ageCategory = oddAgeGroup;
                                    } else {
                                      selectedAgeGroupList = evenAgeGroup;
                                      eventModel.ageCategory = evenAgeGroup;
                                    }
                                  });

                                  updateAgeGroup();
                                },
                              ),


                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: width * .05),
                      Expanded(
                        child: Form(
                          key: _formKeyMobile2,
                          child: Column(
                            children: <Widget>[
                              // Event Date
                              GestureDetector(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      eventDateController.text =
                                          DateFormat('yyyy-MM-dd').format(pickedDate);
                                      eventModel.eventDate = pickedDate;
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  child: buildTitleAndField(
                                    'Event Date',
                                    'Select event date',
                                    controller: eventDateController,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Registration Start Date
                              GestureDetector(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      regStartDateController.text =
                                          DateFormat('yyyy-MM-dd').format(pickedDate);
                                      eventModel.regStartDate = pickedDate;
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  child: buildTitleAndField(
                                    'Registration Start Date',
                                    'Select registration start date',
                                    controller: regStartDateController,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Registration Close Date
                              GestureDetector(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      regCloseDateController.text =
                                          DateFormat('yyyy-MM-dd').format(pickedDate);
                                      eventModel.regCloseDate = pickedDate;
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  child: buildTitleAndField(
                                    'Registration Close Date',
                                    'Select registration close date',
                                    controller: regCloseDateController,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Age as On Date
                              GestureDetector(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      ageAsOnDateController.text =
                                          DateFormat('yyyy-MM-dd').format(pickedDate);
                                      eventModel.ageAsOn = pickedDate;
                                    });
                                  }
                                },
                                child: AbsorbPointer(
                                  child: buildTitleAndField(
                                    'Age as On',
                                    'Select age as on date',
                                    controller: ageAsOnDateController,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16.0),

                              // Registration Amount
                              buildTitleAndField(
                                'Registration Amount',
                                'Enter registration amount',
                                controller: regAmountController,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                              const SizedBox(height: 16.0),

                              // Instruction
                              buildTitleAndField(
                                'Instruction',
                                'Enter instructions',
                                controller: instructionController,
                                isMultiline: true,
                              ),
                              const SizedBox(height: 16.0),

                              // Advertisement Image
                              Text("Advertisement Image"),
                              GestureDetector(
                                onTap: () => _pickImage(true),
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: advertisementImage != null
                                      ? Image.memory(advertisementImage!, fit: BoxFit.cover)
                                      : Center(child: Text('Select Advertisement Image')),
                                ),
                              ),
                              const SizedBox(height: 26.0),


                              // Instruction
                              buildNullTitleAndField(
                                'Certificate Content',
                                'Enter Certificate Content',

                                controller: certificateContentController,
                                isMultiline: true,
                              ),
                              // Visibility Switch
                              // SwitchListTile(
                              //   title: Text('Visibility'),
                              //   value: visibility,
                              //   onChanged: (bool value) {
                              //     setState(() {
                              //       visibility = value;
                              //       eventModel.visibility = value;
                              //     });
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: width * .05),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if(checkSelectedAgeGroup()){
                              showErrorDialog("Please select age group");
                              return;
                            }

                            if(checkRaces()){
                              showErrorDialog("Please create Race for the event");
                              return;
                            }

                            setState(() {
                              if (beginnerEventRaceModel == null) {
                                _showRaceTableDialog(beginnerEventRaceModel!);
                              } else {
                                // beginnerEventRaceModel = null;
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: beginnerValue,
                                onChanged: (bool? value) {
                                  if(checkSelectedAgeGroup() || checkRaces()){
                                    return;
                                  }

                                  setState(() {
                                    beginnerValue= !beginnerValue!;
                                    if (value == true) {
                                      _showRaceTableDialog(beginnerEventRaceModel!);
                                    } else {
                                      //    beginnerEventRaceModel = null;
                                    }
                                  });
                                },
                              ),
                              Text('Beginner Event Race'),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if(checkSelectedAgeGroup()){
                              showErrorDialog("Please select age group");
                              return;
                            }

                            if(checkRaces()){
                              showErrorDialog("Please create Race for the event");
                              return;
                            }
                            setState(() {
                              if (fancyEventRaceModel == null) {
                                _showRaceTableDialog(fancyEventRaceModel!);
                              } else {
                                // fancyEventRaceModel = null;
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: fancyValue,
                                onChanged: (bool? value) {
                                  if(checkSelectedAgeGroup() || checkRaces()){
                                    return;
                                  }
                                  setState(() {
                                    fancyValue = !fancyValue!;
                                    if (value == true) {
                                      _showRaceTableDialog(fancyEventRaceModel!);
                                    } else {
                                      // fancyEventRaceModel = null;
                                    }
                                  });
                                },
                              ),
                              Text('Fancy Event Race'),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if(checkSelectedAgeGroup()){
                              showErrorDialog("Please select age group");
                              return;
                            }

                            if(checkRaces()){
                              showErrorDialog("Please create Race for the event");
                              return;
                            }
                            setState(() {
                              if (quadEventRaceModel == null) {
                                _showRaceTableDialog(quadEventRaceModel!);
                              } else {
                                // quadEventRaceModel = null;
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: quadValue,
                                onChanged: (bool? value) {
                                  if(checkSelectedAgeGroup() || checkRaces()){
                                    return;
                                  }
                                  setState(() {
                                    quadValue = !quadValue!;
                                    if (value == true) {
                                      _showRaceTableDialog(quadEventRaceModel!);
                                    } else {
                                      // quadEventRaceModel = null;
                                    }
                                  });
                                },
                              ),
                              Text('Quad Event Race'),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if(checkSelectedAgeGroup()){
                              showErrorDialog("Please select age group");
                              return;
                            }

                            if(checkRaces()){
                              showErrorDialog("Please create Race for the event");
                              return;
                            }
                            setState(() {
                              if (inlineEventRaceModel == null) {
                                _showRaceTableDialog(inlineEventRaceModel!);
                              } else {
                                // inlineEventRaceModel = null;
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Checkbox(
                                value: inlineValue,
                                onChanged: (bool? value) {
                                  if(checkSelectedAgeGroup() || checkRaces()){
                                    return;
                                  }
                                  setState(() {
                                    inlineValue = !inlineValue!;
                                    if (value == true) {
                                      _showRaceTableDialog(inlineEventRaceModel!);
                                    } else {
                                      // inlineEventRaceModel = null;
                                    }
                                  });
                                },
                              ),
                              Text('Inline Event Race'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {

                      certificateContentController.text.isEmpty?certificateContentController.text='':null;
                      if (_formKeyMobile1.currentState!.validate() && _formKeyMobile2.currentState!.validate()) {
                        _submitForm();
                      } else {
                        // Handle validation errors
                        _formKeyMobile2.currentState!.validate();
                        showErrorDialog('Please fill out all the fields');
                      }                    },
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}
