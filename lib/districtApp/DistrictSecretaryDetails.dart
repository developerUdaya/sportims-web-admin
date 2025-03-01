import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sport_ims/utils/Controllers.dart';
import 'dart:html' as html;
import '../models/DistrictSecretaryModel.dart';
import '../utils/Widgets.dart';

class DistrictSecretaryDetailsPage extends StatefulWidget {
  final DistrictSecretaryModel districtSecretary;
  final Function(DistrictSecretaryModel) updateDistrictSecretaryApproval;

  DistrictSecretaryDetailsPage({required this.districtSecretary, required this.updateDistrictSecretaryApproval});

  @override
  State<DistrictSecretaryDetailsPage> createState() => _DistrictSecretaryDetailsPageState();
}

class _DistrictSecretaryDetailsPageState extends State<DistrictSecretaryDetailsPage> {
  bool _isLoading = true;
  bool isImgDoc = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    String imgUrl = widget.districtSecretary.docUrl.toLowerCase();
    if (imgUrl.contains("png") || imgUrl.contains("jpg") || imgUrl.contains("jpeg")) {
      isImgDoc = true;
    }
    initializeForm();
  }

  void initializeForm() {
    nameController.text = widget.districtSecretary.name;
    addressController.text = widget.districtSecretary.address;
    stateController.text = widget.districtSecretary.stateName;
    districtController.text = widget.districtSecretary.districtName;
    emailController.text = widget.districtSecretary.email;
    contactController.text = widget.districtSecretary.contactNumber;
    passwordController.text = widget.districtSecretary.password; // Password will not be pre-filled for security reasons
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text('District Secretary Details', style: TextStyle(color: Colors.white)),
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
          buildInfoCard('Name', widget.districtSecretary.name),
          buildInfoCard('Address', widget.districtSecretary.address),
          buildInfoCard('State', widget.districtSecretary.stateName),
          buildInfoCard('District', widget.districtSecretary.districtName),
          buildInfoCard('Email', widget.districtSecretary.email),
          buildInfoCard('Contact Number', widget.districtSecretary.contactNumber),
          buildInfoCard('Registration Date', formatDate(widget.districtSecretary.regDate)),
          buildInfoCard('Approval Status', widget.districtSecretary.approval),
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
                child: Image.network(widget.districtSecretary.docUrl, fit: BoxFit.cover),
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
              buildInfoCard('Name', widget.districtSecretary.name),
              buildInfoCard('District Secretary ID', widget.districtSecretary.id),
              buildInfoCard('Address', widget.districtSecretary.address),
              buildInfoCard('State', widget.districtSecretary.stateName),
              buildInfoCard('District', widget.districtSecretary.districtName),
              buildInfoCard('Email', widget.districtSecretary.email),
              buildInfoCard('Contact Number', widget.districtSecretary.contactNumber),
              buildInfoCard('Society Certificate number', widget.districtSecretary.societyCertNumber),
              buildInfoCard('Aadhaar Number', widget.districtSecretary.adharNumber),
              buildInfoCard('Registration Date', formatDate(widget.districtSecretary.regDate)),
              buildInfoCard('Approval Status', widget.districtSecretary.approval),
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
                child: Image.network(widget.districtSecretary.docUrl, fit: BoxFit.cover),
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
          title: const Text('Edit District Secretary Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                buildTitleAndField('Enter Name','Name', controller: nameController),
                buildTitleAndField('Enter Address','Address', controller:addressController),
                buildTitleAndField('Enter State','State',controller: stateController,readOnly: true),
                buildTitleAndField('Enter District','District', controller:districtController,readOnly: true),
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
              onPressed: () => _updateDistrictSecretaryDetails(context),
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
  Future<void> _updateDistrictSecretaryDetails(BuildContext context) async {
    try {
      final ref = FirebaseDatabase.instance.ref('districtSecretaries/${widget.districtSecretary.id}');
      await ref.update({
        'name': nameController.text,
        'address': addressController.text,
        'stateName': stateController.text,
        'districtName': districtController.text,
        'email': emailController.text,
        'contactNumber': contactController.text,
        if (passwordController.text.isNotEmpty) 'password': passwordController.text,
      });

      setState(() {
        widget.districtSecretary.name = nameController.text;
        widget.districtSecretary.address = addressController.text;
        widget.districtSecretary.stateName = stateController.text;
        widget.districtSecretary.districtName = districtController.text;
        widget.districtSecretary.email = emailController.text;
        widget.districtSecretary.contactNumber = contactController.text;
      });
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details updated successfully.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update details: $e')));
    }
  }
}
