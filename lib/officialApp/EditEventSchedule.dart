
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/models/EventParticipantsModel.dart';

import '../models/EventModel.dart';
import '../models/EventScheduleModel.dart';


class EditEventSchedule extends StatefulWidget {
  final Function(EventScheduleModel) updateEventScheduleModels;
  EventModel eventModel;
  List<EventScheduleModel> eventScheduleModelList;
  EventScheduleModel eventScheduleModel;


  EditEventSchedule({required this.updateEventScheduleModels, required this.eventModel, required this.eventScheduleModelList, required this.eventScheduleModel});

  @override
  _EditEventScheduleState createState() => _EditEventScheduleState();
}

class _EditEventScheduleState extends State<EditEventSchedule> {
  final formKey = GlobalKey<FormState>();
  late EventModel model;

  late String eventId;
  late String eventName;
  late String scheduleDate= DateTime.now().toString().substring(0,10);
  late String? scheduleTime="";
  late String gender;
  late String skaterCategory;
  late String ageCategory;
  late String raceCategory;
  late String scheduleId ;
  late String id;
  late List<String> participants=[];
  late List<EventScheduleModel> filteredModels=[];

  List<String> genders = ['Male', 'Female','All'];
  List<String> ageCategories = [];
  List<String> raceCategories = [];
  List<EventParticipantsModel> allParticipants = [];
  List<EventParticipantsModel> filteredParticipants = [];
  List<String> skaterCategories = ["Beginner","Quad","Fancy","Inline"];
  List<EventParticipantsModel> selectedParticipants = [];

  List<String> sanitizeList(List<String> list) {
    return list.toSet().toList();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      model = widget.eventModel;

      // Sanitize lists
      genders = sanitizeList(genders);
      ageCategories = sanitizeList(widget.eventModel.ageCategory);
      raceCategories = sanitizeList(widget.eventModel.eventRaces);
      skaterCategories = sanitizeList(skaterCategories);

      // Initialize form fields with eventScheduleModel values
      eventId = widget.eventModel.id;
      eventName = widget.eventModel.eventName;
      scheduleDate = widget.eventScheduleModel.scheduleDate;
      scheduleTime = widget.eventScheduleModel.scheduleTime;
      gender = widget.eventScheduleModel.gender;
      skaterCategory = widget.eventScheduleModel.skaterCategory;
      ageCategory = widget.eventScheduleModel.ageCategory;
      raceCategory = widget.eventScheduleModel.raceCategory;
      scheduleId = widget.eventScheduleModel.scheduleId;
      id = widget.eventScheduleModel.id;
      participants = List.from(widget.eventScheduleModel.participants);
      allParticipants = widget.eventModel.eventParticipants;


      if (!genders.contains(gender)) {
        gender = genders.isNotEmpty ? genders[0] : '';
      }
      if (!ageCategories.contains(ageCategory)) {
        ageCategory = ageCategories.isNotEmpty ? ageCategories[0] : '';
      }
      if (!raceCategories.contains(raceCategory)) {
        raceCategory = raceCategories.isNotEmpty ? raceCategories[0] : '';
      }
      if (!skaterCategories.contains(skaterCategory)) {
        skaterCategory = skaterCategories.isNotEmpty ? skaterCategories[0] : '';
      }

      // Initialize selectedParticipants based on eventScheduleModel participants
      selectedParticipants = allParticipants
          .where((participant) => participants.contains(participant.skaterId))
          .toList();

      filteredModels = List.from(widget.eventScheduleModelList);
      filteredModels.removeWhere((model) => model.id == id); // Remove based on id

    });
    filterParticipants();
  }


  void onParticipantSelected(bool selected, EventParticipantsModel participant) {
    setState(() {
      if (selected) {
        selectedParticipants.add(participant);
        participants.add(participant.skaterId);
      } else {
        selectedParticipants.remove(participant);
        participants.remove(participant.skaterId);
      }
    });
  }


  void filterParticipants() {
    String selectedGender = gender == 'All' ? '' : gender;

    List<EventScheduleModel> filteredModels = this.filteredModels.where((model) =>
    model.ageCategory.contains(ageCategory) &&
        model.raceCategory.contains(raceCategory) &&
        model.skaterCategory.contains(skaterCategory)
    ).toList();

    // Extract participant IDs from filtered models
    Set<String> filteredParticipantIds = filteredModels
        .expand((model) => model.participants)
        .toSet();

    print(filteredParticipantIds);

    setState(() {
      // Filter allParticipants based on the criteria and exclude participants from filteredParticipantIds
      filteredParticipants = allParticipants.where((element) =>
      element.raceCategory.contains(raceCategory) &&
          element.gender.contains(selectedGender) &&
          (ageCategory.contains(element.age) || ageCategory.contains('${int.tryParse(element.age)! + 1}')) &&
          element.skaterCategory.contains(skaterCategory)
          // && !filteredParticipantIds.contains(element.skaterId)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event Schedule'),
        backgroundColor: Color(0xffb0ccf8),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Two columns on larger screens, one column on smaller screens
                  if (!isMobile)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildEventNameDropdown(),
                              buildScheduleDateField(),
                              buildScheduleTimeField(),
                              buildGenderDropdown(),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSkaterCategoryField(),
                              buildAgeCategoryDropdown(),
                              buildRaceCategoryDropdown(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (isMobile) // Single column on smaller screens
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildEventNameDropdown(),
                        buildScheduleDateField(),
                        buildScheduleTimeField(),
                        buildGenderDropdown(),
                        buildSkaterCategoryField(),
                        buildAgeCategoryDropdown(),
                        buildRaceCategoryDropdown(),
                      ],
                    ),
                  SizedBox(height: 20),
                  Text('Participants:', style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 10),
                  buildParticipantsDataTable(),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        showCircularProgressBar(context);
                        if (formKey.currentState!.validate()) {
                          if(selectedParticipants==null || selectedParticipants.length==0){
                            showErrorDialog(context,'Error',"Please select Skaters");
                            Navigator.pop(context);
                            return;
                          }
                          String refId = widget.eventScheduleModel.id;
                          final newEventSchedule = EventScheduleModel(
                            eventId: eventId,
                            scheduleDate: scheduleDate,
                            scheduleTime: scheduleTime!,
                            gender: gender,
                            skaterCategory: skaterCategory,
                            ageCategory: ageCategory,
                            raceCategory: raceCategory,
                            participants: participants,
                            id: refId,
                            eventName: model.eventName,
                            scheduleId: scheduleId, resultList: widget.eventScheduleModel.resultList,
                          );

                          DatabaseReference ref = FirebaseDatabase.instance.ref();
                          await ref.child('events/pastEvents/${model.id}/eventSchedules/$refId/').update(newEventSchedule.toJson());

                          widget.updateEventScheduleModels(newEventSchedule);
                          Navigator.pop(context);
                          showSuccessDialog(context,"Success","Event Schedule Updated Successfully");
                        }
                      },
                      child: Text('Update Schedule'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void showCircularProgressBar(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);// Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildEventNameDropdown() {
    return DropdownButtonFormField<String>(

      decoration: InputDecoration(labelText: 'Event Name'),
      items: [eventName].map((name) {
        return DropdownMenuItem<String>(
          value: name,
          child: Text(name),
        );
      }).toList(),
      value: [eventName].first,
      onChanged: (value) {
        setState(() {
          eventName = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an event';
        }
        return null;
      },
    );
  }


  Widget buildScheduleDateField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            scheduleDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(labelText: 'Schedule Date (YYYY-MM-DD)'),
          controller: TextEditingController(text: scheduleDate),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter schedule date';
            }
            return null;
          },
        ),
      ),
    );
  }


  Widget buildScheduleTimeField() {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            scheduleTime = '${pickedTime.hour}:${pickedTime.minute}';
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Schedule Time (HH:MM)',
          ),
          controller: TextEditingController(text: scheduleTime),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter schedule time';
            }
            return null;
          },
        ),
      ),
    );
  }
  Widget buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: gender,
      decoration: InputDecoration(labelText: 'Gender'),
      items: genders.map((gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          gender = value!;
        });

        filterParticipants();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select gender';
        }
        return null;
      },
    );
  }


  Widget buildSkaterCategoryField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Skater Category'),
      items: skaterCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      value: skaterCategory,
      onChanged: (value) {
        setState(() {
          skaterCategory = value!;
        });

        filterParticipants();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select skater category';
        }
        return null;
      },
    );
  }

  Widget buildAgeCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: ageCategory,
      decoration: InputDecoration(labelText: 'Age Category'),
      items: ageCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          ageCategory = value!;
        });

        filterParticipants();

      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select age category';
        }
        return null;
      },
    );
  }

  Widget buildRaceCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: raceCategory,
      decoration: InputDecoration(labelText: 'Race Category'),
      items: raceCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          raceCategory = value!;
        });

        filterParticipants();

      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select race category';
        }
        return null;
      },
    );
  }

  Widget buildParticipantsDataTable() {
    return Container(
      width: 1000,
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          headingRowHeight: 45,
          dataRowMinHeight: 14,
          dataRowMaxHeight: 30,
          showFirstLastButtons: true,
          columnSpacing: 8,
          rowsPerPage: 5, // Initial rows per page
          availableRowsPerPage: const [5, 10, 20],
          columns: [
            DataColumn(label: Text('S.No')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Chest No')),
            DataColumn(label: Text('Age')),
          ],
          source: ParticipantData(
            participants: filteredParticipants,
            selectedParticipants: selectedParticipants,
            onParticipantSelected: onParticipantSelected,
          ),
        ),
      ),
    );
  }


}

class ParticipantData extends DataTableSource {
  final List<EventParticipantsModel> participants;
  final List<EventParticipantsModel> selectedParticipants;
  final Function(bool, EventParticipantsModel) onParticipantSelected;

  ParticipantData({
    required this.participants,
    required this.selectedParticipants,
    required this.onParticipantSelected,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= participants.length) return null;

    final participant = participants[index];

    return DataRow.byIndex(
      index: index,
      selected: selectedParticipants.contains(participant),
      onSelectChanged: (selected) {
        onParticipantSelected(selected!, participant);
      },
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(participant.name)),
        DataCell(Text(participant.chestNumber)),
        DataCell(Text(participant.age)),
      ],
    );
  }

  @override
  int get rowCount => participants.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => selectedParticipants.length;
}
