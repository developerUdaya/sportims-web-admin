// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart'; // Add this import for PdfPageFormat
//
// void main() {
//   runApp(CertificateBuilderApp());
// }
//
// class CertificateBuilderApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CertificateBuilderScreen(),
//     );
//   }
// }
//
// class CertificateBuilderScreen extends StatefulWidget {
//   @override
//   _CertificateBuilderScreenState createState() => _CertificateBuilderScreenState();
// }
//
// class _CertificateBuilderScreenState extends State<CertificateBuilderScreen> {
//   Uint8List? _certificateTemplateBytes;
//   List<DraggableDropdown> dropdowns = [];
//   List<DraggableResizableImage> images = [];
//   List<DraggableResizableTextField> textFields = [];
//
//   void _pickCertificateTemplate() async {
//     var result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null) {
//       setState(() {
//         _certificateTemplateBytes = result.files.single.bytes;
//       });
//     }
//   }
//
//   void _addDropdown() {
//     setState(() {
//       dropdowns.add(DraggableDropdown(
//         key: UniqueKey(),
//         onDelete: (key) => _removeDropdown(key),
//       ));
//     });
//   }
//
//   void _removeDropdown(Key key) {
//     setState(() {
//       dropdowns.removeWhere((element) => element.key == key);
//     });
//   }
//
//   void _addImage() async {
//     var result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result != null) {
//       setState(() {
//         images.add(DraggableResizableImage(
//           key: UniqueKey(),
//           imageBytes: result.files.single.bytes!,
//           onDelete: (key) => _removeImage(key),
//         ));
//       });
//     }
//   }
//
//   void _removeImage(Key key) {
//     setState(() {
//       images.removeWhere((element) => element.key == key);
//     });
//   }
//
//   void _addTextField() {
//     setState(() {
//       textFields.add(DraggableResizableTextField(
//
//         key: UniqueKey(),
//         onDelete: (key) => _removeTextField(key),
//       ));
//     });
//   }
//
//   void _removeTextField(Key key) {
//     setState(() {
//       textFields.removeWhere((element) => element.key == key);
//     });
//   }
//
//
//   Future<void> _saveDataToJson() async {
//     // Create a map to hold the serialized data
//     final data = {
//       'certificateTemplate': _certificateTemplateBytes != null
//           ? base64Encode(_certificateTemplateBytes!) // Store image as Base64 string
//           : null,
//       'dropdowns': dropdowns.map((dropdown) => {
//         'position': {
//           'dx': dropdown.position.dx,
//           'dy': dropdown.position.dy,
//         },
//         'selectedValue': dropdown.selectedValue,
//       }).toList(),
//       'images': images.map((image) => {
//         'position': {
//           'dx': image.position.dx,
//           'dy': image.position.dy,
//         },
//         'width': image.width,
//         'height': image.height,
//         'imageBytes': base64Encode(image.imageBytes), // Store image as Base64 string
//       }).toList(),
//       'textFields': textFields.map((textField) => {
//         'position': {
//           'dx': textField.position.dx,
//           'dy': textField.position.dy,
//         },
//         'width': textField.width,
//         'height': textField.height,
//         'text': textField.text,
//         'textSize': textField.textSize,
//       }).toList(),
//     };
//
//     // Convert the map to JSON
//     String jsonData = jsonEncode(data);
//
//     // Now you can save the JSON string to a file or any other storage solution
//     print(jsonData); // For demonstration, print it to the console
//   }
//
//
//   Future<void> _exportAsPDF() async {
//     final pdf = pw.Document();
//
//     // Define your PDF page size with no margins
//     final pageSize = PdfPageFormat.a4.copyWith(
//       marginLeft: 0,
//       marginTop: 0,
//       marginRight: 0,
//       marginBottom: 0,
//     );
//
//     // Get scale factor based on the screen size and the PDF page size
//     double scaleFactor = 1.5;
//
//     // Adjust scale factor based on actual screen size vs. desired PDF size
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     // Calculate scale factors based on screen and page dimensions
//     double scaleX = pageSize.width / screenWidth;
//     double scaleY = pageSize.height / screenHeight;
//
//     // Use minimum scale factor to maintain aspect ratio
//     // scaleFactor = scaleX < scaleY ? scaleX : scaleY;
//
//     // Create a PDF page
//     pdf.addPage(
//       pw.Page(
//         pageFormat: pageSize,
//         build: (pw.Context context) {
//           return pw.Container(
//             width: pageSize.width,
//             height: pageSize.height,
//             child: pw.Stack(
//               children: [
//                 if (_certificateTemplateBytes != null)
//                   pw.Positioned(
//                     left: 0,
//                     top: 0,
//                     child: pw.Image(
//                       pw.MemoryImage(_certificateTemplateBytes!),
//                       width: pageSize.width,
//                       height: pageSize.height,
//                       fit: pw.BoxFit.cover,
//                     ),
//                   ),
//                 ...dropdowns.map((dropdown) => pw.Positioned(
//                   left: dropdown.position.dx * scaleFactor,
//                   top: dropdown.position.dy * scaleFactor,
//                   child: pw.Text(
//                     dropdown.selectedValue ?? '',
//                     style: pw.TextStyle(fontSize: 14),
//                   ),
//                 )),
//                 ...images.map((image) => pw.Positioned(
//                   left: (image.position.dx * scaleFactor)+50,
//                   top: (image.position.dy * scaleFactor)+50,
//                   child: pw.Image(
//                     pw.MemoryImage(image.imageBytes),
//                     width: image.width * scaleFactor,
//                     height: image.height * scaleFactor,
//                   ),
//                 )),
//                 ...textFields.map((textField) => pw.Positioned(
//                   left: (textField.position.dx * scaleFactor)+37,
//                   top: (textField.position.dy * scaleFactor)+50,
//                   child: pw.Text(
//                     textField.text,
//                     style: pw.TextStyle(fontSize: textField.textSize * scaleFactor),
//                   ),
//                 )),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//
//     // Save and print the PDF
//     await Printing.layoutPdf(onLayout: (format) async => pdf.save());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Certificate Builder'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: _addDropdown,
//           ),
//           IconButton(
//             icon: Icon(Icons.image),
//             onPressed: _addImage,
//           ),
//           IconButton(
//             icon: Icon(Icons.text_fields),
//             onPressed: _addTextField,
//           ),
//           IconButton(
//             icon: Icon(Icons.picture_as_pdf),
//             onPressed: _exportAsPDF,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: _pickCertificateTemplate,
//             child: Text('Upload Certificate Template'),
//           ),
//           Expanded(
//             child: Stack(
//               children: [
//                 if (_certificateTemplateBytes != null)
//                   Image.memory(_certificateTemplateBytes!),
//                 ...dropdowns,
//                 ...images,
//                 ...textFields,
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class DraggableDropdown extends StatefulWidget {
//   final Function(Key) onDelete;
//   Offset position = Offset(50, 50);
//   String? selectedValue;
//
//   DraggableDropdown({Key? key, required this.onDelete}) : super(key: key);
//
//   @override
//   _DraggableDropdownState createState() => _DraggableDropdownState();
// }
//
// class _DraggableDropdownState extends State<DraggableDropdown> {
//   final List<String> options = ['[Name]', '[DOB]', '[Event]', '[Date]', '[Age]'];
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: widget.position.dx,
//       top: widget.position.dy,
//       child: Draggable(
//         feedback: Material(
//           child: _buildDropdown(),
//         ),
//         childWhenDragging: Container(),
//         onDragEnd: (details) {
//           setState(() {
//             widget.position = details.offset;
//           });
//         },
//         child: _buildDropdown(),
//       ),
//     );
//   }
//
//   Widget _buildDropdown() {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 8.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.black, width: 1.0),
//             borderRadius: BorderRadius.circular(5.0),
//           ),
//           child: DropdownButton<String>(
//             value: widget.selectedValue,
//             hint: Text('Select Variable'),
//             onChanged: (String? newValue) {
//               setState(() {
//                 widget.selectedValue = newValue;
//               });
//             },
//             items: options.map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//         ),
//         IconButton(
//           icon: Icon(Icons.delete),
//           onPressed: () => widget.onDelete(widget.key!),
//         ),
//       ],
//     );
//   }
// }
//
// class DraggableResizableImage extends StatefulWidget {
//   final Uint8List imageBytes;
//   final Function(Key) onDelete;
//   Offset position = Offset(50, 50);
//   double width = 100;
//   double height = 100;
//
//   DraggableResizableImage(
//       {Key? key, required this.imageBytes, required this.onDelete})
//       : super(key: key);
//
//   @override
//   _DraggableResizableImageState createState() =>
//       _DraggableResizableImageState();
// }
//
// class _DraggableResizableImageState extends State<DraggableResizableImage> {
//   bool showResizeArrows = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: widget.position.dx,
//       top: widget.position.dy,
//       child: MouseRegion(
//         onEnter: (_) {
//           setState(() {
//             showResizeArrows = true;
//           });
//         },
//         onExit: (_) {
//           setState(() {
//             showResizeArrows = false;
//           });
//         },
//         child: GestureDetector(
//           onPanUpdate: (details) {
//             setState(() {
//               widget.position += details.delta;
//             });
//           },
//           child: Stack(
//             children: [
//               Container(
//                 width: widget.width,
//                 height: widget.height,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blueAccent, width: 1),
//                 ),
//                 child: Image.memory(widget.imageBytes, fit: BoxFit.cover),
//               ),
//               if (showResizeArrows)
//                 Positioned(
//                   right: 0,
//                   bottom: 0,
//                   child: GestureDetector(
//                     onPanUpdate: (details) {
//                       setState(() {
//                         widget.width += details.delta.dx;
//                         widget.height += details.delta.dy;
//                       });
//                     },
//                     child: MouseRegion(
//                       cursor: SystemMouseCursors.resizeUpLeftDownRight,
//                       child: Icon(Icons.open_with, color: Colors.blueAccent),
//                     ),
//                   ),
//                 ),
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 child: IconButton(
//                   icon: Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => widget.onDelete(widget.key!),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class DraggableResizableTextField extends StatefulWidget {
//   final Function(Key) onDelete;
//   Offset position = Offset(50, 50);
//   double width = 200;
//   double height = 100; // Set initial height suitable for multiline input
//   String text = '';
//
//   DraggableResizableTextField({Key? key, required this.onDelete}) : super(key: key);
//
//   // Define a getter for textSize to access from outside
//   double get textSize => _state?.textSize ?? 16.0;
//
//   _DraggableResizableTextFieldState? _state;
//
//   @override
//   _DraggableResizableTextFieldState createState() {
//     _state = _DraggableResizableTextFieldState();
//     return _state!;
//   }
// }
//
// class _DraggableResizableTextFieldState extends State<DraggableResizableTextField> {
//   bool showResizeArrows = false;
//   double textSize = 16.0; // Initial font size
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: widget.position.dx,
//       top: widget.position.dy,
//       child: MouseRegion(
//         onEnter: (_) {
//           setState(() {
//             showResizeArrows = true;
//           });
//         },
//         onExit: (_) {
//           setState(() {
//             showResizeArrows = false;
//           });
//         },
//         child: GestureDetector(
//           onPanUpdate: (details) {
//             setState(() {
//               widget.position += details.delta;
//             });
//           },
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   Container(
//                     width: widget.width,
//                     height: widget.height,
//                     padding: EdgeInsets.all(8.0),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.greenAccent, width: 1),
//                     ),
//                     child: TextField(
//
//                       controller: TextEditingController(text: widget.text),
//                       onChanged: (value) {
//                         widget.text = value;
//                       },
//                       maxLines: null, // Allows the text field to be multiline
//                       expands: true,  // Enables the text field to expand with the container
//                       style: TextStyle(fontSize: textSize),
//                       decoration: InputDecoration(
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.all(0)
//                       ),
//                     ),
//                   ),
//                   if (showResizeArrows)
//                     Positioned(
//                       right: 0,
//                       bottom: 0,
//                       child: GestureDetector(
//                         onPanUpdate: (details) {
//                           setState(() {
//                             widget.width += details.delta.dx;
//                             widget.height += details.delta.dy;
//                           });
//                         },
//                         child: MouseRegion(
//                           cursor: SystemMouseCursors.resizeUpLeftDownRight,
//                           child: Icon(Icons.open_with, color: Colors.greenAccent),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.add, color: Colors.blue),
//                     onPressed: () {
//                       setState(() {
//                         textSize += 2.0; // Increase font size
//                       });
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.remove, color: Colors.blue),
//                     onPressed: () {
//                       setState(() {
//                         if (textSize > 6) textSize -= 2.0; // Decrease font size, minimum size check
//                       });
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.delete, color: Colors.red),
//                     onPressed: () => widget.onDelete(widget.key!),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
