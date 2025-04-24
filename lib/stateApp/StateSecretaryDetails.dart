import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/utils/Controllers.dart';
import 'dart:html' as html;
import '../models/StateSecretaryModel.dart';
import '../utils/Widgets.dart';

class StateSecretaryDetailsPage extends StatefulWidget {
  final StateSecretaryModel stateSecretary;
  final Function(StateSecretaryModel) updatestateSecretaryApproval;

  StateSecretaryDetailsPage({required this.stateSecretary, required this.updatestateSecretaryApproval});

  @override
  State<StateSecretaryDetailsPage> createState() => _stateSecretaryDetailsPageState();
}

class _stateSecretaryDetailsPageState extends State<StateSecretaryDetailsPage> {
  bool _isLoading = true;
  bool isImgDoc = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    String imgUrl = widget.stateSecretary.docUrl.toLowerCase();
    if (imgUrl.contains("png") || imgUrl.contains("jpg") || imgUrl.contains("jpeg")) {
      isImgDoc = true;
    }
    initializeForm();
  }

  void initializeForm() {
    nameController.text = widget.stateSecretary.name;
    addressController.text = widget.stateSecretary.address;
    stateController.text = widget.stateSecretary.stateName;
    emailController.text = widget.stateSecretary.email;
    contactController.text = widget.stateSecretary.contactNumber;
    passwordController.text = widget.stateSecretary.password; // Password will not be pre-filled for security reasons
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text('State Secretary Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],

        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _showEditDetailsDialog(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return buildMobileView(context);
          } else {
            return buildWebView(context, constraints.maxWidth);
          }
        },
      ),
    );
  }

  Widget buildMobileView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildInfoCard('Name', widget.stateSecretary.name),
          buildInfoCard('Address', widget.stateSecretary.address),
          buildInfoCard('State', widget.stateSecretary.stateName),
          buildInfoCard('Email', widget.stateSecretary.email),
          buildInfoCard('Contact Number', widget.stateSecretary.contactNumber),
          buildInfoCard('Registration Date', formatDate(widget.stateSecretary.regDate)),
          buildInfoCard('Approval Status', widget.stateSecretary.approval),
          if (isImgDoc) ...[
            const SizedBox(height: 16),
            Text("Adhaar Document", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700])),
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(widget.stateSecretary.docUrl, fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildWebView(BuildContext context, double maxWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: maxWidth / 250,
            shrinkWrap: true,
            children: <Widget>[
              buildInfoCard('Name', widget.stateSecretary.name),
              buildInfoCard('State Secretary ID', widget.stateSecretary.id),
              buildInfoCard('Address', widget.stateSecretary.address),
              buildInfoCard('State', widget.stateSecretary.stateName),
              buildInfoCard('Email', widget.stateSecretary.email),
              buildInfoCard('Contact Number', widget.stateSecretary.contactNumber),
              buildInfoCard('Society Certificate number', widget.stateSecretary.societyCertNumber),
              buildInfoCard('Aadhaar Number', widget.stateSecretary.adharNumber),
              buildInfoCard('Registration Date', formatDate(widget.stateSecretary.regDate)),
              buildInfoCard('Approval Status', widget.stateSecretary.approval),
            ],
          ),
          if (isImgDoc) ...[
            const SizedBox(height: 16),
            Text("Adhaar Document", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700])),
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(widget.stateSecretary.docUrl, fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Widget to build information cards
  Widget buildInfoCard(String label, String value) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 10.0,
              spreadRadius: 2.0,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }

  // Show Edit Details Dialog
  Future<void> _showEditDetailsDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Text('Edit State Secretary Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                buildTitleAndField('Enter Name','Name', controller: nameController),
                buildTitleAndField('Enter Address','Address', controller:addressController),
                buildTitleAndField('Enter State','State',controller: stateController,readOnly: true),
                buildTitleAndField('Enter Email', 'Email',controller:emailController),
                buildTitleAndField('Enter Contact Number','Contact Number', controller:contactController),
                buildPasswordField('Password', 'Enter new password', controller: passwordController),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () => _updatestateSecretaryDetails(context),
            ),
          ],
        );
      },
    );
  }



  // Widget for Password Field

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

  // Update District Secretary Details in Firebase
  Future<void> _updatestateSecretaryDetails(BuildContext context) async {
    try {
      final ref = FirebaseDatabase.instance.ref('stateSecretaries/${widget.stateSecretary.id}');
      await ref.update({
        'name': nameController.text,
        'address': addressController.text,
        'stateName': stateController.text,
        'email': emailController.text,
        'contactNumber': contactController.text,
        if (passwordController.text.isNotEmpty) 'password': passwordController.text,
      });

      setState(() {
        widget.stateSecretary.name = nameController.text;
        widget.stateSecretary.address = addressController.text;
        widget.stateSecretary.stateName = stateController.text;
        widget.stateSecretary.email = emailController.text;
        widget.stateSecretary.contactNumber = contactController.text;
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details updated successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update details: $e')));
    }
  }
}
