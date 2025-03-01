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

class EditEventOfficial extends StatefulWidget {
  final EventOfficialModel eventOfficialModel;
  final Function(EventOfficialModel) updateEventOfficialModels;

  EditEventOfficial({
    required this.eventOfficialModel,
    required this.updateEventOfficialModels,
  });

  @override
  _EditEventOfficialState createState() => _EditEventOfficialState();
}

class _EditEventOfficialState extends State<EditEventOfficial> {
  final _formKey = GlobalKey<FormState>();
  html.File? bannerFile; // Save the local file for later upload
  String? imageUrl;
  String? selectedEvent;
  String? selectedId;
  List<EventModel> events = [];
  List<Map<String, dynamic>> textFields = [];
  double imageContainerWidth = 200;
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  // Controllers
  final TextEditingController officialNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool certificateStatus = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _getEventModels();
    _fetchCertificateTemplate();
  }

  Future<void> _initializeFields() async {
    // Initialize controllers with the existing data from eventOfficialModel
    officialNameController.text = widget.eventOfficialModel.officialName;
    userNameController.text = widget.eventOfficialModel.userName;
    passwordController.text = widget.eventOfficialModel.password;
    selectedEvent = widget.eventOfficialModel.eventName;
    selectedId = widget.eventOfficialModel.eventId;
    certificateStatus = widget.eventOfficialModel.cetificateStatus;
    imageUrl = widget.eventOfficialModel.imgUrl; // Use the saved certificate image URL
  }

  Future<void> _getEventModels() async {
    List<EventModel> fetchedEventModels = await getEventModels();
    setState(() {
      events.addAll(fetchedEventModels);
    });
  }

  Future<void> _fetchCertificateTemplate() async {
    // Fetch certificate details from Firebase using eventId
    final ref = database.child("events/pastEvents/${widget.eventOfficialModel.eventId}/certificateDetails/");
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map); // Cast the data properly
      setState(() {
        imageUrl = data['imageUrl'] as String;
        textFields = List<Map<String, dynamic>>.from((data['textFields'] as List).map((item) => Map<String, dynamic>.from(item)));
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      return; // Exit if form validation fails
    }

    if (textFields.isEmpty) {
      Navigator.of(context).pop();
      showErrorDialog("Add required Text Fields");
      return;
    }

    if(bannerFile!=null || imageUrl!.isNotEmpty) {

      bool usernameExists =widget.eventOfficialModel.userName==userNameController.text?false: await checkUsernameExists(userNameController.text);
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
                child: SelectableText('OK'),
              ),
            ],
          ),
        );
      } else {
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
            const Center(child: CircularProgressIndicator()),
          );

          // Update event official data in Firebase
          final DatabaseReference ref = database.child(
              "events/pastEvents/$selectedId/certificateDetails/");
          String? certificateUrl = bannerFile == null
              ? imageUrl
              : await uploadFileToFirebase();
          await ref.set({
            'imageUrl': certificateUrl,
            'textFields': textFields.map((field) {
              field['text'] = field['text'].replaceAll(
                  '\n', '\\n'); // Preserve line breaks as \\n
              return field;
            }).toList(),
          });

          await _updateEventOfficialDetails();
        } catch (e) {
          Navigator.pop(context);
          showErrorDialog("Error Updating Data : $e");
        }
      }

    }else{
      Navigator.of(context).pop();
      showErrorDialog("Add Certificate Image");
      return;
    }
  }

  Future<void> _updateEventOfficialDetails() async {
    try {
      // Update the official details
      widget.eventOfficialModel.officialName = officialNameController.text;
      widget.eventOfficialModel.userName = userNameController.text;
      widget.eventOfficialModel.password = passwordController.text;
      widget.eventOfficialModel.eventName = selectedEvent!;
      widget.eventOfficialModel.eventId = selectedId!;
      widget.eventOfficialModel.cetificateStatus = certificateStatus;
      widget.eventOfficialModel.updatedAt = DateTime.now().toString();

      // Save updated event official model in Firebase
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('eventOfficials/${widget.eventOfficialModel.id}/');
      await usersRef.update(widget.eventOfficialModel.toJson());

      DatabaseReference userCredentialRef = FirebaseDatabase.instance.ref().child('users/${widget.eventOfficialModel.userName}/');
      await userCredentialRef.update({
        'username': widget.eventOfficialModel.userName,
        'password': widget.eventOfficialModel.password,
      });

      Navigator.pop(context);
      widget.updateEventOfficialModels(widget.eventOfficialModel);
      showSuccessDialog("Event Official data updated successfully");
    } catch (e) {
      Navigator.pop(context);
      showErrorDialog("Error updating event official data: $e");
    }
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
        setState(() {
          imageContainerWidth = info.image.width as double;
        });
      }),
    );
  }

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
        title: const Text('Edit Event Official'),
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
                          buildTitleAndField('User Name', 'Enter User Name', controller: userNameController,readOnly: true),
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
                  const Divider(thickness: 2),
                  const Text("Certificate Template Builder", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Container(
                            height: 594,
                            width: 420,
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                            child: Stack(
                              children: [
                                if (imageUrl != null)
                                  Positioned.fill(
                                    child: imageUrl!.startsWith('data:image/')
                                        ? Image.memory(
                                      _base64ToUint8List(imageUrl!),
                                      fit: BoxFit.fitHeight,
                                    )
                                        : Image.network(imageUrl!, fit: BoxFit.cover),
                                  ),
                                for (var textField in textFields)
                                  Positioned(
                                    left: textField['x'],
                                    top: textField['y'],
                                    child: Draggable(
                                      data: textField,
                                      feedback: Material(
                                        child: Text(
                                          textField['text'],
                                          style: TextStyle(
                                            fontSize: textField['fontSize'],
                                            color: Color(textField['color']),
                                          ),
                                        ),
                                      ),
                                      childWhenDragging: Container(),
                                      child: GestureDetector(
                                        onTap: () => editTextField(textField),
                                        child: Text(
                                          textField['text'],
                                          style: TextStyle(
                                            fontSize: textField['fontSize'],
                                            color: Color(textField['color']),
                                          ),
                                        ),
                                      ),
                                      onDragEnd: (details) {
                                        _updateTextFieldPosition(details, textField);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MaterialButton(
                              color: Colors.blue,
                              onPressed: selectBackgroundImage,
                              child: const Text("Upload Background Image", style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(height: 16),
                            MaterialButton(
                              color: Colors.blue,
                              onPressed: addTextField,
                              child: const Text("Add Text Field", style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: MaterialButton(
                      color: Colors.blue,
                      onPressed: _submitForm,
                      child: const Text('Update', style: TextStyle(color: Colors.white)),
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
      textField['y'] = details.offset.dy - 100;
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
