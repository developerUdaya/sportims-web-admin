import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sport_ims/models/EventOrganiser.dart';
import 'dart:html' as html;

import '../utils/Colors.dart';

class EventOrganiserDetailsPage extends StatefulWidget {
  final EventOrganiser eventOrganiser;
  final Function(EventOrganiser) updateEventOrganiserApproval;


  EventOrganiserDetailsPage({required this.eventOrganiser, required this.updateEventOrganiserApproval});

  @override
  State<EventOrganiserDetailsPage> createState() => _EventOrganiserDetailsPageState();
}

class _EventOrganiserDetailsPageState extends State<EventOrganiserDetailsPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Organiser Details'),
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
      backgroundColor: Colors.white,
    );
  }

  Widget buildMobileView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          SizedBox(height: 16),
          buildEventOrganiserInfoListTile('Name', widget.eventOrganiser.name),
          buildEventOrganiserInfoListTile('User Name', widget.eventOrganiser.userName),
          buildEventOrganiserInfoListTile('Event Id', widget.eventOrganiser.eventId),
        //  buildEventOrganiserInfoListTile('Password', widget.eventOrganiser.password),
          buildEventOrganiserInfoListTile('Event Name', widget.eventOrganiser.eventName),
          buildEventOrganiserInfoListTile('Approval', widget.eventOrganiser.approval),
          SizedBox(height: 16),
          Center(
            child: Row(
              children: [
                if (widget.eventOrganiser.approval != "Approved")
                  ElevatedButton(
                    onPressed: () {
                      // Handle button press, e.g., navigate to document
                      approveEventOrganiser(widget.eventOrganiser);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue, // Background color
                    ),
                    child: Text('Approve Event Organiser',style: TextStyle(color: Colors.white),),
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
                buildEventOrganiserInfoCard('Name', widget.eventOrganiser.name),
                buildEventOrganiserInfoCard('User Name', widget.eventOrganiser.userName),
                buildEventOrganiserInfoCard('Event Id', widget.eventOrganiser.eventId),
                //buildEventOrganiserInfoCard('Password', widget.eventOrganiser.password),
                buildEventOrganiserInfoCard('Event Name', widget.eventOrganiser.eventName),
                buildEventOrganiserInfoCard('Approval', widget.eventOrganiser.approval),
              ],
            ),
            SizedBox(height: 16),
            Container(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.eventOrganiser.approval != "Approved")
                      ElevatedButton(
                        onPressed: () {
                          // Handle button press, e.g., navigate to document
                          approveEventOrganiser(widget.eventOrganiser);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue, // Background color
                        ),
                        child: Text('Approve Event Organiser',style: TextStyle(color: Colors.white),),
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

  Widget buildEventOrganiserInfoCard(String label, String value) {
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

  Widget buildEventOrganiserInfoListTile(String label, String value) {
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

  void approveEventOrganiser(EventOrganiser eventOrganiser) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Approval'),
          content: Text('Are you sure you want to approve this eventOrganiser?'),
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
        // Update the eventOrganiser's approval status
        final ref = FirebaseDatabase.instance.ref('eventOrganisers/${eventOrganiser.id}');
        await ref.update({'approval': "Approved"});

        // Close the loading indicator
        Navigator.of(context).pop();

        setState(() {
          widget.eventOrganiser.approval = "Approved";


        });
        widget.updateEventOrganiserApproval(eventOrganiser);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('EventOrganiser approved successfully.'))
        );
      } catch (error) {
        // Close the loading indicator
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to approve eventOrganiser. Please try again.'))
        );
      }
    }
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
