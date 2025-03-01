
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:sport_ims/loginApp/LoginApp.dart';
import 'package:sport_ims/utils/Controllers.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/EventParticipantsModel.dart';
import '../models/EventModel.dart';
import '../models/EventModel.dart';
import '../models/EventParticipantsModel.dart';



class EventParticipantDetailsPage extends StatelessWidget {
  final EventParticipantsModel participant;
  final EventModel eventModel;

  EventParticipantDetailsPage({required this.participant, required this.eventModel});

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Participant Details',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          AnimatedButton(
            onTap: (){
              generateAndDownloadPDF(participant,eventModel);
            }, label: 'Download', icon: null, buttonColor: Colors.red,textColor: Colors.white,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Card Section
              profileCard(),
              SizedBox(height: 16),

              Row(

                children: [
                  // Event Information Card
                  Expanded(
                    child: eventCard(),
                  ),

                  SizedBox(width: 16), // Add some spacing between the cards

                  // Race Categories
                  Expanded(
                    child: racesCard(),
                  ),
                ],
              ),


              SizedBox(height: 24),

              // Payment Information
              paymentCard(),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Card UI
  Widget profileCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Image
          CircleAvatar(
            radius: 50,
            backgroundImage: participant.imgUrl.isNotEmpty
                ? NetworkImage(participant.imgUrl)
                : AssetImage('assets/default_profile.png') as ImageProvider,
          ),
          SizedBox(height: 16),

          // Participant Information
          Text(
            participant.name,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            participant.skaterId, // Placeholder for contact number
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Text(
            participant.dob,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          Text(
            participant.club,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),

          // SMS Activation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${participant.district}, ${participant.state}',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                radius: 6,
                backgroundColor: Colors.green,
              ),
            ],
          ),

          // Save Button with Gradient
          SizedBox(height: 16),
          Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.pink],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'Chest No : ${participant.chestNumber}',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Event Card UI
  Widget eventCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          detailRow('Event Name', participant.eventName),
          detailRow('Event Place', eventModel.place),
          detailRow('Event Date', formatDate(eventModel.eventDate.toString())),
        ],
      ),
    );
  }

  // Race Card UI
  Widget racesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Races Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          for (String race in participant.raceCategory)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                race,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  // Payment Card UI
  Widget paymentCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          detailRow('Payment Status', participant.paymentStatus),
          detailRow('Payment Amount', participant.paymentAmount),
          detailRow('Payment ID', participant.paymentId),
          detailRow('Payment Order ID', participant.paymentOrderId),
          detailRow('Payment Mode', participant.paymentMode),
        ],
      ),
    );
  }

  // Helper method for details row
  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
          ),
          Text(
            value.isNotEmpty ? value : 'N/A',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }




// Method to generate and download PDF with header, footer, logo, and professional styles
  Future<void> generateAndDownloadPDF(EventParticipantsModel participant, EventModel eventModel) async {
    final pdf = pw.Document();

    // Add content to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(eventModel),

            pw.SizedBox(height: 20),

            // Participant and Event Details
            pw.Text(
              'Participant & Event Details',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
            ),
            pw.Divider(color: PdfColors.blue900),

            // Participant Information
            buildDetailSection('Participant Name', participant.name),
            buildDetailSection('Chest Number', participant.chestNumber),
            buildDetailSection('Skater ID', participant.skaterId),
            buildDetailSection('Club', participant.club),
            buildDetailSection('Date of Birth', participant.dob),
            buildDetailSection('District & State', '${participant.district}, ${participant.state}'),

            pw.SizedBox(height: 16),

            // Event Information
            pw.Text(
              'Event Information',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700),
            ),
            pw.SizedBox(height: 8),
            buildDetailSection('Event Name', eventModel.eventName),
            buildDetailSection('Event Place', eventModel.place),
            buildDetailSection('Event Date', eventModel.eventDate.toIso8601String()),

            pw.SizedBox(height: 16),

            // Races Information
            pw.Text(
              'Races Participated',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700),
            ),
            pw.SizedBox(height: 8),
            for (String race in participant.raceCategory)
              pw.Padding(
                padding: pw.EdgeInsets.only(bottom: 4),
                child: pw.Text('- $race', style: pw.TextStyle(fontSize: 14, color: PdfColors.black)),
              ),

            pw.SizedBox(height: 16),

            // Payment Information
            pw.Text(
              'Payment Information',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700),
            ),
            pw.SizedBox(height: 8),
            buildDetailSection('Payment Status', participant.paymentStatus),
            buildDetailSection('Payment Amount', participant.paymentAmount),
            buildDetailSection('Payment Mode', participant.paymentMode),

            pw.SizedBox(height: 20),

            // Terms & Conditions
            pw.Text(
              'Terms & Conditions',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red900),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '1. Participants must comply with all event regulations and rules.\n'
                  '2. The organizer holds no liability for injuries caused during the event.\n'
                  '3. The participant should ensure the accuracy of the details submitted.\n'
                  '4. Any misrepresentation of details may result in disqualification.',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
            ),
          ];
        },
        footer: (pw.Context context) => _buildFooter(context),
      ),
    );

    // Print or share the PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

// Header with Logo, Title, and Date
  pw.Widget _buildHeader(EventModel eventModel)  {
    return pw.Container(
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
        // Event or Company Logo (replace with actual image)
    pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
    pw.Text(
    'Event Participant Details',
    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
    ),
    pw.Text(
    'Generated: ${DateTime.now().toIso8601String()}',
    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
    ),
    ],
    ),
    ],
    ),
    );
  }

// Footer with Page Number and Additional Info
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
      child: pw.Text(
        '',
        style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
      ),
    );
  }

// Helper method to build the details section in PDF
  pw.Widget buildDetailSection(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, color: PdfColors.black)),
        ],
      ),
    );
  }


}
