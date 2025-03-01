
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sport_ims/models/EventParticipantsModel.dart';

import '../models/EventModel.dart';
import '../models/EventScheduleModel.dart';


class AddEventSchedule extends StatefulWidget {
  final Function(EventScheduleModel) updateEventScheduleModels;
  EventModel eventModel;
  List<EventScheduleModel> eventScheduleModelList;


  AddEventSchedule({required this.updateEventScheduleModels, required this.eventModel, required this.eventScheduleModelList});

  @override
  _AddEventScheduleState createState() => _AddEventScheduleState();
}

class _AddEventScheduleState extends State<AddEventSchedule> {
  final formKey = GlobalKey<FormState>();
  late EventModel model;

  late String eventId;
  late String eventName;
  late String scheduleDate= DateTime.now().toString().substring(0,10);
  late String? scheduleTime="";
  String gender = 'All';
  late String skaterCategory="Beginner";
  late String ageCategory;
  late String raceCategory;
  late String scheduleId ;
  late List<String> participants=[];

  List<EventModel> events = [];
  List<String> eventNames = [];
  List<String> genders = ['Male', 'Female', 'All'];
  List<String> ageCategories = [];
  List<String> raceCategories = ['100m', '200m', '400m', '800m', '1600m'];
  List<EventParticipantsModel> allParticipants = [];
  List<EventParticipantsModel> filteredParticipants = [];
  List<String> skaterCategories = ["Beginner","Quad","Fancy","Inline"];
  List<EventParticipantsModel> selectedParticipants = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      model = widget.eventModel;
      eventId = model.id;
      eventName = model.eventName;
      ageCategories = model.ageCategory;
      raceCategories = model.eventRaces;
      allParticipants = model.eventParticipants;
      eventNames.add(model.eventName);
      eventName = model.eventName;
      

      raceCategory = raceCategories.first;
      ageCategory = ageCategories.first;
    });

    print('All Participants');
    print(allParticipants.map((e) => e.toJson(),));
    filterParticipants();
  }


  void onParticipantSelected(bool selected, EventParticipantsModel participant) {
    setState(() {
      if (selected) {
        selectedParticipants.add(participant);
        participants.add(participant.skaterId);
      } else {
        selectedParticipants.remove(participant);
        participants.add(participant.skaterId);
      }
    });
  }


  void filterParticipants() {
    String selectedGender = gender == 'All' ? '' : gender;
    int selectedAge = int.parse(ageCategory.replaceAll(new RegExp(r'[^0-9]'),''));


    setState(() {
      filteredParticipants.clear();
      // Filter allParticipants based on the criteria and exclude participants from filteredParticipantIds
      // filteredParticipants = allParticipants.where((element) =>
      // element.raceCategory.contains(raceCategory) &&
      //     element.gender.contains(selectedGender) &&
      //     (ageCategory.contains(element.age) ||
      //         ageCategory.contains('${int.tryParse(element.age)! + 1}')) &&
      //     element.skaterCategory.contains(skaterCategory) &&
      //     !filteredParticipantIds.contains(element.skaterId)).toList();

      

      filteredParticipants = allParticipants.where((element) {

        print(' ${element.gender.contains(selectedGender)} ${element.raceCategory.contains(raceCategory)} ${element.skaterCategory==skaterCategory} ${ageCategory.toLowerCase().contains('above')? selectedAge<int.parse(element.age):(int.parse(element.age)==selectedAge||int.parse(element.age)==selectedAge-1)}');
      return  element.gender.contains(selectedGender) &&
              element.raceCategory.contains(raceCategory) &&
              element.skaterCategory==skaterCategory &&
          (ageCategory.toLowerCase().contains('above')? selectedAge<int.parse(element.age):(int.parse(element.age)==selectedAge||int.parse(element.age)==selectedAge-1));
      }).toList();
      // Remove participants already in eventScheduleModelList for the selected race category
      for (var schedule in widget.eventScheduleModelList) {
        if (schedule.raceCategory == raceCategory) {
          filteredParticipants.removeWhere((participant) => schedule.participants.contains(participant.skaterId));
        }
      }
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
                            Navigator.pop(context);

                            showErrorDialog(context,'Error',"Please select Skaters");
                            return;
                          }
                          String scheduleId = widget.eventScheduleModelList.length>0?'SCD${(int.parse(widget.eventScheduleModelList.last.id.substring(3))+1).toString().padLeft(4, '0')}':'SCD0001';
                          final newEventSchedule = EventScheduleModel(
                            eventId: eventId,
                            scheduleDate: scheduleDate,
                            scheduleTime: scheduleTime!,
                            gender: gender,
                            skaterCategory: skaterCategory,
                            ageCategory: ageCategory,
                            raceCategory: raceCategory,
                            participants: participants,
                            id: scheduleId,
                            eventName: model.eventName,
                            scheduleId: scheduleId, resultList: [],
                          );

                          DatabaseReference ref = FirebaseDatabase.instance.ref();
                          await ref.child('events/pastEvents/${model.id}/eventSchedules/$scheduleId/').set(newEventSchedule.toJson());

                          widget.updateEventScheduleModels(newEventSchedule);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }else{
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Add Schedule'),
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
  Widget buildEventNameDropdown() {
    return DropdownButtonFormField<String>(

      decoration: InputDecoration(labelText: 'Event Name'),
      items: eventNames.map((name) {
        return DropdownMenuItem<String>(
          value: name,
          child: Text(name),
        );
      }).toList(),
      value: eventName,
      onChanged: (value) {
        setState(() {
          eventName = value!;
          eventId = 'sample_event_id'; // Replace with actual logic to fetch event ID
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
      decoration: InputDecoration(labelText: 'Age Category'),
      items: ageCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      value: ageCategory,
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


  // 12.50

  // - 1
  // - 50
  // - 1
  // - 0.25
  // - 1.25

 //   Total          Dhanabal               Ganeshan
 //    4    -          0                     4
 //    2    -          1                     1
 //    2    -          1                     1
 //    1    -          0.50                  0.50
 //    0.25 -          0.25                  0
 //    1    -          1                     0
 //    1.75 -          1.25                  0.50
 //    1    -          1                     0
 //    2.5  -          2                     0.50
 //     --------------------------------------------
 //    15.5 -          8                     7.5
 //

 // 2.5 -         2.5                   0



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
