import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:html' as html;

import '../models/DistrictSecretaryModel.dart';
import '../utils/Colors.dart';
import '../utils/MessageHelper.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String imgUrl = widget.districtSecretary.docUrl.toLowerCase();
    if(imgUrl.contains("png")||imgUrl.contains("jpg")||imgUrl.contains("jpeg")){
      isImgDoc = true;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DistrictSecretary Details'),
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

          SizedBox(height: 16),
          buildDistrictSecretaryInfoListTile('Name', widget.districtSecretary.name),
          buildDistrictSecretaryInfoListTile('Address', widget.districtSecretary.address),
          buildDistrictSecretaryInfoListTile('State', widget.districtSecretary.stateName),
          buildDistrictSecretaryInfoListTile('District', widget.districtSecretary.districtName),
          buildDistrictSecretaryInfoListTile('Email', widget.districtSecretary.email),
          buildDistrictSecretaryInfoListTile('Contact Number', widget.districtSecretary.contactNumber),
          buildDistrictSecretaryInfoListTile('Registration Date', widget.districtSecretary.regDate),
          buildDistrictSecretaryInfoListTile('Approval', widget.districtSecretary.approval),
          SizedBox(height: 16),
          if(isImgDoc)Text("Adhaar Document"),
          if(isImgDoc)Container(
            height: 300,
            child: Image.network(widget.districtSecretary.docUrl),
          ),
          if(isImgDoc)SizedBox(height: 16),
          Center(
            child: Row(
              children: [
                if (widget.districtSecretary.approval != "Approved")
                  ElevatedButton(
                    onPressed: () {
                      // Handle button press, e.g., navigate to document
                      approveDistrictSecretary(widget.districtSecretary);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue, // Background color
                    ),
                    child: Text('Approve District Secretary'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    // Handle button press, e.g., navigate to document
                    _showDialog(context, widget.districtSecretary.docUrl);
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

            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: aspectRatio,
              shrinkWrap: true,
              children: <Widget>[
                buildDistrictSecretaryInfoCard('Name', widget.districtSecretary.name),
                buildDistrictSecretaryInfoCard('Address', widget.districtSecretary.address),
                buildDistrictSecretaryInfoCard('State', widget.districtSecretary.stateName),
                buildDistrictSecretaryInfoCard('District', widget.districtSecretary.districtName),
                buildDistrictSecretaryInfoCard('Email', widget.districtSecretary.email),
                buildDistrictSecretaryInfoCard('Contact Number', widget.districtSecretary.contactNumber),
                buildDistrictSecretaryInfoCard('Registration Date', widget.districtSecretary.regDate),
                buildDistrictSecretaryInfoCard('Approval', widget.districtSecretary.approval),
              ],
            ),
            SizedBox(height: 16),
            if(isImgDoc)Text("Adhaar Document"),
            if(isImgDoc)Container(
              height: 300,
              child: Image.network(widget.districtSecretary.docUrl),
            ),
            if(isImgDoc)SizedBox(height: 16),
            Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.districtSecretary.approval != "Approved")
                      ElevatedButton(
                        onPressed: () {
                          // Handle button press, e.g., navigate to document
                          approveDistrictSecretary(widget.districtSecretary);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue, // Background color
                        ),
                        child: Text('Approve District Secretary'),
                      ),
                    if (widget.districtSecretary.approval != "Approved")
                      SizedBox(width: 20,),
                    ElevatedButton(
                      onPressed: () {
                        // Handle button press, e.g., navigate to document
                        _showDialog(context, widget.districtSecretary.docUrl);
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

  Widget buildDistrictSecretaryInfoCard(String label, String value) {
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

  Widget buildDistrictSecretaryInfoListTile(String label, String value) {
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

  void approveDistrictSecretary(DistrictSecretaryModel districtSecretary) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Approval'),
          content: Text('Are you sure you want to approve this districtSecretary?'),
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
        // Update the districtSecretary's approval status
        final ref = FirebaseDatabase.instance.ref('districtSecretaries/${districtSecretary.id}');
        await ref.update({'approval': "Approved"});

        // Close the loading indicator
        Navigator.of(context).pop();

        setState(() {
          widget.districtSecretary.approval = "Approved";


        });
        widget.updateDistrictSecretaryApproval(districtSecretary);

        sendRegistrationApproved(name: districtSecretary.name!, role: 'District Secretary User', companyName: 'Sport-IMS', phoneNumber: districtSecretary.contactNumber!, email: districtSecretary.email!);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('DistrictSecretary approved successfully.'))
        );
      } catch (error) {
        // Close the loading indicator
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve districtSecretary. Please try again.'))
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
