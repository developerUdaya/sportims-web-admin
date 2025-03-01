import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(MaterialApp(
    home: CertificateTemplatePage(),
  ));
}

class CertificateTemplatePage extends StatefulWidget {
  @override
  _CertificateTemplatePageState createState() =>
      _CertificateTemplatePageState();
}

class _CertificateTemplatePageState extends State<CertificateTemplatePage> {
  List<Map<String, dynamic>> textFields = [];
  String? imageUrl;
  final GlobalKey _boundaryKey = GlobalKey();
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Certificate Template Builder")),
      body: Row(
        children: [
          Expanded(
            child: Container(
              key: _boundaryKey,
              padding: EdgeInsets.all(20),
              child: Stack(
                children: [
                  if (imageUrl != null)
                    Positioned.fill(
                      child: Image.network(imageUrl!, fit: BoxFit.contain),
                    ),
                  for (var textField in textFields)
                    Positioned(
                      left: textField['x'],
                      top: textField['y'],
                      child: Draggable(
                        data: textField,
                        feedback: Material(
                          child: Text(
                            textField['text'],
                            style: TextStyle(
                              fontSize: textField['fontSize'],
                              color: Color(textField['color']),
                            ),
                          ),
                        ),
                        childWhenDragging: Container(),
                        child: GestureDetector(
                          onTap: () => editTextField(textField),
                          child: Text(
                            textField['text'],
                            style: TextStyle(
                              fontSize: textField['fontSize'],
                              color: Color(textField['color']),
                            ),
                          ),
                        ),
                        onDragEnd: (details) {
                          _updateTextFieldPosition(details, textField);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          buildControlPanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveTemplate,
        child: Icon(Icons.save),
      ),
    );
  }

  // Control Panel Widget
  Widget buildControlPanel() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: selectBackgroundImage,
            child: Text("Upload Background Image"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: addTextField,
            child: Text("Add Text Field"),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => generateCertificate(
              certificateId: "-O8OPPBoJVTtbXi2BWNL",
              playerId: "test_player_id",
              profileImageUrl: "https://images.squarespace-cdn.com/content/v1/60f1a490a90ed8713c41c36c/1629223610791-LCBJG5451DRKX4WOB4SP/37-design-powers-url-structure.jpeg", // Replace with actual profile image URL
            ),
            child: Text("Generate Certificate"),
          ),
        ],
      ),
    );
  }

  // Select and upload background image
  void selectBackgroundImage() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);

      reader.onLoadEnd.listen((e) async {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("certificate_backgrounds/${file.name}");
        await storageRef.putBlob(file);
        String downloadUrl = await storageRef.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });
      });
    });
  }

  // Add new text field
  void addTextField() {
    setState(() {
      textFields.add({
        'x': 100.0,
        'y': 100.0,
        'text': 'New Text',
        'fontSize': 20.0,
        'color': Colors.black.value,
      });
    });
  }

  // Edit text field properties
  void editTextField(Map<String, dynamic> textField) async {
    TextEditingController controller = TextEditingController(text: textField['text']);
    double fontSize = textField['fontSize'];
    Color color = Color(textField['color']);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Text Field"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLines: null, // Enable multiline editing
              decoration: InputDecoration(
                hintText: "Enter text here (Use \\n for new lines)",
              ),
            ),
            Slider(
              value: fontSize,
              min: 10,
              max: 100,
              divisions: 90,
              label: fontSize.toString(),
              onChanged: (value) {
                setState(() {
                  fontSize = value; // Update the value and set state to reflect the change
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                Color? selectedColor = await pickColor(context, color);
                if (selectedColor != null) {
                  setState(() {
                    color = selectedColor;
                  });
                }
              },
              child: Text("Select Color"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              textField['text'] = controller.text; // Save edited text with \n support
              textField['fontSize'] = fontSize;
              textField['color'] = color.value;
              setState(() {});
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  // Function to pick a color using a dialog
  Future<Color?> pickColor(BuildContext context, Color currentColor) async {
    Color tempColor = currentColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (Color color) {
              tempColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(tempColor),
            child: Text("Select"),
          ),
        ],
      ),
    );

    return tempColor;
  }

  // Save template to Firebase
  void saveTemplate() async {
    // Ensure the text fields are saved with new line characters preserved
    final DatabaseReference ref = database.child("certificate_templates").push();
    await ref.set({
      'imageUrl': imageUrl,
      'textFields': textFields.map((field) {
        field['text'] = field['text'].replaceAll('\n', '\\n'); // Preserve line breaks as \\n
        return field;
      }).toList(),
    });
  }

  // Update text field position after dragging
  void _updateTextFieldPosition(DraggableDetails details, Map<String, dynamic> textField) {
    // Adjust coordinates based on boundary
    final RenderBox box = _boundaryKey.currentContext?.findRenderObject() as RenderBox;
    if (box != null) {
      Offset localOffset = box.globalToLocal(details.offset);
      setState(() {
        textField['x'] = localOffset.dx;
        textField['y'] = localOffset.dy;
      });
    }
  }

  // Generate and display certificate as a PDF with multiline support and QR code
  Future<void> generateCertificate({
    required String playerId,
    required String certificateId,
    required String profileImageUrl,
  }) async {
    // Extract data from Firebase
    final DatabaseReference ref = database.child("certificate_templates/$certificateId");
    final DataSnapshot snapshot = await ref.get();
    final Map<String, dynamic> snapshotValue = Map<String, dynamic>.from(snapshot.value as Map);

    final String imageUrl = snapshotValue['imageUrl'];
    final List<Map<String, dynamic>> textFields = List<Map<String, dynamic>>.from(
      (snapshotValue['textFields'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );

    // Fetch the background image
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }
    final Uint8List imageData = response.bodyBytes;

    // Create PDF
    final pdf = pw.Document();
    final image = pw.MemoryImage(imageData);

    // Profile image if provided
    pw.Widget? profileWidget;
    if (profileImageUrl.isNotEmpty) {
      final profileResponse = await http.get(Uri.parse(profileImageUrl));
      if (profileResponse.statusCode == 200) {
        final profileImageData = profileResponse.bodyBytes;
        final profileImage = pw.MemoryImage(profileImageData);
        profileWidget = pw.Positioned(
          top: 20,
          right: 20,
          child: pw.Image(profileImage, width: 100, height: 100),
        );
      }
    }

    // Calculate the Firebase Storage URL where the PDF will be stored
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('certificates/$certificateId.pdf');
    String certurl = "https://firebasestorage.googleapis.com/v0/b/sportimsweb.appspot.com/o/certificates%2F$certificateId.pdf?alt=media";
    // https://firebasestorage.googleapis.com/v0/b/sportimsweb.appspot.com/o/certificates%2F-O8OPPBoJVTtbXi2BWNL.pdf?alt=media&token=91226c91-bcae-49d3-a1a3-7dc6621463b6
    // Generate QR code for the URL
    // final qrCode = img.Image(200, 200);
    print(certurl);
    final qrPainter = QrPainter(
      data: certurl,
      version: QrVersions.auto,
      gapless: true,
    );
    final qrByteData = await qrPainter.toImageData(200);
    final qrBytes = qrByteData!.buffer.asUint8List();
    final qrImage = pw.MemoryImage(qrBytes);

    // Add content to PDF
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Stack(
            children: [
              pw.Image(image, fit: pw.BoxFit.cover),
              for (var field in textFields)
                pw.Positioned(
                  left: field['x'],
                  top: field['y'],
                  child: pw.Text(
                    field['text'].replaceAll('\\n', '\n'), // Use \\n stored in Firebase as \n
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(field['color']),
                      fontSize: field['fontSize'],
                    ),
                  ),
                ),
              if (profileWidget != null) profileWidget,
              pw.Positioned(
                bottom: 20,
                left: context.page.pageFormat.width / 2 ,
                child: pw.Image(qrImage, width: 100, height: 100),
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF to bytes
    final Uint8List pdfBytes = await pdf.save();

    // Upload the PDF to Firebase Storage
    await storageRef.putData(pdfBytes);
    final String firebasePdfUrl = await storageRef.getDownloadURL();

    print(firebasePdfUrl);

    final DatabaseReference userref = database.child("certificate/");
    await userref.push().set({"sertUrl":firebasePdfUrl});
    // Open the PDF in a new browser tab
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, "_blank");
    html.Url.revokeObjectUrl(url);  // Clean up after opening the tab
  }

}
