import 'package:intl/intl.dart';
import 'ResultModel.dart';
import 'UsersModel.dart';

class PastEventModel {
  String _advertisement;
  String _bannerImage;
  bool _certificateStatus;
  DateTime _createdAt;
  String _declaration;
  DateTime _eventDate;
  String _eventName;
  String _id;
  String _instruction;
  String _place;
  String _regAmount;
  String _eventPrefixName;
  List<String> _ageCategory;
  List<String> _rink;
  List<Users> _participants;
  List<ResultModel> _result;
  DateTime _regCloseDate;
  DateTime _regStartDate;
  DateTime _updatedAt;
  bool _visibility;

  PastEventModel({
    required String regAmount,
    required String eventPrefixName,
    required List<String> ageCategory,
    required List<String> rink,
    required List<Users> participants,
    required String advertisement,
    required String bannerImage,
    required bool certificateStatus,
    required DateTime createdAt,
    required String declaration,
    required DateTime eventDate,
    required String eventName,
    required String id,
    required String instruction,
    required String place,
    required DateTime regCloseDate,
    required DateTime regStartDate,
    required DateTime updatedAt,
    required bool visibility,
    required   List<ResultModel> result
  })  : _regAmount = regAmount,
        _eventPrefixName = eventPrefixName,
        _ageCategory = ageCategory,
        _rink = rink,
        _participants = participants,
        _advertisement = advertisement,
        _bannerImage = bannerImage,
        _certificateStatus = certificateStatus,
        _createdAt = createdAt,
        _declaration = declaration,
        _eventDate = eventDate,
        _eventName = eventName,
        _id = id,
        _instruction = instruction,
        _place = place,
        _regCloseDate = regCloseDate,
        _regStartDate = regStartDate,
        _updatedAt = updatedAt,
        _visibility = visibility,
        _result= result;

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
  List<String> get rink => _rink;
  List<Users> get participants => _participants;
  DateTime get regCloseDate => _regCloseDate;
  DateTime get regStartDate => _regStartDate;
  DateTime get updatedAt => _updatedAt;
  bool get visibility => _visibility;

  // Setters
  set advertisement(String advertisement) => _advertisement = advertisement;
  set bannerImage(String bannerImage) => _bannerImage = bannerImage;
  set certificateStatus(bool certificateStatus) =>
      _certificateStatus = certificateStatus;
  set createdAt(DateTime createdAt) => _createdAt = createdAt;
  set declaration(String declaration) => _declaration = declaration;
  set eventDate(DateTime eventDate) => _eventDate = eventDate;
  set eventName(String eventName) => _eventName = eventName;
  set id(String id) => _id = id;
  set instruction(String instruction) => _instruction = instruction;
  set place(String place) => _place = place;
  set regAmount(String regAmount) => _regAmount = regAmount;
  set eventPrefixName(String eventPrefixName) =>
      _eventPrefixName = eventPrefixName;
  set ageCategory(List<String> ageCategory) => _ageCategory = ageCategory;
  set rink(List<String> rink) => _rink = rink;
  set participants(List<Users> participants) => _participants = participants;
  set regCloseDate(DateTime regCloseDate) => _regCloseDate = regCloseDate;
  set regStartDate(DateTime regStartDate) => _regStartDate = regStartDate;
  set updatedAt(DateTime updatedAt) => _updatedAt = updatedAt;
  set visibility(bool visibility) => _visibility = visibility;

  factory PastEventModel.fromJson(Map<dynamic, dynamic> json) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    return PastEventModel(
      regAmount: json['regAmount'] ?? '',
      eventPrefixName: json['eventPrefixName'] ?? '',
      ageCategory: List<String>.from(json['ageCategory'] ?? []),
      rink: List<String>.from(json['rink'] ?? []),
      participants: List<Users>.from(json['participants'] ?? [])
          .map((participant) => Users.fromJson(participant as Map))
          .toList(),
      advertisement: json['advertisement'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
      certificateStatus: json['certificateStatus'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      declaration: json['declaration'] ?? '',
      eventDate: json['eventDate'] != null
          ? dateFormat.parse(json['eventDate']) ?? DateTime.now()
          : DateTime.now(),
      eventName: json['eventName'] ?? '',
      id: json['id'] ?? '',
      instruction: json['instruction'] ?? '',
      place: json['place'] ?? '',
      regCloseDate: json['regCloseDate'] != null
          ? dateFormat.parse(json['regCloseDate']) ?? DateTime.now()
          : DateTime.now(),
      regStartDate: json['regStartDate'] != null
          ? dateFormat.parse(json['regStartDate']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      visibility: json['visibility'] ?? false, result: json['result'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regAmount': _regAmount,
      'eventPrefixName': _eventPrefixName,
      'ageCategory': _ageCategory,
      'rink': _rink,
      'participants': _participants.map((participant) => participant.toJson()).toList(),
      'advertisement': _advertisement,
      'bannerImage': _bannerImage,
      'certificateStatus': _certificateStatus,
      'createdAt': _createdAt.toIso8601String(),
      'declaration': _declaration,
      'eventDate': _eventDate.toIso8601String(),
      'eventName': _eventName,
      'id': _id,
      'instruction': _instruction,
      'place': _place,
      'regCloseDate': _regCloseDate.toIso8601String(),
      'regStartDate': _regStartDate.toIso8601String(),
      'updatedAt': _updatedAt.toIso8601String(),
      'visibility': _visibility,
    };
  }
}
