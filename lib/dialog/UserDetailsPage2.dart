import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:sport_ims/utils/MessageHelper.dart';


import '../models/UsersModel.dart';
import '../utils/Colors.dart';

class UserDetailsPage extends StatefulWidget {
  final Users user;
  final Function(Users) updateUserApproval;


  UserDetailsPage({required this.user, required this.updateUserApproval});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        backgroundColor: AppColors().bluePrimary,
        leading: IconButton(onPressed: () { Navigator.pop(context); },
          icon: Icon(Icons.arrow_back),

        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // For mobile view, display as a ListView
            return buildMobileView(context);
          } else {
            // For web view, display as a GridView
            return buildWebView(context, constraints.maxWidth);
          }
        },
      ),
    );
  }

  Widget buildMobileView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: CachedNetworkImageProvider(widget.user.profileImageUrl),
              backgroundColor: Colors.grey[200],
            ),
          ),
          SizedBox(height: 16),
          buildUserInfoListTile('Name', widget.user.name),
          buildUserInfoListTile('Address', widget.user.address),
          buildUserInfoListTile('State', widget.user.state),
          buildUserInfoListTile('District', widget.user.district),
          buildUserInfoListTile('School', widget.user.school),
          buildUserInfoListTile('School Affiliation Number', widget.user.schoolAffiliationNumber),
          buildUserInfoListTile('Club', widget.user.club),
          buildUserInfoListTile('Email', widget.user.email),
          buildUserInfoListTile('Contact Number', widget.user.contactNumber),
          buildUserInfoListTile('Blood Group', widget.user.bloodGroup),
          buildUserInfoListTile('Gender', widget.user.gender),
          buildUserInfoListTile('Skate Category', widget.user.skateCategory),
          buildUserInfoListTile('Aadhar/Birth Certificate Number', widget.user.aadharBirthCertificateNumber),
          buildUserInfoListTile('Date of Birth', widget.user.dateOfBirth),
          buildUserInfoListTile('Registration Date', widget.user.regDate),
          buildUserInfoListTile('Approval', widget.user.approval),
          SizedBox(height: 16),
          Center(
            child: Row(
              children: [
                if (widget.user.approval != "Approved")
                  ElevatedButton(
                    onPressed: () {
                      // Handle button press, e.g., navigate to document
                      approveUser(widget.user);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue, // Background color
                    ),
                    child: Text('Approve Skater'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    // Handle button press, e.g., navigate to document
                    _showDialog(context, widget.user.docFileUrl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue, // Background color
                  ),
                  child: Text('View Document'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWebView(BuildContext context, double maxWidth) {
    double aspectRatio = (maxWidth / 200);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(widget.user.profileImageUrl),
                backgroundColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: aspectRatio,
              shrinkWrap: true,
              children: <Widget>[
                buildUserInfoCard('Name', widget.user.name),
                buildUserInfoCard('Address', widget.user.address),
                buildUserInfoCard('State', widget.user.state),
                buildUserInfoCard('District', widget.user.district),
                buildUserInfoCard('School', widget.user.school),
                buildUserInfoCard('School Affiliation Number', widget.user.schoolAffiliationNumber),
                buildUserInfoCard('Club', widget.user.club),
                buildUserInfoCard('Email', widget.user.email),
                buildUserInfoCard('Contact Number', widget.user.contactNumber),
                buildUserInfoCard('Blood Group', widget.user.bloodGroup),
                buildUserInfoCard('Gender', widget.user.gender),
                buildUserInfoCard('Skate Category', widget.user.skateCategory),
                buildUserInfoCard('Aadhar/Birth Certificate Number', widget.user.aadharBirthCertificateNumber),
                buildUserInfoCard('Date of Birth', widget.user.dateOfBirth),
                buildUserInfoCard('Registration Date', widget.user.regDate),
                buildUserInfoCard('Approval', widget.user.approval),
              ],
            ),
            SizedBox(height: 16),
            Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.user.approval != "Approved")
                      ElevatedButton(
                        onPressed: () {
                          // Handle button press, e.g., navigate to document
                          approveUser(widget.user);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue, // Background color
                        ),
                        child: Text('Approve Skater'),
                      ),
                    if (widget.user.approval != "Approved")
                      SizedBox(width: 20,),
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press, e.g., navigate to document
                        _showDialog(context, widget.user.docFileUrl);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue, // Background color
                      ),
                      child: Text('View Document'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget buildUserInfoCard(String label, String value) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildUserInfoListTile(String label, String value) {
    return ListTile(
      tileColor: AppColors().blueTertiary,
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.lightBlue,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
  Future<void> registerPlayer(String playerId, String name, String phoneNumber) async {
    final String url = 'http://103.174.10.153:6017/sportims/player_reg/$playerId/$name/$phoneNumber';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the server returns an OK response, parse the data
        print('Player registered successfully');
        // Handle the response data as needed
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        print('Failed to register player');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error occurred: $e');
    }
  }
  Future<void> approvalPlayerSendEmail(String playerId, String name, String email) async {
    final String url = 'http://103.174.10.153:6017/send_approval_email/$email/$name/$playerId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the server returns an OK response, parse the data
        print('Player registered successfully');
        // Handle the response data as needed
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        print('Failed to register player');
      }
    } catch (e) {
      // Handle network or other errors
      print('Error occurred: $e');
    }
  }

  void approveUser(Users user) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Approval'),
          content: Text('Are you sure you want to approve this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if cancelled
              },
            ),
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if approved
              },
            ),
          ],
        );
      },
    );

    if (confirmed) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Approving..."),
              ],
            ),
          );
        },
      );

      try {
        // Update the user's approval status
        final ref = FirebaseDatabase.instance.ref('skaters/${user.contactNumber}');
        await ref.update({'approval': "Approved"});

        approvalPlayerSendEmail(user.skaterID,user.name,user.email);

        // Close the loading indicator
        Navigator.of(context).pop();

        setState(() {
            widget.user.approval = "Approved";


        });
        widget.updateUserApproval(user);

        sendPlayerApproval(name: widget.user.name, phoneNumber: '91${widget.user.contactNumber}', email: user.email);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User approved successfully.'))
        );
      } catch (error) {
        // Close the loading indicator
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve user. Please try again.'))
        );
      }
    }
  }


  Future<void> _launchURL(String url) async {
    html.window.open(url, '_blank');
  }

  Future<void> _showDialog(BuildContext context, String url) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            child: DocumentViewer(url: url),
          ),
        );
      },
    );
  }
}

class DocumentViewer extends StatefulWidget {
  final String url;

  DocumentViewer({required this.url});

  @override
  _DocumentViewerState createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    document = await PDFDocument.fromURL(widget.url);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(
            document: document,
            lazyLoad: false,
            zoomSteps: 1,
            numberPickerConfirmWidget: const Text("Confirm"),
          ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            html.window.open(widget.url, '_blank');
          },
          child: Text('Download'),
        ),
      ],
    );
  }
}
