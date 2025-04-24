import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/UsersModel.dart';
import '../utils/Controllers.dart';
import '../utils/DateFormatter.dart';
import '../utils/Widgets.dart';

class SkaterEditRegistrationForm extends StatefulWidget {
  final Users skater;

  SkaterEditRegistrationForm({super.key, required this.skater});

  @override
  SkaterEditRegistrationFormState createState() => SkaterEditRegistrationFormState();
}

class SkaterEditRegistrationFormState extends State<SkaterEditRegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for editing profile fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _affiliationNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedGender;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController.text = widget.skater.name;
    _dobController.text = widget.skater.dateOfBirth;
    _addressController.text = widget.skater.address;
    _schoolController.text = widget.skater.school;
    _affiliationNumberController.text = widget.skater.schoolAffiliationNumber;
    _emailController.text = widget.skater.email;
    _contactNumberController.text = widget.skater.contactNumber;
    _aadharController.text = widget.skater.aadharBirthCertificateNumber;

    _selectedBloodGroup = widget.skater.bloodGroup;
    _selectedGender = widget.skater.gender;
    _selectedCategory = widget.skater.skateCategory;
  }

  // Method to handle form submission and save changes
  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      // Show the progress indicator dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevents dialog from closing on tap outside
        builder: (context) => Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );

      try {
        // Update the skater data in Firebase
        DatabaseReference ref = FirebaseDatabase.instance.ref('skaters/${widget.skater.contactNumber}');
        await ref.update({
          'name': _nameController.text,
          'address': _addressController.text,
          'school': _schoolController.text,
          'schoolAffiliationNumber': _affiliationNumberController.text,
          'email': _emailController.text,
          'bloodGroup': _selectedBloodGroup,
          'gender': _selectedGender,
          'skateCategory': _selectedCategory,
          'aadharBirthCertificateNumber': _aadharController.text,
          'dateOfBirth': _dobController.text,
        });

        // Close the progress indicator dialog
        if (mounted) Navigator.pop(context);

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Updated Successfully'),
              content: Text('Profile Data Updated Successfully'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the success dialog
                    Navigator.pop(context); // Go back to the previous screen
                  },
                  child: Text('Ok'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Failed to update profile: $e');

        // Close the progress indicator dialog if error occurs
        if (mounted) Navigator.pop(context);

        // Show failure dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Failed'),
              content: Text('Profile Data Updation Failed, Please try again'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the failure dialog
                  },
                  child: Text('Ok'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Edit Registration",style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.blue[700],
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded),
        onPressed: (){
          Navigator.pop(context);
        },
      ),),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 100,vertical: 50),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: buildTitleAndField('Name', 'Enter name', controller: _nameController),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildTitleAndField(
                        'Date of Birth',
                        'Enter date of birth (DD-MM-YYY)',
                        controller: _dobController,
                        inputFormatters: [DateInputFormatter()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildTitleAndField('Residential Address', 'Enter address', isMultiline: true, controller: _addressController),
                const SizedBox(height: 16),

                // State and District (Read-only)
                Row(
                  children: [
                    Expanded(
                      child: buildTitleAndDropdown('State', widget.skater.state, [widget.skater.state], widget.skater.state, (value) {},
                          enabled: false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildTitleAndDropdown('District', widget.skater.district, [widget.skater.district], widget.skater.district, (value) {},
                          enabled: false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // School and School Affiliation Number
                buildTitleAndField('School/College Name', 'Enter school/college name', controller: _schoolController),
                const SizedBox(height: 16),
                buildTitleAndField('School Affiliation Number', 'Enter school affiliation number', controller: _affiliationNumberController),
                const SizedBox(height: 16),

                // Club (Read-only)
                buildTitleAndDropdown('Club', widget.skater.club, [widget.skater.club], widget.skater.club, (value) {}, enabled: false),
                const SizedBox(height: 16),

                // Email and Contact Number (Contact Number is read-only)
                buildTitleAndField('Email ID', 'Enter email ID', controller: _emailController),
                const SizedBox(height: 16),
                buildTitleAndField('Contact Number', widget.skater.contactNumber, controller: _contactNumberController, readOnly: true),
                const SizedBox(height: 16),

                // Blood Group and Gender
                Row(
                  children: [
                    Expanded(
                      child: buildTitleAndDropdown('Blood Group', 'Select blood group', ['A+', 'B+', 'O+', 'AB+', 'A-', 'B-', 'O-', 'AB-'],
                          _selectedBloodGroup, (value) {
                            setState(() {
                              _selectedBloodGroup = value;
                            });
                          }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildTitleAndDropdown('Gender', 'Select gender', ['Male', 'Female', 'Other'], _selectedGender, (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Skate Category
                buildTitleAndDropdown('Skate Category', 'Select skate category', ['Beginner', 'Fancy', 'Quad', 'Inline'], _selectedCategory, (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }),
                const SizedBox(height: 16),

                buildTitleAndField('Aadhar/Birth Certificate Number', 'Enter Aadhar/Birth certificate number', controller: _aadharController),
                const SizedBox(height: 16),

                // Save Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
