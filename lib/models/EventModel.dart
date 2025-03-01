import 'package:intl/intl.dart';
import 'package:sport_ims/models/EventParticipantsModel.dart';
import 'EventRaceModel.dart';
import 'ResultModel.dart';
import 'UsersModel.dart';

class EventModel {
  String _advertisement;
  String _bannerImage;
  bool _certificateStatus;
  DateTime _createdAt;
  String _declaration;
  DateTime _eventDate;
  DateTime _ageAsOn;
  String _eventName;
  String _id;
  String _instruction;
  String _place;
  String _regAmount;
  String _eventPrefixName;
  List<String> _ageCategory;
  List<Users> _participants;
  List<ResultModel> _result;
  DateTime _regCloseDate;
  DateTime _regStartDate;
  DateTime _updatedAt;
  bool _visibility;
  List<EventRaceModel> _eventRaceModel;
  List<String> _eventRaces;
  List<EventParticipantsModel> _eventParticipants;
  bool _deleteStatus;

  EventModel({
    required String advertisement,
    required String bannerImage,
    required bool certificateStatus,
    required DateTime createdAt,
    required String declaration,
    required DateTime eventDate,
    required DateTime ageAsOn,
    required String eventName,
    required String id,
    required String instruction,
    required String place,
    required String regAmount,
    required String eventPrefixName,
    required List<String> ageCategory,
    required List<Users> participants,
    required List<ResultModel> result,
    required DateTime regCloseDate,
    required DateTime regStartDate,
    required DateTime updatedAt,
    required bool visibility,
    required List<EventRaceModel> eventRaceModel,
    required List<String> eventRaces,
    required List<EventParticipantsModel> eventParticipants,
     bool deleteStatus = false
  })  : _advertisement = advertisement,
        _bannerImage = bannerImage,
        _certificateStatus = certificateStatus,
        _createdAt = createdAt,
        _declaration = declaration,
        _eventDate = eventDate,
        _ageAsOn = ageAsOn,
        _eventName = eventName,
        _id = id,
        _instruction = instruction,
        _place = place,
        _regAmount = regAmount,
        _eventPrefixName = eventPrefixName,
        _ageCategory = ageCategory,
        _participants = participants,
        _result = result,
        _regCloseDate = regCloseDate,
        _regStartDate = regStartDate,
        _updatedAt = updatedAt,
        _visibility = visibility,
        _eventRaceModel = eventRaceModel,
        _eventRaces = eventRaces,
        _eventParticipants = eventParticipants,
        _deleteStatus = deleteStatus;

  // Getters
  String get advertisement => _advertisement;
  String get bannerImage => _bannerImage;
  bool get certificateStatus => _certificateStatus;
  DateTime get createdAt => _createdAt;
  String get declaration => _declaration;
  DateTime get eventDate => _eventDate;
  String get eventName => _eventName;
  String get id => _id;
  String get instruction => _instruction;
  String get place => _place;
  String get regAmount => _regAmount;
  String get eventPrefixName => _eventPrefixName;
  List<String> get ageCategory => _ageCategory;
  List<Users> get participants => _participants;
  DateTime get regCloseDate => _regCloseDate;
  DateTime get regStartDate => _regStartDate;
  DateTime get updatedAt => _updatedAt;
  bool get visibility => _visibility;
  List<EventRaceModel> get eventRaceModel => _eventRaceModel;
  List<String> get eventRaces => _eventRaces;
  DateTime get ageAsOn => _ageAsOn;
  List<EventParticipantsModel> get eventParticipants => _eventParticipants;
  bool get deleteStatus => _deleteStatus;

  // Setters
  set advertisement(String advertisement) => _advertisement = advertisement;
  set bannerImage(String bannerImage) => _bannerImage = bannerImage;
  set certificateStatus(bool certificateStatus) => _certificateStatus = certificateStatus;
  set createdAt(DateTime createdAt) => _createdAt = createdAt;
  set declaration(String declaration) => _declaration = declaration;
  set eventDate(DateTime eventDate) => _eventDate = eventDate;
  set ageAsOn(DateTime ageAsOn) => _ageAsOn = ageAsOn;
  set eventName(String eventName) => _eventName = eventName;
  set id(String id) => _id = id;
  set instruction(String instruction) => _instruction = instruction;
  set place(String place) => _place = place;
  set regAmount(String regAmount) => _regAmount = regAmount;
  set eventPrefixName(String eventPrefixName) => _eventPrefixName = eventPrefixName;
  set ageCategory(List<String> ageCategory) => _ageCategory = ageCategory;
  set participants(List<Users> participants) => _participants = participants;
  set regCloseDate(DateTime regCloseDate) => _regCloseDate = regCloseDate;
  set regStartDate(DateTime regStartDate) => _regStartDate = regStartDate;
  set updatedAt(DateTime updatedAt) => _updatedAt = updatedAt;
  set visibility(bool visibility) => _visibility = visibility;
  set eventRaceModel(List<EventRaceModel> eventRaceModel) => _eventRaceModel = eventRaceModel;
  set eventRaces(List<String> eventRaces) => _eventRaces = eventRaces;
  set eventParticipants(List<EventParticipantsModel> eventParticipants) => _eventParticipants = eventParticipants;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    // Parse eventParticipants if it's a List<dynamic> or handle it as needed
    List<EventParticipantsModel> participants = [];

    // Check if eventParticipants exists and is a Map<String, dynamic>
    if (json['eventParticipants'] != null && json['eventParticipants'] is Map<dynamic, dynamic>) {
      json['eventParticipants'].forEach((key, value) {
        // Convert each value (which is a Map<dynamic, dynamic>) to EventParticipantsModel
        EventParticipantsModel participant = EventParticipantsModel.fromJson(Map<String, dynamic>.from(value));
        participants.add(participant);

        print("participant name :${participant.name}");

        // Print the fetched eventParticipants JSON for debugging
        print('Fetched eventParticipant JSON for key $key:');
        print(value); // Print the JSON data for each participant
      });
    }
    return EventModel(
      advertisement: json['advertisement'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
      certificateStatus: json['certificateStatus'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      declaration: json['declaration'] ?? '',
      eventDate: json['eventDate'] != null ? dateFormat.parse(json['eventDate']) : DateTime.now(),
      ageAsOn: json['ageAsOn'] != null ? DateTime.parse(json['ageAsOn']) : DateTime.now(),
      eventName: json['eventName'] ?? '',
      id: json['id'] ?? '',
      instruction: json['instruction'] ?? '',
      place: json['place'] ?? '',
      regAmount: json['regAmount'] ?? '',
      eventPrefixName: json['eventPrefixName'] ?? '',
      ageCategory: List<String>.from(json['ageCategory'] ?? []),
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((participant) => Users.fromJson(participant as Map<dynamic, dynamic>))
          .toList(),
      regCloseDate: json['regCloseDate'] != null ? dateFormat.parse(json['regCloseDate']) : DateTime.now(),
      regStartDate: json['regStartDate'] != null ? dateFormat.parse(json['regStartDate']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      visibility: json['visibility'] ?? false,
      result: (json['result'] as List<dynamic>? ?? [])
          .map((result) => ResultModel.fromJson(result! as Map<String, dynamic>))
          .toList(),
      eventRaceModel: (json['eventRaceModel'] as List<dynamic>? ?? [])
          .map((e) => EventRaceModel.fromJson(e as Map<dynamic, dynamic>))
          .toList(),
      eventRaces: List<String>.from(json['eventRaces'] ?? []),
      eventParticipants: participants,
      deleteStatus: json['deleteStatus']??false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'advertisement': _advertisement,
      'bannerImage': _bannerImage,
      'certificateStatus': _certificateStatus,
      'createdAt': _createdAt.toIso8601String(),
      'declaration': _declaration,
      'eventDate': _eventDate.toIso8601String(),
      'ageAsOn': _ageAsOn.toIso8601String(),
      'eventName': _eventName,
      'id': _id,
      'instruction': _instruction,
      'place': _place,
      'regAmount': _regAmount,
      'eventPrefixName': _eventPrefixName,
      'ageCategory': _ageCategory,
      'participants': _participants.map((participant) => participant.toJson()).toList(),
      'regCloseDate': _regCloseDate.toIso8601String(),
      'regStartDate': _regStartDate.toIso8601String(),
      'updatedAt': _updatedAt.toIso8601String(),
      'visibility': _visibility,
      'result': _result.map((result) => result.toJson()).toList(),
      'eventRaceModel': _eventRaceModel.map((e) => e.toJson()).toList(),
      'eventRaces': _eventRaces,
    };
  }
}
