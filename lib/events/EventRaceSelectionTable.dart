import 'package:flutter/material.dart';
import '../models/EventRaceModel.dart';

class PaginatedRaceTable extends StatefulWidget {
  final List<RaceAgeGroup> raceAgeGroups;
  final List<String> eventRaces;
  final Function(List<RaceAgeGroup>,String) updateEventRaceModel;
  final String category;

  PaginatedRaceTable({required this.raceAgeGroups, required this.eventRaces,required this.updateEventRaceModel, required this.category});

  @override
  _PaginatedRaceTableState createState() => _PaginatedRaceTableState();
}

class _PaginatedRaceTableState extends State<PaginatedRaceTable> {
  late List<RaceAgeGroup> raceAgeGroups;
  late List<String> eventRaces;


  @override
  void initState() {
    super.initState();
    raceAgeGroups = widget.raceAgeGroups;
    eventRaces = widget.eventRaces;
    print("raceAgeGroups.map((e) => e.ageGroup).toList()");

    print(raceAgeGroups.map((e) => e.ageGroup).toList());
  }

  void _onRaceSelectionChanged(int ageGroupIndex, String raceName, bool isSelected) {
    setState(() {
      raceAgeGroups = raceAgeGroups.map((ageGroup) {
        if (ageGroup == raceAgeGroups[ageGroupIndex]) {
          // Update existing races or add new one if not found
          final updatedEventRaces = ageGroup.eventRaces.map((race) {
            if (race.race == raceName) {
              return EventRace(race: raceName, selected: isSelected);
            }
            return race;
          }).toList();

          // Ensure no duplicate races are added
          if (!updatedEventRaces.any((race) => race.race == raceName)) {
            updatedEventRaces.add(EventRace(race: raceName, selected: isSelected));
          }

          // Filter out duplicates
          final distinctEventRaces = <String, EventRace>{};
          for (var race in updatedEventRaces) {
            distinctEventRaces[race.race] = race;
          }

          final filteredEventRaces = distinctEventRaces.values.toList();

          // Print the number of selected races in the age group
          final selectedRacesCount = filteredEventRaces.where((race) => race.selected).length;
          print('Number of selected races in age group ${ageGroup.ageGroup}: $selectedRacesCount');

          // Update maxEvents if it's 0 or null
          int updatedMaxEvents = ageGroup.maxEvents;
          if (updatedMaxEvents == 0 || updatedMaxEvents == null) {
            updatedMaxEvents = selectedRacesCount;
          }

          return RaceAgeGroup(
            ageGroup: ageGroup.ageGroup,
            maxEvents: updatedMaxEvents,
            eventRaces: filteredEventRaces,
          );
        }
        return ageGroup;
      }).toList();
    });
  }

  void _onMaxEventsChanged(int ageGroupIndex, int newMaxEvents) {
    setState(() {
      raceAgeGroups[ageGroupIndex] = RaceAgeGroup(
        ageGroup: raceAgeGroups[ageGroupIndex].ageGroup,
        maxEvents: newMaxEvents,
        eventRaces: raceAgeGroups[ageGroupIndex].eventRaces,
      );
    });
  }

  void _showAlertDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Validation Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onSubmit() {
    for (var ageGroup in raceAgeGroups) {
      int selectedRacesCount = ageGroup.eventRaces.where((race) => race.selected).length;
      if (selectedRacesCount < ageGroup.maxEvents) {

        _showAlertDialog(
          'The max events of age group ${ageGroup.ageGroup} cannot be more than $selectedRacesCount.',
        );
        return;
      }
      if (selectedRacesCount > 0 && (ageGroup.maxEvents == 0 || ageGroup.maxEvents == null)) {
        _showAlertDialog(
          'The max events for age group ${ageGroup.ageGroup} cannot be zero or empty if any race is selected.',
        );
        return;
      }
      if (selectedRacesCount == 0 && ageGroup.maxEvents != 0) {
        _showAlertDialog(
          'Selected events cannot be empty for age group ${ageGroup.ageGroup} as Max Events not empty.',
        );
        return;
      }
    }

    List<RaceAgeGroup> selectedRaceAgeGroups = raceAgeGroups.map((ageGroup) {
      return RaceAgeGroup(
        ageGroup: ageGroup.ageGroup,
        maxEvents: ageGroup.maxEvents,
        eventRaces: ageGroup.eventRaces.where((race) => race.selected).toList(),
      );
    }).where((ageGroup) => ageGroup.eventRaces.isNotEmpty).toList();

    widget.updateEventRaceModel(raceAgeGroups,widget.category);

    // Print or process the selectedRaceAgeGroups as needed
    print('Selected Race Age Groups: ${raceAgeGroups.map((group) => group.toJson()).toList()}');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Race Participation Table'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            PaginatedDataTable(
              header: Text('Select races for each age group'),
              rowsPerPage: raceAgeGroups.length,
              columns: [
                DataColumn(label: Text('Age Group')),
                ...eventRaces.map((race) => DataColumn(label: Text(race))).toList(),
                DataColumn(label: Text('Max Events')),
              ],
              source: RaceDataTableSource(
                raceAgeGroups,
                eventRaces,
                onRaceSelectionChanged: _onRaceSelectionChanged,
                onMaxEventsChanged: _onMaxEventsChanged,
              ),
            ),
            ElevatedButton(
              onPressed: _onSubmit,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}


class RaceDataTableSource extends DataTableSource {
  final List<RaceAgeGroup> raceAgeGroups;
  final List<String> raceNames;
  final Function(int, String, bool) onRaceSelectionChanged;
  final Function(int, int) onMaxEventsChanged;

  RaceDataTableSource(this.raceAgeGroups, this.raceNames,
      {required this.onRaceSelectionChanged, required this.onMaxEventsChanged});

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= raceAgeGroups.length) return null!;
    final RaceAgeGroup ageGroup = raceAgeGroups[index];

    TextEditingController maxEventsController = TextEditingController(
        text: ageGroup.maxEvents != null && ageGroup.maxEvents != 0
            ? ageGroup.maxEvents.toString()
            : '');

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(ageGroup.ageGroup)),
        ...raceNames.map((raceName) {
          final race = ageGroup.eventRaces.firstWhere(
                (race) => race.race == raceName,
            orElse: () => EventRace(race: raceName, selected: false),
          );
          print(ageGroup.ageGroup);
          return DataCell(Checkbox(
            value: race.selected,
            onChanged: (bool? value) {
              onRaceSelectionChanged(index, raceName, value ?? false);
            },
          ));
        }).toList(),
        DataCell(
          TextFormField(
            controller: maxEventsController,
            // initialValue: ageGroup.maxEvents.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              int newMaxEvents = int.tryParse(value) ?? 0;
              onMaxEventsChanged(index, newMaxEvents);
            },
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => raceAgeGroups.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => raceAgeGroups
      .map((group) => group.eventRaces.where((race) => race.selected).length)
      .fold(0, (prev, count) => prev + count);
}

// EventRaceModel, RaceAgeGroup, and EventRace classes remain the same.
