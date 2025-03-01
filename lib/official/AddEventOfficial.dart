import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/EventModel.dart';
import '../models/EventOfficialModel.dart';
import '../models/UserCredentialsModel.dart';
import '../utils/Controllers.dart';
import '../utils/Widgets.dart';

class AddEventOfficial extends StatefulWidget {
  final Function(EventOfficialModel) updateEventOfficialModels;

  AddEventOfficial({required this.updateEventOfficialModels});

  @override
  _AddEventOfficialState createState() => _AddEventOfficialState();
}

class _AddEventOfficialState extends State<AddEventOfficial> {
  final _formKey = GlobalKey<FormState>();
  html.File? bannerFile; // Save the local file for later upload
  String? imageUrl;
  String? selectedEvent;
  String? selectedId;
  List<EventModel> events = [];
  List<Map<String, dynamic>> textFields = [];
  double imageContainerWidth =200;
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  // Controllers
  final TextEditingController officialNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool certificateStatus = false;
  bool obscurePassword = true;

  EventOfficialModel? eventOfficialModel;

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

  Future<void> submitForm() async {

    if (!_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      return; // Exit if form validation fails
    }

    // if(bannerFile==null || textFields.isEmpty){
    //   Navigator.of(context).pop();
    //   showErrorDialog("Add Certificate Background and required Text Fields");
    //   return;
    // }

    bool usernameExists = await checkUsernameExists(userNameController.text);
    if (usernameExists) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: SelectableText('Username Exists'),
          content: SelectableText('This username already exists. Please choose a different one.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {


      // Assign values from input fields to the eventOfficialModel
      eventOfficialModel!.createdAt = DateTime.now().toString();
      eventOfficialModel!.officialName = officialNameController.text;
      eventOfficialModel!.userName = userNameController.text;
      eventOfficialModel!.password = passwordController.text;
      eventOfficialModel!.eventName = selectedEvent!;
      eventOfficialModel!.eventId = selectedId!;
      eventOfficialModel!.id = await _generateEventOfficialID();
      eventOfficialModel!.cetificateStatus = true;
      eventOfficialModel!.updatedAt = DateTime.now().toString();


      try {


        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        // Ensure the text fields are saved with new line characters preserved
        // final DatabaseReference ref = database.child("events/pastEvents/$selectedId/certificateDetails/");
        // String certificateFirebaseUrl = await uploadFileToFirebase();
        //
        // await ref.set({
        //   'imageUrl': certificateFirebaseUrl,
        //   'textFields': textFields.map((field) {
        //     field['text'] = field['text'].replaceAll('\n', '\\n'); // Preserve line breaks as \\n
        //     return field;
        //   }).toList(),
        // });


        await submitEventDetails();
      } catch (e) {
        Navigator.pop(context);
        showErrorDialog("Error Uploading Data : $e");
      }
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
    final ref = FirebaseDatabase.instance.ref().child('eventOfficials');
    final snapshot = await ref.get();

    int userCount = snapshot.children.length;
    String uniqueId = (userCount + 1).toString().padLeft(4, '0'); // Pads the ID to 4 digits

    return 'OFF$uniqueId';
  }

  // Method to select background image from local file
  void selectBackgroundImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();

      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) async {
        setState(() {
          imageUrl = reader.result as String; // Store local data URL for display
          bannerFile = file; // Store the file for later upload
        });
      });
    });

    Uint8List imageBytes = _base64ToUint8List(imageUrl!);
    final image = Image.memory(imageBytes);

    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        // print('Image width: ${info.image.width}');
        setState(() {
          imageContainerWidth = info.image.width as double;
        });
        // print('Image height: ${info.image.height}');
      }),
    );
  }

  // Method to upload the file to Firebase when needed
  Future<String> uploadFileToFirebase() async {
    String downloadUrl='';
      final storageRef = FirebaseStorage.instance.ref().child("certificate_backgrounds/${bannerFile!.name}");
      await storageRef.putBlob(bannerFile!);
      downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        imageUrl = downloadUrl; // Update to Firebase URL after upload
      });

    return downloadUrl;
  }


  void addTextField() {
    setState(() {
      textFields.add({
        'x': 10.0,
        'y': 10.0,
        'text': 'New Text',
        'fontSize': 20.0,
        'color': Colors.black.value,
      });
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,

      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
      backgroundColor: Colors.white,
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

                  // const SizedBox(height: 16),
                  // const Divider(thickness: 2),
                  // const Text("Certificate Template Builder", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  // const SizedBox(height: 16),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //         child: Center(
                  //           child: Container(
                  //             height: 594,
                  //             width: 420,
                  //             decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  //             child: Stack(
                  //               children: [
                  //                 if (imageUrl != null)
                  //                   Positioned.fill(
                  //                     child: imageUrl!.startsWith('data:image/')
                  //                         ? Image.memory(
                  //                       _base64ToUint8List(imageUrl!),
                  //                       fit: BoxFit.fitHeight,
                  //                     )
                  //                         : Image.network(imageUrl!, fit: BoxFit.cover),
                  //                   ),
                  //                 for (var textField in textFields)
                  //                   Positioned(
                  //                     left: textField['x'],
                  //                     top: textField['y'],
                  //                     child: Draggable(
                  //                       data: textField,
                  //                       feedback: Material(
                  //                         child: Text(
                  //                           textField['text'],
                  //                           style: TextStyle(
                  //                             fontSize: textField['fontSize'],
                  //                             color: Color(textField['color']),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       childWhenDragging: Container(),
                  //                       child: GestureDetector(
                  //                         onTap: () => editTextField(textField),
                  //                         child: Text(
                  //                           textField['text'],
                  //                           style: TextStyle(
                  //                             fontSize: textField['fontSize'],
                  //                             color: Color(textField['color']),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       onDragEnd: (details) {
                  //                         _updateTextFieldPosition(details, textField);
                  //                       },
                  //                     ),
                  //                   ),
                  //               ],
                  //             ),
                  //           ),
                  //
                  //         )
                  //     ),
                  //     Expanded(
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.start,
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             MaterialButton(
                  //               color: Colors.blue,
                  //               onPressed: selectBackgroundImage,
                  //               child: const Text("Upload Background Image",style:TextStyle(color: Colors.white)),
                  //             ),
                  //             const SizedBox(height: 16),
                  //             MaterialButton(
                  //               color: Colors.blue,
                  //               onPressed: addTextField,
                  //               child: const Text("Add Text Field",style:TextStyle(color: Colors.white)),
                  //             ),
                  //             const SizedBox(height: 16),
                  //           ],
                  //         )
                  //     )
                  //   ],
                  // ),
                  Center(
                    child: MaterialButton(
                      color: Colors.blue,
                      onPressed: submitForm,
                      child: const Text('Submit',style:TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Uint8List _base64ToUint8List(String base64) {
    // Convert Base64 string to Uint8List for Image.memory
    final UriData? data = Uri.parse(base64).data;
    return data!.contentAsBytes();
  }

  void _updateTextFieldPosition(DraggableDetails details, Map<String, dynamic> textField) {
    setState(() {
      textField['x'] = details.offset.dx;
      textField['y'] = details.offset.dy-100;
    });
  }

  void editTextField(Map<String, dynamic> textField) async {
    TextEditingController controller = TextEditingController(text: textField['text']);
    double fontSize = textField['fontSize'];
    Color color = Color(textField['color']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Text Field"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: null,
              decoration: const InputDecoration(hintText: "Enter text here (Use \\n for new lines)"),
            ),
            Slider(
              value: fontSize,
              min: 10,
              max: 100,
              divisions: 90,
              label: fontSize.toString(),
              onChanged: (value) {
                setState(() {
                  fontSize = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                Color? selectedColor = await pickColor(context, color);
                if (selectedColor != null) {
                  setState(() {
                    color = selectedColor;
                  });
                }
              },
              child: const Text("Select Color"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              textField['text'] = controller.text;
              textField['fontSize'] = fontSize;
              textField['color'] = color.value;
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<Color?> pickColor(BuildContext context, Color currentColor) async {
    Color tempColor = currentColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (Color color) {
              tempColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(tempColor),
            child: const Text("Select"),
          ),
        ],
      ),
    );

    return tempColor;
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
