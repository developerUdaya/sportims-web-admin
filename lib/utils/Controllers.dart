import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import '../models/EventModel.dart';
import '../models/UsersModel.dart';
import 'Constants.dart';
import 'dart:html' as html;

Future<String> uploadFileToStorage(String path, String fileName, {bool isWeb = false, html.File? webFile}) async {
  try {
    if (isWeb && webFile != null) {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(webFile);
      await reader.onLoad.first;

      final storageRef = FirebaseStorage.instance.ref('clubs/${DateTime.now().toString() + fileName}');
      final snapshot = await storageRef.putBlob(webFile);
      return await snapshot.ref.getDownloadURL();
    } else {
      return '';
    }
  } catch (e) {
    return '';
  }
}

Future<String> generateSkaterID(String state,String district) async {
  final database = FirebaseDatabase.instance;
  final ref = database.ref().child('skaters');
  final snapshot = await ref.get();

  int userCount = snapshot.children.length;
  String stateCode = Constants().getStateCode(state.toString());
  String districtCode = Constants().getDistrictCode(district.toString());
  String uniqueId = (userCount + 1).toString().padLeft(4, '0');  // Pads the ID to 5 digits

  return '$stateCode$districtCode$uniqueId';
}
Future<String> generateEventParticipantsID(String eventID) async {
  final database = FirebaseDatabase.instance;
  final ref = database.ref().child('events/pastEvents/$eventID/eventParticipants/');
  final snapshot = await ref.get();

  int userCount = snapshot.children.length;

  return 'EVNTREG${userCount+1}';
}
Future<String> generatePaymentID() async {
  final database = FirebaseDatabase.instance;
  final ref = database.ref().child('paymentReports');
  final snapshot = await ref.get();

  int userCount = snapshot.children.length;

  return '${userCount+1}';
}

Future<String> generateClubID(String state,String district) async {
  final database = FirebaseDatabase.instance;
  final ref = database.ref().child('clubs');
  final snapshot = await ref.get();

  int userCount = snapshot.children.length;
  String stateCode = Constants().getStateCode(state.toString());
  String districtCode = Constants().getDistrictCode(district.toString());
  String uniqueId = (userCount + 1).toString().padLeft(4, '0');  // Pads the ID to 5 digits

  return '${stateCode}C$districtCode$uniqueId';
}

Future<String> generateDistrictSecretaryID(String state,String district) async {
  final database = FirebaseDatabase.instance;
  final ref = database.ref().child('districtSecretaries');
  final snapshot = await ref.get();

  int userCount = snapshot.children.length;
  String stateCode = Constants().getStateCode(state.toString());
  String districtCode = Constants().getDistrictCode(district.toString());
  String uniqueId = (userCount + 1).toString().padLeft(4, '0');  // Pads the ID to 5 digits

  return '$stateCode${districtCode}D$uniqueId';
}

String? getUserMobileNumber() {
  // Get the current logged-in user
  User? user = FirebaseAuth.instance.currentUser;

  // Check if the user exists and has a phone number
  if (user != null && user.phoneNumber != null) {
    // Get the phone number and extract the last 10 digits
    String phoneNumber = user.phoneNumber!;
    return phoneNumber.length >= 10
        ? phoneNumber.substring(phoneNumber.length - 10)
        : phoneNumber; // Fallback in case the phone number is less than 10 digits
  }

  // Return null if no user is logged in or no phone number is available
  return null;
}
Future<bool> checkUsernameExists(String username) async {
  final ref = FirebaseDatabase.instance.ref('users');

  // 1. Efficient Query:
  final query = ref.orderByKey().equalTo(username).limitToFirst(1);

  // 2. Asynchronous Snapshot:
  final snapshot = await query.get();

  // 3. Data Extraction (null check):
  final exists = snapshot.value != null ? (snapshot.value as Map).isNotEmpty : false;


  return exists;
}

Future<List<Users>> getAllSkaters() async {
  // Show loading dialog
  List<Users> users = [];
  final database = FirebaseDatabase.instance;
  final ref = database.ref().child('skaters');
  // Fetch the data once using a single await call
  DataSnapshot snapshot = await ref.get();

  if (snapshot.exists) {
    for (final child in snapshot.children) {
      // Convert each child snapshot to a Club object
      Users user;
      try {
        user = Users.fromJson(Map<String, dynamic>.from(child.value as Map));
        users.add(user);
        print(user.name);
      }catch(e){
        print(e);
      }
    }
  } else {
    print('No data available.');
  }

  return users;
}

Future<List<EventModel>> getEventModels() async {
  List<EventModel> events = [];
  final ref = FirebaseDatabase.instance.ref().child('events/pastEvents');
  DataSnapshot snapshot = await ref.get();

  if (snapshot.exists) {
    for (final child in snapshot.children) {
      EventModel event = EventModel.fromJson(Map<String, dynamic>.from(child.value as Map));
      if(!event.deleteStatus) {
        events.add(event);
      }
    }
  }
  return events;
}


bool isValidEmail(String email) {
  // Regular expression for validating an Email
  RegExp regex = RegExp(
    r'^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})$',
    caseSensitive: false,
    multiLine: false,
  );
  return regex.hasMatch(email);
}

String formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) {
    return '';
  }

  DateTime? parsedDate;

  // List of known formats that you want to support
  List<String> formats = [
    'yyyy-MM-ddTHH:mm:ss.SSSZ', // ISO 8601 with milliseconds
    'yyyy-MM-ddTHH:mm:ssZ',     // ISO 8601 without milliseconds
    'yyyy-MM-dd HH:mm:ss.SSS',  // Date with time and milliseconds
    'yyyy-MM-dd HH:mm:ss',      // Date with time
    'yyyy-MM-dd',               // Simple date
    'MM/dd/yyyy',               // US date format
    'dd/MM/yyyy',               // European date format
    'dd-MM-yyyy',               // Standard date format (as target)
    'dd MMM yyyy',              // 12 Dec 2023 format
  ];

  for (var format in formats) {
    try {
      // Try parsing the date with the current format
      var dateFormat = DateFormat(format);
      parsedDate = dateFormat.parse(dateStr);
      break;
    } catch (e) {
      // Continue if this format fails
      continue;
    }
  }

  if (parsedDate == null) {
    // If parsing failed for all formats, return empty string
    return '';
  }

  // Format the parsed date to 'dd-MM-yyyy'
  return DateFormat('dd-MM-yyyy').format(parsedDate);
}


DateTime? parseDate(String dateString, List<String> formats) {
  for (String format in formats) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      // Ignore the exception and continue to the next format
    }
  }
  throw FormatException("Date format not supported: $dateString");
}

int calculateAge(String dobString, DateTime referenceDate) {
  // Define supported date formats
  print('dobString: $dobString referenceDate: ${referenceDate.toString()}');
  List<String> formats = [
    'dd-MM-yyyy',
    'yyyy-MM-ddTHH:mm:ss.SSSZ',
    'yyyy-MM-ddTHH:mm:ssZ',
    'yyyy-MM-dd HH:mm:ss.SSS',
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd',
    'MM/dd/yyyy',
    'dd/MM/yyyy',
    'dd MMM yyyy',
  ];

  // Parse dobString using parseDate function
  DateTime dob = parseDate(dobString, formats)!;
  print('dob:$dob');

  print('referenceDate.year:${referenceDate.year} - dob.year:${dob.year}');

  // Calculate age
  int age = referenceDate.year - dob.year;

  // Adjust if the birthday hasn't occurred yet this year
  if (referenceDate.month < dob.month ||
      (referenceDate.month == dob.month && referenceDate.day < dob.day)) {
    age--;
  }

  print('Calculated age: $age');
  return age;
}
// Method to calculate age in years, months, and days
String calculateAgeInDetail(String dob, String ageAsOn) {
  // Define the date format to match the input strings
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  // Parse the date of birth and ageAsOn dates
  DateTime dobDate = dateFormat.parse(dob);
  DateTime ageAsOnDate = dateFormat.parse(ageAsOn);

  // Calculate years difference
  int years = ageAsOnDate.year - dobDate.year;

  // Calculate months difference
  int months = ageAsOnDate.month - dobDate.month;

  // If months is negative, adjust the years and months
  if (months < 0) {
    years--;
    months += 12;
  }

  // Calculate days difference
  int days = ageAsOnDate.day - dobDate.day;

  // If days is negative, adjust the months and days
  if (days < 0) {
    months--;
    DateTime previousMonth = DateTime(ageAsOnDate.year, ageAsOnDate.month - 1, 1);
    days += DateTime(ageAsOnDate.year, ageAsOnDate.month, 0).day;
  }

  return '$years years, $months months, $days days';
}


bool isValidPhoneNumber(String phoneNumber) {
  final phoneRegex = RegExp(r'^\d{10}$');
  return phoneRegex.hasMatch(phoneNumber);
}

Map<String, String> getDayMonthYear(String dateString) {
  // Define a DateFormat that can parse various date formats
  DateTime parsedDate;

  try {
    // Attempt to parse the date string to DateTime object
    parsedDate = DateTime.parse(dateString);
  } catch (e) {
    // If parsing fails, throw an exception
    throw FormatException("Invalid date format: $dateString");
  }

  // Use DateFormat to format the parsed date
  String dayOfWeek = DateFormat('EEEE').format(parsedDate); // Full day name, e.g., Sunday
  String day = DateFormat('d').format(parsedDate); // Day number, e.g., 28
  String month = DateFormat('MMMM').format(parsedDate); // Full month name, e.g., March
  String year = parsedDate.year.toString(); // Year name, e.g., 2023

  return {
    'dayOfWeek': dayOfWeek,
    'day': day,
    'month': month,
    'year':year
  };
}
Future<void> launchURL(String url) async {
  html.window.open(url, '_blank');
}

