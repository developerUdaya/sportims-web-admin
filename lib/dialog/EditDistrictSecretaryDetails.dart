import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
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
import '../utils/Widgets.dart';

class EditDistrictSecretaryDialog extends StatefulWidget {
  final Function(DistrictSecretaryModel) updateDistrictSecretary;
  final DistrictSecretaryModel districtSecretaryModel;

  EditDistrictSecretaryDialog({required this.updateDistrictSecretary, required this.districtSecretaryModel});

  @override
  _EditDistrictSecretaryDialogState createState() => _EditDistrictSecretaryDialogState();
}

class _EditDistrictSecretaryDialogState extends State<EditDistrictSecretaryDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController societyCertificateNumberController = TextEditingController();
  TextEditingController pickedDocumentFileName = TextEditingController();
  TextEditingController pickedSocietyCertificateFileName = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? selectedState;
  String? selectedDistrict;

  bool obscurePassword = true; // For hiding/showing password

  List<States> states = Constants().states;
  List<District> allDistrict = Constants().districts;
  List<District> district = [];

  late String societyCertFileUrl;
  late String aadharCertFileUrl;
  PlatformFile? _pickedDocument;
  PlatformFile? _pickedSocietyCertificate;
  PlatformFile? _pickedAadharCertificate;
  html.File? _pickedWebDocument;
  html.File? _pickedWebSocietyCertificate;
  html.File? _pickedWebAadharCertificate;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.districtSecretaryModel.name;
    addressController.text = widget.districtSecretaryModel.address;
    emailController.text = widget.districtSecretaryModel.email;
    contactController.text = widget.districtSecretaryModel.contactNumber;
    aadharController.text = widget.districtSecretaryModel.adharNumber;
    selectedState = widget.districtSecretaryModel.stateName;
    selectedDistrict = widget.districtSecretaryModel.districtName;
    societyCertificateNumberController.text = widget.districtSecretaryModel.societyCertNumber;
    passwordController.text = widget.districtSecretaryModel.password;
    societyCertFileUrl = widget.districtSecretaryModel.societyCertUrl;
    aadharCertFileUrl = widget.districtSecretaryModel.docUrl;

    pickedDocumentFileName.text = widget.districtSecretaryModel.docUrl.toString().split('/').toList().last.toString();
    pickedSocietyCertificateFileName.text = widget.districtSecretaryModel.societyCertUrl.toString().split('/').toList().last.toString();



    _filterDistrictByState(selectedState!);
  }

  void _filterDistrictByState(String stateName) {
    setState(() {
      district = allDistrict.where((d) => d.state == stateName).toList();
      if (!district.any((d) => d.name == selectedDistrict)) {
        selectedDistrict = district.isNotEmpty ? district.first.name : null;
      }
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );



    if (_pickedWebSocietyCertificate == null) {
      societyCertFileUrl = widget.districtSecretaryModel.societyCertUrl;
    } else {
      societyCertFileUrl = kIsWeb
          ? await uploadFileToStorage('', _pickedWebSocietyCertificate!.name, isWeb: true, webFile: _pickedWebSocietyCertificate)
          : await uploadFileToStorage(_pickedSocietyCertificate!.path!, _pickedSocietyCertificate!.name);
    }

    if (_pickedWebAadharCertificate == null) {
      aadharCertFileUrl = widget.districtSecretaryModel.adharNumber;
    } else {
      aadharCertFileUrl = kIsWeb
          ? await uploadFileToStorage('', _pickedWebAadharCertificate!.name, isWeb: true, webFile: _pickedWebAadharCertificate)
          : await uploadFileToStorage(_pickedAadharCertificate!.path!, _pickedAadharCertificate!.name);
    }

    DistrictSecretaryModel newDistrictSecretary = DistrictSecretaryModel(
      name: nameController.text,
      address: addressController.text,
      email: emailController.text,
      contactNumber: contactController.text,
      adharNumber: aadharController.text,
      stateName: selectedState!,
      districtName: selectedDistrict!,
      docUrl: aadharCertFileUrl,
      id: widget.districtSecretaryModel.id,
      regDate: widget.districtSecretaryModel.regDate,
      createdAt: widget.districtSecretaryModel.createdAt,
      updatedAt: DateTime.now().toString(),
      approval: widget.districtSecretaryModel.approval,
      password: passwordController.text.isNotEmpty ? passwordController.text : widget.districtSecretaryModel.password,
      societyCertNumber: societyCertificateNumberController.text,
      societyCertUrl: societyCertFileUrl,
    );

    try {
      DatabaseReference districtSecretaryRef =
      FirebaseDatabase.instance.ref().child('districtSecretaries/${newDistrictSecretary.id}/');
      await districtSecretaryRef.set(newDistrictSecretary.toJson());
      widget.updateDistrictSecretary(newDistrictSecretary);
      showSuccessDialog("District Secretary data updated successfully");
    } catch (e) {
      showErrorDialog("Error saving district secretary data: $e");
    }

    setState(() {});
    Navigator.pop(context);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Edit District Secretary'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        buildTitleAndField('Name', 'Enter Name', controller: nameController),
                        const SizedBox(height: 18),
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
                        buildFileUploadButton('Upload Aadhar Certificate', pickedDocumentFileName, (file) {
                          setState(() {
                            _pickedWebAadharCertificate = file;
                            pickedDocumentFileName.text = file.name;
                          });
                        }),
                        const SizedBox(height: 18),
                        buildFileUploadButton('Upload Society Certificate', pickedSocietyCertificateFileName, (file) {
                          setState(() {
                            _pickedWebSocietyCertificate = file;
                            pickedSocietyCertificateFileName.text = file.name;
                          });
                        }),
                      ],
                    ),

                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        buildTitleAndField('Address', 'Enter Address', controller: addressController, isMultiline: true),
                        const SizedBox(height: 18),
                        buildTitleAndField('Contact Number', 'Enter Contact Number', controller: contactController, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                        const SizedBox(height: 18),
                        buildTitleAndField('Society Certificate Number', 'Enter Society Certificate Number', controller: societyCertificateNumberController),
                        const SizedBox(height: 18),
                        buildTitleAndField('Aadhar Number', 'Enter Aadhar Number', controller: aadharController, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                        const SizedBox(height: 18),
                        buildPasswordField('Password', 'Enter Password', controller: passwordController),

                      ],
                    ),
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


            if (_formKey.currentState!.validate()) {
              if (!isValidEmail(emailController.text)) {
                showErrorDialog("Enter Valid Email");
                return;
              }
              if (!isValidPhoneNumber(contactController.text)) {
                showErrorDialog("Enter Valid Mobile number");
                return;
              }
              saveDistrictSecretaryData();
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
