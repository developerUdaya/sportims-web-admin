class EventRaceModel {
  String categoryName;
  List<RaceAgeGroup> raceAgeGroup;

  EventRaceModel({required this.categoryName, required this.raceAgeGroup});

  factory EventRaceModel.fromJson(Map<dynamic, dynamic> json) {
    return EventRaceModel(
      categoryName: json['categoryName'] ?? '',
      raceAgeGroup: (json['raceAgeGroup'] as List<dynamic>? ?? [])
          .map((x) => RaceAgeGroup.fromJson(x as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'raceAgeGroup': raceAgeGroup.map((x) => x.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EventRaceModel &&
              runtimeType == other.runtimeType &&
              categoryName == other.categoryName &&
              raceAgeGroup == other.raceAgeGroup;

  @override
  int get hashCode => categoryName.hashCode ^ raceAgeGroup.hashCode;
}

class RaceAgeGroup {
  String ageGroup;
  int maxEvents;
  List<EventRace> eventRaces;

  RaceAgeGroup({required this.ageGroup, required this.maxEvents, required this.eventRaces});

  factory RaceAgeGroup.fromJson(Map<dynamic, dynamic> json) {
    return RaceAgeGroup(
      ageGroup: json['ageGroup'] ?? '',
      maxEvents: json['maxEvents'] ?? 0,
      eventRaces: (json['eventRaces'] as List<dynamic>? ?? [])
          .map((x) => EventRace.fromJson(x as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageGroup': ageGroup,
      'maxEvents': maxEvents,
      'eventRaces': eventRaces.map((x) => x.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is RaceAgeGroup &&
              runtimeType == other.runtimeType &&
              ageGroup == other.ageGroup &&
              maxEvents == other.maxEvents &&
              eventRaces == other.eventRaces;

  @override
  int get hashCode => ageGroup.hashCode ^ maxEvents.hashCode ^ eventRaces.hashCode;
}

class EventRace {
  String race;
  bool selected;

  EventRace({required this.race, this.selected = false});

  factory EventRace.fromJson(Map<dynamic, dynamic> json) {
    return EventRace(
      race: json['race'] ?? '',
      selected: json['selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'race': race,
      'selected': selected,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is EventRace &&
              runtimeType == other.runtimeType &&
              race == other.race &&
              selected == other.selected;

  @override
  int get hashCode => race.hashCode ^ selected.hashCode;
}
