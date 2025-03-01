import 'dart:html' as html;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_ims/models/UserCredentialsModel.dart';

import '../models/Constants.dart';
import '../utils/Controllers.dart';
import '../utils/MessageHelper.dart';
import '../utils/Widgets.dart';

class AddNewAdminDialog extends StatefulWidget {
  final Function(UserCredentials) updateAdmin;

  AddNewAdminDialog({required this.updateAdmin});

  @override
  _AddNewAdminDialogState createState() => _AddNewAdminDialogState();
}

class _AddNewAdminDialogState extends State<AddNewAdminDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController usernameController = TextEditingController(); // Added username controller
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true; // To toggle password visibility


  @override
  void initState() {
    super.initState();
  }

  Future<String> uploadFileToStorage(String path, String fileName, {bool isWeb = false, html.File? webFile}) async {
    try {
      if (isWeb && webFile != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(webFile);
        await reader.onLoad.first;

        final storageRef = FirebaseStorage.instance.ref('admin/${DateTime.now().toString() + fileName}');
        final snapshot = await storageRef.putBlob(webFile);
        return await snapshot.ref.getDownloadURL();
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> saveAdminData() async {
    bool usernameExists = await checkUsernameExists(usernameController.text);
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
      showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );




      UserCredentials newAdmin = UserCredentials(
          username: usernameController.text,
          // Save the username in the model
          name: nameController.text,
          password: passwordController.text,
          createdAt: DateTime.now().toString(),
          status: true,
          role: 'admin',
          eventId: '',
          mobileNumber: contactController.text,

          accessLog: []
      );

      try {
        DatabaseReference adminRef = FirebaseDatabase.instance.ref().child(
            'users/${newAdmin.username}/');
        await adminRef.set(newAdmin.toJson());
        await adminRef.child('email').set(emailController.text);
        widget.updateAdmin(newAdmin);
        Navigator.pop(context);
        Navigator.pop(context);

        sendRegistrationSuccessful(name: newAdmin.name!, role: 'admin <br> Username : ${newAdmin.username} <br> Password : ${newAdmin.password} <br>', companyName: 'Sport-IMS', phoneNumber: newAdmin.mobileNumber!, email: emailController.text);

        showSuccessDialog("Admin data saved successfully");
      } catch (e) {
        showErrorDialog("Error saving data: $e");
      }
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
      title: Text('Add New Admin'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTitleAndField('Username', 'Enter Username', controller: usernameController), // Username field
              const SizedBox(height: 18),
              buildTitleAndField('Name', 'Enter Admin Name', controller: nameController),

              const SizedBox(height: 18),
              buildTitleAndField('Contact Number', 'Enter Contact Number', controller: contactController, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
              const SizedBox(height: 18),
              buildTitleAndField('Email', 'Enter Email', controller: emailController),

              const SizedBox(height: 18),
              buildPasswordField('Password', 'Enter Password', controller: passwordController),
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
                showErrorDialog("Enter Valid Mobile Number");
                return;
              }

              saveAdminData();
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
}
