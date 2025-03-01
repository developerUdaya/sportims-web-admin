import 'package:sport_ims/models/ResultModel.dart';


class EventScheduleModel {
  String id;
  String eventId;
  String eventName;
  String scheduleId;
  String scheduleDate;
  String scheduleTime;
  String gender;
  String skaterCategory;
  String ageCategory;
  String raceCategory;
  List<String> participants;
  List<ResultModel> resultList;

  // Constructor
  EventScheduleModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.scheduleId,
    required this.scheduleDate,
    required this.scheduleTime,
    required this.gender,
    required this.skaterCategory,
    required this.ageCategory,
    required this.raceCategory,
    required this.participants,
    required this.resultList,
  });

  // fromJson method
  factory EventScheduleModel.fromJson(Map<String, dynamic> json) {
    List<ResultModel> resultModelList = [];
    if (json['resultList'] != null && json['resultList'] is List) {
      for (var value in json['resultList']) {
        try {
          ResultModel result = ResultModel.fromJson(Map<String, dynamic>.from(value));
          resultModelList.add(result);
        } catch (e) {
          print('Error parsing ResultModel: $e');
        }
      }
    }

    return EventScheduleModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      scheduleId: json['scheduleId'] as String,
      scheduleDate: json['scheduleDate'] as String,
      scheduleTime: json['scheduleTime'] as String,
      gender: json['gender'] as String,
      skaterCategory: json['skaterCategory'] as String,
      ageCategory: json['ageCategory'] as String,
      raceCategory: json['raceCategory'] as String,
      participants: List<String>.from(json['participants'] ?? []),
      resultList: resultModelList,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventName': eventName,
      'scheduleId': scheduleId,
      'scheduleDate': scheduleDate,
      'scheduleTime': scheduleTime,
      'gender': gender,
      'skaterCategory': skaterCategory,
      'ageCategory': ageCategory,
      'raceCategory': raceCategory,
      'participants': participants,
      'resultList': resultList.map((e) => e.toJson()).toList(),
    };
  }
}