import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package

class PaymentReport extends StatefulWidget {
  const PaymentReport({super.key});

  @override
  State<PaymentReport> createState() => _PaymentReportState();
}

class _PaymentReportState extends State<PaymentReport> {
  late DateTime fromDate = DateTime.now();
  late DateTime toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RightSide(
        fromDate: fromDate,
        toDate: toDate,
        onFromChanged: (DateTime newFromDate) {
          setState(() {
            fromDate = newFromDate;
          });
        },
        onToChanged: (DateTime newToDate) {
          setState(() {
            toDate = newToDate;
          });
        },
      ),
    );
  }
}

class RightSide extends StatefulWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final ValueChanged<DateTime> onFromChanged;
  final ValueChanged<DateTime> onToChanged;

  const RightSide({
    required this.fromDate,
    required this.toDate,
    required this.onFromChanged,
    required this.onToChanged,
  });

  @override
  State<RightSide> createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  String dropdownValue = 'Option 1'; // Default dropdown value
  bool _showPrefix = true;
  bool _isSearching = false;
  double _textFieldWidth = 70;
  List<PaymentReportModel> tableData = [
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),
    PaymentReportModel("s001", "Chennai Speed\n2023", "Nadin s", "10", "null", "5","20/11/2023", "aborted"),


  ];

  late TextEditingController _dateController; // Controller for the TextField
  late DateTime _selectedDate; // Variable to store the selected date

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd').format(widget.fromDate));
    _selectedDate = widget.fromDate; // Initialize selected date with fromDate
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Payment Report"),
          backgroundColor: Color(0xffb0ccf8),
        ),
        body: Center(
          child: Container(
            color: Color(0xffcbdcf7),
            padding: EdgeInsets.only(
                top: 20, left: 20, right: 20, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffdde7f9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          // Handle download action
                        },
                        icon: Icon(
                          Icons.download_rounded, // Change the icon to download
                          color: Color(0xff276ad5),
                        ),
                        label: Text(
                          'Download Excel ', // Change the label text
                          style: TextStyle(
                            color: Color(0xff276ad5),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),


                    Container(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(50, 5, 0, 0),
                            child: Text(
                              "From Date",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(50, 0, 0, 20),
                            child: TextField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                hintText: 'Agr as on',
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.date_range),
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: widget.fromDate,
                                      firstDate: DateTime(2015, 8),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null && picked != widget.fromDate) {
                                      widget.onFromChanged(picked);
                                      _dateController.text =
                                          DateFormat('yyyy-MM-dd').format(picked);
                                      setState(() {
                                        _selectedDate = picked; // Update selected date
                                      });
                                    }
                                  },
                                ),
                                // border: OutlineInputBorder(),
                              ),
                              cursorColor: Colors.black,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: widget.fromDate,
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != widget.fromDate) {
                                  widget.onFromChanged(picked);
                                  _dateController.text =
                                      DateFormat('yyyy-MM-dd').format(picked);
                                  setState(() {
                                    _selectedDate = picked; // Update selected date
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(50, 5, 0, 0),
                            child: Text(
                              "To Date",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(50, 0, 0, 20),
                            child: TextField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                hintText: 'Events Date',
                                suffixIcon: IconButton(
                                  icon: Icon(Icons.date_range),
                                  onPressed: () async {
                                    final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: widget.fromDate,
                                      firstDate: DateTime(2015, 8),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null && picked != widget.fromDate) {
                                      widget.onFromChanged(picked);
                                      _dateController.text =
                                          DateFormat('yyyy-MM-dd').format(picked);
                                      setState(() {
                                        _selectedDate = picked; // Update selected date
                                      });
                                    }
                                  },
                                ),
                                // border: OutlineInputBorder(),
                              ),
                              cursorColor: Colors.black,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: widget.fromDate,
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != widget.fromDate) {
                                  widget.onFromChanged(picked);
                                  _dateController.text =
                                      DateFormat('yyyy-MM-dd').format(picked);
                                  setState(() {
                                    _selectedDate = picked; // Update selected date
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        child: Expanded(
                            child: Container())), // Add spacing between the button and the search bar
                    AnimatedContainer(
                      duration: Duration(milliseconds: 65),
                      width: _isSearching ? 200 : 0,
                      height: _isSearching ? 35 : 0,
                      padding: _isSearching?EdgeInsets.symmetric(horizontal: 0,vertical: 0):EdgeInsets.symmetric(horizontal: 10,vertical: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: _textFieldWidth,
                              child: CupertinoSearchTextField(
                                onChanged: (value) {
                                  // Handle search query changes
                                },
                              ),
                            ),
                          ),
                          // IconButton(
                          //   // icon: Icon(Icons.cancel),
                          //   onPressed: () {
                          //     setState(() {
                          //       _isSearching = false;
                          //     });
                          //   },
                          // ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(9),
                            child: DataTable(
                              headingRowHeight: 45,
                              dataRowHeight: 55,
                              columns: [
                                DataColumn(
                                    label: Text('Serial No'), numeric: false),
                                DataColumn(
                                    label: Text('Event name'),
                                    numeric: false),
                                DataColumn(
                                    label: Text('skater name'),
                                    numeric: false),
                                DataColumn(
                                    label: Text('order ID'), numeric: false),
                                DataColumn(
                                    label: Text('Payment ref no'),
                                    numeric: false),
                                DataColumn(
                                    label: Text('paid amount'), numeric: false),
                                DataColumn(
                                    label: Text('Paid date&time'),
                                    numeric: false),
                                DataColumn(
                                    label: Text('Paid status'),
                                    numeric: false),
                                DataColumn(
                                    label: Text('Delete'), numeric: false),
                              ],
                              rows: List.generate(tableData.length, (index) {
                                return DataRow(cells: [
                                  DataCell(
                                      Text(tableData[index].serialnumber)),
                                  DataCell(
                                      Text(tableData[index].Eventsname)),
                                  DataCell(
                                      Text(tableData[index].Skatername)),
                                  DataCell(
                                      Text(tableData[index].OrderID)),
                                  DataCell(Text(
                                      tableData[index].PaymentRefNo)),
                                  DataCell(Text(
                                      tableData[index].Paidamount)),
                                  DataCell(Text(
                                      tableData[index].PaidDateandTime)),
                                  DataCell(
                                      Text(tableData[index].Paidstatus)),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(Icons.delete, size: 16),
                                      onPressed: () {
                                        // Handle delete action
                                      },
                                    ),
                                  ),
                                ]);
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Handle reverse button press
                      },
                      icon: Icon(Icons.arrow_circle_left_sharp),
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle reverse button press
                      },
                      icon: Transform.rotate(
                        angle: -4.7,
                        child: Icon(Icons.arrow_drop_down_circle_sharp),
                      ),
                    ),
                    Text("1"),
                    IconButton(
                      onPressed: () {
                        // Handle play button press
                      },
                      icon: Transform.rotate(
                        angle: 4.7,
                        child: Icon(Icons.arrow_drop_down_circle_sharp),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle reverse button press
                      },
                      icon: Icon(Icons.arrow_circle_right_sharp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentReportModel {
  String serialnumber,
      Eventsname,
      Skatername,
      OrderID,
      PaymentRefNo,
      Paidamount,
      PaidDateandTime,
      Paidstatus;

  PaymentReportModel(
      this.serialnumber,
      this.Eventsname,
      this.Skatername,
      this.OrderID,
      this.PaymentRefNo,
      this.Paidamount,
      this.PaidDateandTime,
      this.Paidstatus);
}
