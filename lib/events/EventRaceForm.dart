import 'package:flutter/material.dart';

class EventRaceForm extends StatefulWidget {
  final List<String>? eventRaces;
  final Function(List<String>)? updatedEventRaces;

  EventRaceForm({required this.eventRaces, required this.updatedEventRaces});

  @override
  _EventRaceFormState createState() => _EventRaceFormState();
}

class _EventRaceFormState extends State<EventRaceForm> {
  List<TextEditingController> _controllers = [];

  List<String>? eventRaces;

  @override
  void initState() {
    super.initState();
    eventRaces = widget.eventRaces ?? [];
    // Initialize controllers based on eventRaces
    for (var race in eventRaces!) {
      _controllers.add(TextEditingController(text: race));
    }
    // If eventRaces is empty, add one empty controller
    if (eventRaces!.isEmpty) {
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers when the widget is disposed
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitForm() {
    bool hasEmptyFields = false;
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        hasEmptyFields = true;
        break;
      }
    }

    if (hasEmptyFields) {
      // Display an alert dialog or any other UI element to show the error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('All fields must be filled out.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Proceed with form submission
      List<String> updatedRaces = [];
      for (var controller in _controllers) {
        updatedRaces.add(controller.text);
      }
      widget.updatedEventRaces!(updatedRaces);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: 300,
                  child: ListView.builder(
                    itemCount: _controllers.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controllers[index],
                              decoration: InputDecoration(labelText: 'Race ${index + 1}'),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () {
                              if(_controllers.length!=1){
                                setState(() {
                                  _controllers.removeAt(index);
                                });
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        _controllers.add(TextEditingController());
                      });
                    },
                    child: Text(
                      'Add Race',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.lightBlue,
                  ),
                  SizedBox(width: 20),
                  MaterialButton(
                    onPressed: _submitForm,
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.lightBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

