import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aadhaar Verification',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AadhaarVerificationScreen(),
    );
  }
}

class AadhaarVerificationScreen extends StatefulWidget {
  @override
  _AadhaarVerificationScreenState createState() => _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? referenceId;
  bool isOtpSent = false;

  Future<void> sendOtp() async {
    final response = await http.post(
      Uri.parse('http://103.174.10.153:4005/aadhaar/otp/'),
      body: jsonEncode({'aadhaar_number': _aadhaarController.text}),
      headers: {'Content-Type': 'application/json'},
    );

    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(data);
      setState(() {
        referenceId = data['reference_id'].toString();
        isOtpSent = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP')));
    }
  }

  Future<void> verifyOtp() async {
    final response = await http.post(
      Uri.parse('http://103.174.10.153:4005/aadhaar/otp/verify/'),
      body: jsonEncode({'reference_id': referenceId, 'otp': _otpController.text}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];

      print(data);
      await storeInFirebase(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Successful!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP verification failed')));
    }
  }

  Future<void> storeInFirebase(Map<String, dynamic> data) async {
    final dbRef = FirebaseDatabase.instance.ref('skaters/${data['reference_id']}');
    await dbRef.set({
      "aadharBirthCertificateNumber": data['reference_id'],
      "address": data['full_address'],
      "approval": "Approved",
      "bloodGroup": "Unknown",
      "club": "Unknown",
      "contactNumber": "Unknown",
      "dateOfBirth": data['date_of_birth'],
      "district": data['address']['district'],
      "docFileUrl": "https://firebasestorage.googleapis.com/v0/b/yourapp.appspot.com/o/skaters%2F${data['reference_id']}%2Fdocument.pdf?alt=media",
      "email": "Unknown",
      "gender": data['gender'] == "M" ? "Male" : "Female",
      "name": data['name'],
      "profileImageUrl": "data:image/jpeg;base64,${data['photo']}",
      "regDate": DateTime.now().toIso8601String(),
      "school": "Unknown",
      "schoolAffiliationNumber": "Unknown",
      "skateCategory": "Unknown",
      "skaterID": "TNSA${data['reference_id']}",
      "state": data['address']['state'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aadhaar Verification')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _aadhaarController,
              decoration: InputDecoration(labelText: 'Enter Aadhaar Number'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            if (!isOtpSent)
              ElevatedButton(onPressed: sendOtp, child: Text('Send OTP')),
            if (isOtpSent) ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              ElevatedButton(onPressed: verifyOtp, child: Text('Verify OTP')),
            ],
          ],
        ),
      ),
    );
  }
}
