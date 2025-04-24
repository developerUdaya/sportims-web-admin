
import 'dart:html' as html;
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/models/EventParticipantsModel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/EventModel.dart';
import 'Controllers.dart';
import 'Values.dart';

Widget buildEllipseTextContainer(String text, double width){
  return Container(
      width: width,
      child: Text(text ,style: TextStyle(overflow: TextOverflow.ellipsis),
      )
  );
}

Widget buildTitleAndDropdown(String title, String hintText, List<String> items, String? selectedItem, Function(String?) onChanged, {bool enabled = true,}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        decoration: _inputDecoration(hintText),
        value: selectedItem,
        onChanged: enabled ? onChanged : null, // Disable onChanged when enabled is false
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an option';
          }
          return null;
        },
        style: enabled ? null : TextStyle(color: Colors.grey), // Change text color when disabled
        icon: enabled ? null : Icon(Icons.block), // Change icon when disabled
        isDense: true,
        disabledHint: Text(selectedItem ?? '', style: const TextStyle(color: Colors.grey)), // Show hint when disabled
      ),
    ],
  );
}

Widget buildTitleAndField(String title, String hintText, {bool isNumberOnly = false,bool isMultiline = false, required TextEditingController controller, List<TextInputFormatter>? inputFormatters,  bool readOnly=false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        readOnly: readOnly,
        controller: controller,
        decoration: _inputDecoration(hintText),
        maxLines: isMultiline ? 5 : 1,
        inputFormatters: inputFormatters,
        keyboardType: isNumberOnly ? TextInputType.number : TextInputType.text,
        // keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    ],
  );
}

Widget buildNullTitleAndField(String title, String hintText, {bool isMultiline = false, required TextEditingController controller, List<TextInputFormatter>? inputFormatters,  bool readOnly=false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        readOnly: readOnly,
        controller: controller,
        decoration: _inputDecoration(hintText),
        maxLines: isMultiline ? 5 : 1,
        inputFormatters: inputFormatters,
        keyboardType: TextInputType.number,
        validator: null,
      ),
    ],
  );
}

Widget buildFileUploadButton(String title, TextEditingController fileNameController, Function(html.File) onFileSelected) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      const SizedBox(height: 8),
      MaterialButton(
        color: Colors.blue[800],
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Text(title,style: TextStyle(color: Colors.white,),),
              Icon(Icons.upload_file,color: Colors.white,)
            ],
          ),
        ),
        onPressed: () async {
          if (kIsWeb) {
            final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
            uploadInput.accept = '.pdf,.doc,.docx,.png,.jpg,.jpeg';
            uploadInput.click();

            uploadInput.onChange.listen((e) {
              final files = uploadInput.files!;
              if (files.isNotEmpty) {
                onFileSelected(files[0]);
                fileNameController.text = files[0].name;
              }
            });
          }
        },
      ),
      SizedBox(
        width: 250,
        height: 20,
        child: TextFormField(
          style: const TextStyle(fontSize: 10,overflow: TextOverflow.ellipsis),
          controller: fileNameController,
          readOnly: true,
          decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please upload the file';
            }
            return null;
          },
        ),
      ),
    ],
  );
}

Widget buildPhotoUploadButton(String title, TextEditingController fileNameController, Function(html.File) onFileSelected) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
      const SizedBox(height: 8),
      MaterialButton(
        color: Colors.blue[800],
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Text(title,style: TextStyle(color: Colors.white,),),
              Icon(Icons.upload_file,color: Colors.white,)
            ],
          ),
        ),
        onPressed: () async {
          if (kIsWeb) {
            final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
            uploadInput.accept = '.png,.jpg,.jpeg';
            uploadInput.click();

            uploadInput.onChange.listen((e) {
              final files = uploadInput.files!;
              if (files.isNotEmpty) {
                onFileSelected(files[0]);
                fileNameController.text = files[0].name;
              }
            });
          }
        },
      ),
      SizedBox(
        width: 250,
        height: 20,
        child: TextFormField(
          style: const TextStyle(fontSize: 10,overflow: TextOverflow.ellipsis),
          controller: fileNameController,
          readOnly: true,
          decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please upload the file';
            }
            return null;
          },
        ),
      ),
    ],
  );
}

Widget buildColumnWithFields(List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: children,
  );
}

InputDecoration _inputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Colors.grey),
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    contentPadding:
    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
  );
}

Widget buildEventCard(Map<String, dynamic> event) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          height: 150,
          width: 200,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chest no : ${event['chestNumber']??''}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Text(
                event['raceCategory']??'',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                event['skaterCategory'],
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  // decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event['place']??'',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      event['eventDate']??'',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  event['eventName']??'',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: 1,
                  backgroundColor: Colors.grey.shade300,
                  color: primaryColor,
                ),
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                        Uri uri = Uri.parse(event['certificateUrl']);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication,);
                        } else {
                          print('Could not launch ${event['certificateUrl']}');
                        }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'View Certificate',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget GlassmorphismCalendarCard(EventModel event) {
  Map<String,String> eventDate = getDayMonthYear(event.eventDate.toString());
  Map<String, String> regCloseDate = getDayMonthYear(event.eventDate.toString());
  return Container(
    child: Center(
      child: Container(
        height: 120,
        width: 600,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.2), Colors.blue.withOpacity(0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            // Blurred background effect
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Day Text
                    Container(
                      width: 80,

                      padding: EdgeInsets.only(left:2,right:2,top: 2,bottom: 1),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15),)
                      ),
                      child: Center(
                        child: Text(
                          eventDate['month']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w600,

                          ),
                        ),
                      ),
                    ),
                    // Date Text
                    Container(
                      width: 80,
                      padding: EdgeInsets.only(left:2,right:2,bottom: 2,top: 1),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),)
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              eventDate['day']!,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              eventDate['dayOfWeek']!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),
                    // Colored Circle Decorations
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Color(0xFFFF6A55), // Red circle
                        ),
                        SizedBox(width: 12),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Color(0xFFFFC93C), // Yellow circle
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Separate title fields for "Glassmorphism" and "Calendar Card"
            Positioned(
              right: 20,
              bottom: 90,
              child: Text(
                event.eventName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.withOpacity(0.6),
                  fontWeight: FontWeight.bold,

                ),
                textAlign: TextAlign.right,
              ),
            ),
            Positioned(
              right: 20,
              bottom: 70,
              child: Text(
                'Venue : ${event.place}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            // Additional description text
            Positioned(
              right: 20,
              bottom: 30,
              child: Text(
                'Registration Deadline : ${regCloseDate['day']} ${regCloseDate['month']}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget GlassmorphismCalendarEventCard(EventModel event, EventParticipantsModel participant) {
  Map<String,String> eventDate = getDayMonthYear(event.eventDate.toString());
  Map<String, String> regCloseDate = getDayMonthYear(event.eventDate.toString());

  return Container(
    child: Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.2), Colors.blue.withOpacity(0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            // Blurred background effect
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Day Text
                    Container(
                      width: 80,

                      padding: EdgeInsets.only(left:2,right:2,top: 2,bottom: 1),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15),)
                      ),
                      child: Center(
                        child: Text(
                          eventDate['month']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w600,

                          ),
                        ),
                      ),
                    ),
                    // Date Text
                    Container(
                      width: 80,
                      padding: EdgeInsets.only(left:2,right:2,bottom: 2,top: 1),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15),)
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              eventDate['day']!,
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              eventDate['year']!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Colored Circle Decorations
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Color(0xFFFF6A55), // Red circle
                            ),
                            SizedBox(width: 12),
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Color(0xFFFFC93C), // Yellow circle
                            ),
                          ],
                        ),
                        TextButton(onPressed: () async {

                          String url = "http://103.174.10.153:8000/certificates/${event.id}/certificate_${participant.chestNumber}_${participant.skaterId}_${event.id}.png";
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }

                        }, child: Text('View Certificate', style: TextStyle(color: Colors.blue),)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            // Separate title fields for "Glassmorphism" and "Calendar Card"
            Positioned(

              right: 20,
              bottom: 100,
              child: Text(
                event.eventName,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.bold,

                ),
                textAlign: TextAlign.right,
              ),
            ),
            Positioned(
              right: 20,
              bottom: 80,
              child: Text(
                'Chest No : ${participant.chestNumber}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            // Additional description text
            Positioned(
              right: 20,
              bottom: 50,
              child: Text(
                'Race : ${participant.raceCategory.join(', ')}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class LoginTextField extends StatefulWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;

  const LoginTextField({
    required this.label,
    this.obscureText = false,
    this.controller,
  });

  @override
  _LoginTextFieldState createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _obscureText,
      controller: widget.controller,
      cursorColor: Colors.grey,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
      ),
    );
  }
}


