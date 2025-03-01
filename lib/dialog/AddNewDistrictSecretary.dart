import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/Constants.dart';
import '../models/DistrictModel.dart';
import '../models/DistrictSecretaryModel.dart';
import '../models/StateModel.dart';
import '../utils/Controllers.dart';
import '../utils/MessageHelper.dart';
import '../utils/Widgets.dart';


class AddNewDistrictSecretaryDialog extends StatefulWidget {
  final Function(DistrictSecretaryModel) updateDistrictSecretary;

  AddNewDistrictSecretaryDialog({required this.updateDistrictSecretary});

  @override
  _AddNewDistrictSecretaryDialogState createState() => _AddNewDistrictSecretaryDialogState();
}

class _AddNewDistrictSecretaryDialogState extends State<AddNewDistrictSecretaryDialog> {
  final _formKey = GlobalKey<FormState>(); // Add a form key


  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController societyCertificateNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController pickedDocumentFileName = TextEditingController();
  TextEditingController pickedSocietyCertificateFileName = TextEditingController();

  String? selectedState;
  String? selectedDistrict;
  bool obscurePassword = true; // To toggle password visibility

  List<States> states = Constants().states;
  List<District> allDistrict = Constants().districts;
  List<District> district = Constants().districts.where((d) => d.state.contains("Tamil Nadu")).toList();

  html.File? _pickedWebDocument;
  html.File? _pickedSocietyCertificate;

  @override
  void initState() {
    super.initState();
  }

  void _filterDistrictByState(String stateName) {
    setState(() {
      district = allDistrict.where((d) => d.state.contains(stateName)).toList();
      selectedDistrict = allDistrict.where((d) => d.state.contains(stateName)).toList().first.name;
    });
  }

  Future<String> uploadFileToStorage(String path, String fileName, {bool isWeb = false, html.File? webFile}) async {
    try {
      if (isWeb && webFile != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(webFile);
        await reader.onLoad.first;

        final storageRef = FirebaseStorage.instance.ref('events/${DateTime.now().toString() + fileName}');
        final snapshot = await storageRef.putBlob(webFile);
        return await snapshot.ref.getDownloadURL();
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> saveDistrictSecretaryData() async {
    if (_pickedWebDocument == null || _pickedSocietyCertificate == null) {
      showSnackBar("Please upload all required documents");
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child:CircularProgressIndicator()
          );
        },
    );



    String docFileUrl = '';
    String societyCertFileUrl = '';

    if (kIsWeb) {
      docFileUrl = await uploadFileToStorage('', _pickedWebDocument!.name, isWeb: true, webFile: _pickedWebDocument);
      societyCertFileUrl = await uploadFileToStorage('', _pickedSocietyCertificate!.name, isWeb: true, webFile: _pickedSocietyCertificate);
    }

    if (docFileUrl.isEmpty || societyCertFileUrl.isEmpty) {
      return;
    }

    DistrictSecretaryModel newDistrictSecretary = DistrictSecretaryModel(
      id: await generateDistrictSecretaryID(selectedState!,selectedDistrict!),
      name: nameController.text,
      address: addressController.text,
      email: emailController.text,
      contactNumber: contactController.text,
      adharNumber: aadharController.text,
      stateName: selectedState!,
      districtName: selectedDistrict!,
      docUrl: docFileUrl,
      societyCertUrl: societyCertFileUrl,
      societyCertNumber: societyCertificateNumberController.text,
      password: passwordController.text,
      regDate: DateTime.now().toString(),
      createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
      approval: "Not Approved",
    );

    try {
      DatabaseReference districtSecretaryRef = FirebaseDatabase.instance.ref().child('districtSecretaries/${newDistrictSecretary.id}/');
      await districtSecretaryRef.set(newDistrictSecretary.toJson());
      widget.updateDistrictSecretary(newDistrictSecretary);
      Navigator.pop(context);
      Navigator.pop(context);
      sendRegistrationSuccessful(name: newDistrictSecretary.name!, role: 'District Secretary <br>  Username : ${newDistrictSecretary.id} <br>  password : ${newDistrictSecretary.password} <br> ', companyName: 'Sport-IMS', phoneNumber: newDistrictSecretary.contactNumber!, email: newDistrictSecretary.email!);

      showSuccessDialog("District Secretary data saved successfully");
    } catch (e) {
      showErrorDialog("Error saving data: $e");
    }
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(seconds: 2)),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,

      title: Text('Add New District Secretary'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey, // Attach form key to the form
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: buildColumnWithFields([
                      buildTitleAndField('Name', 'Enter Name', controller: nameController),
                      const SizedBox(height: 18), // Add space between widgets
                      buildTitleAndField('Email', 'Enter Email', controller: emailController),

                      const SizedBox(height: 18),
                      buildTitleAndDropdown('Select State', 'Choose State', states.map((state) => state.name).toList(), selectedState, (newValue) {
                        setState(() {
                          selectedState = newValue;
                          selectedDistrict = allDistrict.where((district) => district.state.contains(newValue!)).toList().first.name;
                        });
                        _filterDistrictByState(newValue!);
                      }),

                      const SizedBox(height: 18),
                      buildTitleAndDropdown('Select District', 'Choose District', district.map((d) => d.name).toList(), selectedDistrict, (newValue) {
                        setState(() {
                          selectedDistrict = newValue;
                        });
                      }),


                      const SizedBox(height: 18),
                      buildFileUploadButton('Upload Society Certificate', pickedSocietyCertificateFileName, (file) {
                        setState(() {
                          _pickedSocietyCertificate = file;
                          pickedSocietyCertificateFileName.text = file.name;
                        });
                      }),
                       const SizedBox(height: 10),
                      buildFileUploadButton('Upload Aadhar Document', pickedDocumentFileName, (file) {
                        setState(() {
                          _pickedWebDocument = file;
                          pickedDocumentFileName.text = file.name;
                        });
                      }),
                    ]),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: buildColumnWithFields([
                      buildTitleAndField('Address', 'Enter Address', controller: addressController, isMultiline: true),
                      const SizedBox(height: 18),
                      buildTitleAndField('Contact Number', 'Enter Contact Number', controller: contactController, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                      const SizedBox(height: 18),
                      buildTitleAndField('Society Certificate Number', 'Enter Society Certificate Number', controller: societyCertificateNumberController),
                      const SizedBox(height: 18),
                      buildTitleAndField('Aadhar Number', 'Enter Aadhar Number', controller: aadharController, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),

                      const SizedBox(height: 18),
                      buildPasswordField('Password', 'Enter Password', controller: passwordController),

                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Save'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) { // Check validation

              if (!isValidEmail(emailController.text)) {
                showErrorDialog("Enter Valid Email");
                return;
              }

              if (!isValidPhoneNumber(contactController.text)) {
                showErrorDialog("Enter Valid Mobile number");
                return;
              }

              if (await doesNumberExist(contactController.text)) {
                showErrorDialog("Mobile Number already exists");
                return;
              }

              saveDistrictSecretaryData(); // If valid, save data
            }

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

  Future<bool> doesNumberExist(String enteredNumber) async {
    final ref = FirebaseDatabase.instance.ref('districtSecretaries');
    final query = ref.orderByKey().equalTo(enteredNumber).limitToFirst(1);
    final snapshot = await query.get();
    final exists = snapshot.value != null ? (snapshot.value as Map).isNotEmpty : false;
    return exists;
  }
}
