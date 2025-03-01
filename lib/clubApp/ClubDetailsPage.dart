import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:html' as html;

import '../models/ClubsModel.dart';
import '../utils/Colors.dart';
import 'EditClubDialog.dart';

class ClubDetailsPage extends StatefulWidget {
  final Club club;
  final Function(Club) updateClubApproval;

  ClubDetailsPage({required this.club, required this.updateClubApproval});

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  late Club club; // The Club object to display and update

  @override
  void initState() {
    super.initState();
    club = widget.club; // Initialize with the passed Club object
  }


  void _updateClub(Club updatedClub) {
    setState(() {
      club = updatedClub; // Update the UI with the new club details
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Club Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit,color: Colors.white,),
            onPressed: () {
              // Open the EditClubDialog when the edit button is clicked
              showDialog(
                context: context,
                builder: (context) {
                  return EditClubDialog(
                    club: club,
                    updateClub: _updateClub, // Pass the update function
                  );
                },
              );
            },
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
      backgroundColor:  Color(0xfff5f6fa),

    );
  }

  Widget buildMobileView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 16),
          buildModernInfoCard('Club Name', widget.club.clubName!),
          buildModernInfoCard('Address', widget.club.address!),
          buildModernInfoCard('State', widget.club.state!),
          buildModernInfoCard('District', widget.club.district!),
          buildModernInfoCard('Coach Name', widget.club.coachName!),
          buildModernInfoCard('Master Name', widget.club.masterName!),
          buildModernInfoCard('Society Certificate Number', widget.club.aadharNumber!),
          buildModernInfoCard('Contact Number', widget.club.contactNumber!),
          buildModernInfoCard('Email', widget.club.email!),
          buildModernInfoCard('Registration Date', widget.club.regDate!),
          buildModernInfoCard('Approval Status', widget.club.approval!),
          SizedBox(height: 16),
          buildApproveButton(),
        ],
      ),
    );
  }

  Widget buildWebView(BuildContext context, double maxWidth) {
    double aspectRatio = (maxWidth / 300);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: aspectRatio,
              shrinkWrap: true,
              children: <Widget>[
                buildModernInfoCard('Club Name', widget.club.clubName!),
                buildModernInfoCard('Address', widget.club.address!),
                buildModernInfoCard('State', widget.club.state!),
                buildModernInfoCard('District', widget.club.district!),
                buildModernInfoCard('Coach Name', widget.club.coachName!),
                buildModernInfoCard('Master Name', widget.club.masterName!),
                buildModernInfoCard('Society Certificate Number', widget.club.aadharNumber!),
                buildModernInfoCard('Contact Number', widget.club.contactNumber!),
                buildModernInfoCard('Email', widget.club.email!),
                buildModernInfoCard('Registration Date', widget.club.regDate!),
                buildModernInfoCard('Approval Status', widget.club.approval!),
              ],
            ),
            SizedBox(height: 16),
            // buildApproveButton(),
          ],
        ),
      ),
    );
  }

  Widget buildModernInfoCard(String label, String value) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
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
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Approval button with modern design
  Widget buildApproveButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => approveClub(widget.club),
        icon: Icon(Icons.check_circle_outline, color: Colors.white),
        label: Text(
          'Approve Club',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Method to handle club approval
  void approveClub(Club club) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Approval'),
          content: Text('Are you sure you want to approve this club?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed) {
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
        final ref = FirebaseDatabase.instance.ref('clubs/${club.id}');
        await ref.update({'approval': "Approved"});

        Navigator.of(context).pop();

        setState(() {
          widget.club.approval = "Approved";
        });
        widget.updateClubApproval(club);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Club approved successfully.')));
      } catch (error) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve club. Please try again.')));
      }
    }
  }

  void _launchURL(String url) async {
    html.window.open(url, '_blank');
  }
}
