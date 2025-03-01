import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_ims/utils/MessageHelper.dart';
import 'dart:html' as html;

import '../models/ClubsModel.dart';
import '../utils/Colors.dart';

class ClubDetailsPage extends StatefulWidget {
  final Club club;
  final Function(Club) updateClubApproval;

  ClubDetailsPage({required this.club, required this.updateClubApproval});

  @override
  State<ClubDetailsPage> createState() => _ClubDetailsPageState();
}

class _ClubDetailsPageState extends State<ClubDetailsPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Club Details'),
        backgroundColor: AppColors().bluePrimary,
        leading: IconButton(onPressed: () { Navigator.pop(context); },
          icon: Icon(Icons.arrow_back),
        ),
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
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 16),
          buildClubInfoListTile('Club Name', widget.club.clubName!),
          buildClubInfoListTile('Address', widget.club.address!),
          buildClubInfoListTile('State', widget.club!.state!),
          buildClubInfoListTile('District', widget.club.district!),
          buildClubInfoListTile('Coach Name', widget.club.coachName!),
          buildClubInfoListTile('Master Name', widget.club.masterName!),
          buildClubInfoListTile('Contact Number', widget.club.contactNumber!),
          buildClubInfoListTile('Email', widget.club.email!),
          buildClubInfoListTile('Registration Date', widget.club.regDate!),
          buildClubInfoListTile('Approval', widget.club.approval!),
          SizedBox(height: 16),
          Center(
            child: Row(
              children: [
                if (widget.club.approval != "Approved")
                  ElevatedButton(
                    onPressed: () {
                      approveClub(widget.club);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                    ),
                    child: Text('Approve Club'),
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
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: aspectRatio,
              shrinkWrap: true,
              children: <Widget>[
                buildClubInfoCard('Club Name', widget.club.clubName!),
                buildClubInfoCard('Address', widget.club.address!),
                buildClubInfoCard('State', widget.club.state!),
                buildClubInfoCard('District', widget.club.district!),
                buildClubInfoCard('Coach Name', widget.club.coachName!),
                buildClubInfoCard('Master Name', widget.club.masterName!),
                buildClubInfoCard('Contact Number', widget.club.contactNumber!),
                buildClubInfoCard('Society Certificate Number', widget.club.aadharNumber!),
                buildClubInfoCard('Email', widget.club.email!),
                buildClubInfoCard('Registration Date', widget.club.regDate!),
                buildClubInfoCard('Approval', widget.club.approval!),
              ],
            ),
            SizedBox(height: 16),
            Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.club.approval != "Approved")
                      ElevatedButton(
                        onPressed: () {
                          approveClub(widget.club);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                        ),
                        child: Text('Approve Club'),
                      )
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

  Widget buildClubInfoCard(String label, String value) {
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

  Widget buildClubInfoListTile(String label, String value) {
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
        sendRegistrationApproved(name: club.clubName!, role: 'Club User', companyName: 'Sport-IMS', phoneNumber: club.contactNumber!, email: club.email!);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Club approved successfully.'))
        );
      } catch (error) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve club. Please try again.'))
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
