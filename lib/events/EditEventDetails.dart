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


class EditEventDetails extends StatefulWidget {
  EventModel eventModel;
  Function(EventModel) updateEventModels;

  EditEventDetails({required this.eventModel, required this.updateEventModels});
  @override
  _EditEventDetailsState createState() => _EditEventDetailsState();
}

class _EditEventDetailsState extends State<EditEventDetails> {
  final GlobalKey<FormState> _formKeyWeb = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyMobile1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyMobile2 = GlobalKey<FormState>();


  late EventModel eventModel = EventModel(
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

  late TextEditingController advertisementController = TextEditingController();
  late TextEditingController bannerImageController = TextEditingController();
  late TextEditingController ageAsOnDateController = TextEditingController();
  bool certificateStatus = false;
  late TextEditingController createdAtController = TextEditingController();
  late TextEditingController eventRaceController = TextEditingController();
  late TextEditingController declarationController = TextEditingController();
  late TextEditingController eventDateController = TextEditingController();
  late TextEditingController eventNameController = TextEditingController();
  late TextEditingController idController = TextEditingController();
  late TextEditingController instructionController = TextEditingController();
  late TextEditingController certificateContentController = TextEditingController();

  late TextEditingController placeController = TextEditingController();
  late TextEditingController regAmountController = TextEditingController();
  late TextEditingController eventPrefixNameController = TextEditingController();
  late TextEditingController regCloseDateController = TextEditingController();
  late TextEditingController regStartDateController = TextEditingController();
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
      eventModel.ageAsOn =  DateTime.parse(ageAsOnDateController.text);

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
        eventModel.eventRaceModel.every((race) => race.categoryName.isEmpty && race.raceAgeGroup.isEmpty)) {
      showErrorDialog("Please fill out all required fields");
      return;
    }

    bool confirmation = await _showConfirmationDialog();
    if (!confirmation) {
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
        builder: (context) => const Center(child: CircularProgressIndicator()),);
      // Call method to save the data to the database
      try {
        if (advertisementFile != null) {
          eventModel.advertisement = await uploadFileToStorage('events/advertisement', advertisementFile!.name, isWeb: true, webFile: advertisementFile);
        }
        else{
          eventModel.advertisement = widget.eventModel.advertisement;

        }
        if (bannerFile != null) {
          eventModel.bannerImage = await uploadFileToStorage('events/banner', bannerFile!.name, isWeb: true, webFile: bannerFile);
        }
        else{
          eventModel.bannerImage = widget.eventModel.bannerImage;
        }


        // Submit event details to Firebase
        await submitEventDetails();
      } catch (e) {
        // Handle any errors during upload
        print('Error uploading files: $e');
        Navigator.pop(context);
        showErrorDialog("Error uploading images: $e");
      }
  }


  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Submission'),
          content: Text('Are you sure you want to update the event details?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    ) ?? false; // Return false if the dialog is dismissed without selection
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

      setState((){
        beginnerEventRaceModel!.raceAgeGroup.add(raceAgeGroup);
      });

    }


  }
  void setQuad(){
    List<EventRace> emptylist =[];
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

      setState((){
        quadEventRaceModel!.raceAgeGroup.add(raceAgeGroup);
      });

    }


  }
  void setFancy(){
    List<EventRace> emptylist =[];
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

      setState((){
        fancyEventRaceModel!.raceAgeGroup.add(raceAgeGroup);
      });

    }


  }
  void setInline(){
    List<EventRace> emptylist =[];
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

      setState((){
        inlineEventRaceModel!.raceAgeGroup.add(raceAgeGroup);
      });

    }


  }

  void updateAgeGroup(){
    setBeginner();
    setQuad();
    setInline();
    setFancy();
     fetchCertificateData();
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
          beginnerEventRaceModel!.raceAgeGroup.addAll(raceAgeGroups);
          eventModel.eventRaceModel[0]=beginnerEventRaceModel!;
          break;
        case 'Quad':
          quadEventRaceModel!.raceAgeGroup.clear();
          quadEventRaceModel!.raceAgeGroup.addAll(raceAgeGroups);
          eventModel.eventRaceModel[1]=quadEventRaceModel!;
          break;
        case 'Fancy':
          fancyEventRaceModel!.raceAgeGroup.clear();
          fancyEventRaceModel!.raceAgeGroup.addAll(raceAgeGroups);
          eventModel.eventRaceModel[2]=fancyEventRaceModel!;
          break;
        case 'Inline':
          inlineEventRaceModel!.raceAgeGroup.clear();
          inlineEventRaceModel!.raceAgeGroup.addAll(raceAgeGroups);
          eventModel.eventRaceModel[3]=inlineEventRaceModel!;
          break;
        default:
        // Handle unknown category
          print('Unknown category: $category');
      }
    });
  }

  void _showRaceTableDialog(EventRaceModel eventRaceModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PaginatedRaceTable(raceAgeGroups: eventRaceModel.raceAgeGroup, eventRaces: eventRaces!, updateEventRaceModel: updateEventRaceModel, category: eventRaceModel.categoryName, );
      },
    );
  }


  Future<void> submitEventDetails() async {
    try {
      eventModel.id = widget.eventModel.id;

      if(certificateFile != null){
        certificateImgUrl = await uploadFileToStorage('events/certificates', '${eventModel.id}_${certificateFile!.name}', isWeb: true, webFile: certificateFile);
      }
      
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('events/pastEvents/${eventModel.id}/');
      await usersRef.set(eventModel.toJson());

      await usersRef.child('certificateGenerateDetails/imageUrl/').set(certificateImgUrl);
      await usersRef.child('certificateGenerateDetails/imageContent/').set(certificateContentController.text);
      // Show success dialog
      Navigator.pop(context);
      Navigator.pop(context);

      widget.updateEventModels(eventModel);

      showSuccessDialog("Event data saved successfully");
    } on FirebaseException catch (e) {
      // Handle Firebase-specific exceptions
      print('FirebaseException: $e');
      Navigator.pop(context);

      showErrorDialog("Error saving event data: ${e.message}");
    } catch (e) {
      // Handle all other exceptions
      print('Exception: $e');
      Navigator.pop(context);

      showErrorDialog("Error saving event data: $e");
    }
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

  // Initialize the controllers with eventModel data
  @override
  void initState() {
    super.initState();
    updateAgeGroup();

    eventNameController = TextEditingController(text: widget.eventModel.eventName);
    eventRaceController = TextEditingController(text: widget.eventModel.eventRaces.toString()); // Set this appropriately
    placeController = TextEditingController(text: widget.eventModel.place);
    eventDateController = TextEditingController(text: widget.eventModel.eventDate != null ? DateFormat('yyyy-MM-dd').format(widget.eventModel.eventDate!) : '');
    regCloseDateController = TextEditingController(text: widget.eventModel.regCloseDate != null ? DateFormat('yyyy-MM-dd').format(widget.eventModel.regCloseDate!) : '');
    regStartDateController = TextEditingController(text: widget.eventModel.regStartDate != null ? DateFormat('yyyy-MM-dd').format(widget.eventModel.regStartDate!) : '');
    regAmountController = TextEditingController(text: widget.eventModel.regAmount);
    eventPrefixNameController = TextEditingController(text: widget.eventModel.eventPrefixName);
    declarationController = TextEditingController(text: widget.eventModel.declaration);
    instructionController = TextEditingController(text: widget.eventModel.instruction);
    ageAsOnDateController = TextEditingController(text:widget.eventModel.ageAsOn != null ? DateFormat('yyyy-MM-dd').format(widget.eventModel.ageAsOn!) : '');
    certificateStatus = widget.eventModel.certificateStatus;
    visibility = widget.eventModel.visibility;
    selectedAgeGroup = widget.eventModel.ageCategory != null && widget.eventModel.ageCategory!.isNotEmpty ? (widget.eventModel.ageCategory!.first.contains("Odd") ? "Odd" : "Even") : null;
    selectedAgeGroupList = widget.eventModel.ageCategory ;

    final beginner = widget.eventModel.eventRaceModel.firstWhere(
          (element) => element.categoryName.toString().toLowerCase().contains("beginner"),
      orElse: () => beginnerEventRaceModel!,
    );
    final fancy = widget.eventModel.eventRaceModel.firstWhere(
          (element) => element.categoryName.toString().toLowerCase().contains("fancy"),
      orElse: () => fancyEventRaceModel!,
    );
    final quad = widget.eventModel.eventRaceModel.firstWhere(
          (element) => element.categoryName.toString().toLowerCase().contains("quad"),
      orElse: () => quadEventRaceModel!,
    );
    final inline = widget.eventModel.eventRaceModel.firstWhere(
          (element) => element.categoryName.toString().toLowerCase().contains("inline"),
      orElse: () => inlineEventRaceModel!,
    );

    // Assign new values only if they are different from the old ones
    if (beginner != beginnerEventRaceModel) {
      beginnerEventRaceModel = beginner;
    }
    if (fancy != fancyEventRaceModel) {
      fancyEventRaceModel = fancy;
    }
    if (quad != quadEventRaceModel) {
      quadEventRaceModel = quad;
    }
    if (inline != inlineEventRaceModel) {
      inlineEventRaceModel = inline;
    }

    beginnerValue = !beginnerEventRaceModel!.raceAgeGroup.every((element) => element.eventRaces.every((element) => element.selected==false));
    fancyValue = !fancyEventRaceModel!.raceAgeGroup.every((element) => element.eventRaces.every((element) => element.selected==false));
    quadValue = !quadEventRaceModel!.raceAgeGroup.every((element) => element.eventRaces.every((element) => element.selected==false));
    inlineValue = !inlineEventRaceModel!.raceAgeGroup.every((element) => element.eventRaces.every((element) => element.selected==false));

    eventRaces = widget.eventModel.eventRaces;
    eventModel = widget.eventModel;
  }


  Future<void> fetchCertificateData() async {
    DatabaseReference usersRef = FirebaseDatabase.instance
        .ref()
        .child('events/pastEvents/${widget.eventModel.id}/certificateGenerateDetails/');

    try {
      DataSnapshot urlSnapshot = await usersRef.child('imageUrl').get();
      DataSnapshot contentSnapshot = await usersRef.child('imageContent').get();

      setState(() {
        certificateImgUrl = (urlSnapshot.value as String?)!;
        certificateContentController = TextEditingController(text: contentSnapshot.value as String?);

      });

      // print("Certificate URL: $url");
      // print("Certificate Content: $content");
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return MaterialApp(
      color: Colors.white,

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
                        : Image.network(widget.eventModel.advertisement),
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
                        : Image.network(widget.eventModel.bannerImage),
                  ),
                ),
                SizedBox(height: 16.0),

                //Declaration
                Text('Declaration'),
                TextFormField(
                  controller: declarationController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10,
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
                Text('Instruction'),
                TextFormField(
                  controller: instructionController,
                  decoration: InputDecoration(
                    // labelText: 'Instruction',
                    border: OutlineInputBorder(),
                  ),
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
                        : Image.network(certificateImgUrl),
                  ),
                ),

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
                  onChanged: (newValue) {
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
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        _submitForm();
                      },
                      child: Text('Update Details'),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                ),
                SizedBox(height: 50,)

              ],
            ),
          ):
          SingleChildScrollView(
            child: Container(
              color: Colors.white,
              width: width,
              child:  Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: width*.05,
                      ),
                    Expanded(
                      child: Form(
                        key: _formKeyMobile1,
                        child: Column(
                          children: <Widget>[
                            //Event Name
                            buildTitleAndField(
                              'Event Name',
                              'Enter event name',
                              controller: eventNameController,
                            ),
                            SizedBox(height: 16.0),

                            // Event races
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
                            SizedBox(height: 16.0),

                            // Event place
                            buildTitleAndField(
                              'Place',
                              'Enter place',
                              controller: placeController,
                            ),
                            SizedBox(height: 16.0),

                            // Event prefix number
                            buildTitleAndField(
                              'Event Prefix Number',
                              'Enter event prefix number',
                              controller: eventPrefixNameController,
                              // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            SizedBox(height: 16.0),

                            // Declaration
                            buildTitleAndField(
                              'Declaration',
                              'Enter declaration',
                              isMultiline: true,
                              controller: declarationController,
                            ),
                            SizedBox(height: 16.0),

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
                                    : Image.network(widget.eventModel.bannerImage),
                              ),
                            ),
                            SizedBox(height: 16.0),

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
                                    : Image.network(certificateImgUrl),
                              ),
                            ),

                            const SizedBox(height: 16.0),

                            // Age Group Dropdown
                            buildTitleAndDropdown(
                              'Select Age Group',
                              'Choose age group',
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
                              SizedBox(height: 16.0),

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
                                    'Select start date',
                                    controller: regStartDateController,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),

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
                                    'Select close date',
                                    controller: regCloseDateController,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),

                              // Age as on Date
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
                              SizedBox(height: 16.0),

                              // Registration Amount
                              buildTitleAndField(
                                'Registration Amount',
                                'Enter registration amount',
                                controller: regAmountController,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                              SizedBox(height: 16.0),

                              // Instruction
                              buildTitleAndField(
                                'Instruction',
                                'Enter instruction',
                                isMultiline: true,
                                controller: instructionController,
                              ),
                              SizedBox(height: 16.0),

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
                                      : Image.network(widget.eventModel.advertisement),
                                ),
                              ),
                              SizedBox(height: 16.0),


                              const SizedBox(height: 26.0),

                              // Instruction
                              buildNullTitleAndField(
                                'Certificate Content',
                                'Enter Certificate Content',
                                controller: certificateContentController,
                                isMultiline: true,
                              ),
                              // const SizedBox(height: 16.0),
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
                    onPressed: (){
                        if (_formKeyMobile1.currentState!.validate() && _formKeyMobile2.currentState!.validate()) {
                          _submitForm();
                        } else {
                          // Handle validation errors
                          _formKeyMobile2.currentState!.validate();

                          showErrorDialog('Please fill out all the fields');
                        }
                      },
                    child: Text('Update'),
                  ),
                  SizedBox(height: 16.0),


                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}

