import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/StateSecretaryModel.dart';
import '../utils/Widgets.dart';

class EditStateSecretaryPage extends StatefulWidget {
  final StateSecretaryModel stateSecretary;
  final Function(StateSecretaryModel) onUpdate;

  EditStateSecretaryPage({required this.stateSecretary, required this.onUpdate});

  @override
  _EditStateSecretaryPageState createState() => _EditStateSecretaryPageState();
}

class _EditStateSecretaryPageState extends State<EditStateSecretaryPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _stateController;
  late TextEditingController _emailController;
  late TextEditingController _contactNumberController;
  late TextEditingController _regDateController;

  @override
  void initState() {
    super.initState();

    // Initialize text controllers with existing values
    _nameController = TextEditingController(text: widget.stateSecretary.name);
    _addressController = TextEditingController(text: widget.stateSecretary.address);
    _stateController = TextEditingController(text: widget.stateSecretary.stateName);
    _emailController = TextEditingController(text: widget.stateSecretary.email);
    _contactNumberController = TextEditingController(text: widget.stateSecretary.contactNumber);
    _regDateController = TextEditingController(text: widget.stateSecretary.regDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _regDateController.dispose();
    super.dispose();
  }

  Future<void> _updateDistrictSecretary() async {
    if (_formKey.currentState!.validate()) {
      // Create updated district secretary model
      final updatedDistrictSecretary = StateSecretaryModel(
        id: widget.stateSecretary.id,
        name: _nameController.text,
        address: _addressController.text,
        stateName: _stateController.text,
        email: _emailController.text,
        contactNumber: _contactNumberController.text,
        regDate: _regDateController.text,
        approval: widget.stateSecretary.approval,
        docUrl: widget.stateSecretary.docUrl,
        adharNumber: '',
        createdAt: '',
        updatedAt: '',
        password: '',
        societyCertNumber: '',
        societyCertUrl: '',
      );

      // Update Firebase with new values
      final ref = FirebaseDatabase.instance.ref('stateSecretaries/${widget.stateSecretary.id}');
      await ref.update(updatedDistrictSecretary.toJson());

      // Call onUpdate callback with new model
      widget.onUpdate(updatedDistrictSecretary);

      // Navigate back to the details page with updated values
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit State Secretary'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTitleAndField('Enter Name','Name', controller: _nameController),
              buildTitleAndField('Enter Address','Address', controller:_addressController),
              buildTitleAndField('Enter State','State',controller: _stateController,readOnly: true),
              buildTitleAndField('Enter Email', 'Email',controller:_emailController),
              buildTitleAndField('Enter Contact Number','Contact Number', controller:_contactNumberController),

              buildTitleAndField('Enter Registration Date', 'Registration Date',controller:_regDateController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateDistrictSecretary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build a text field with validation
}
