import 'package:intl/intl.dart';

class EventRegistrationModel {
  final String userId;
  final String eventId;
  final DateTime registrationDate;
  final bool paymentStatus;
  final String paymentId;

  EventRegistrationModel({
    required this.userId,
    required this.eventId,
    required this.registrationDate,
    required this.paymentStatus,
    required this.paymentId,
  });

  factory EventRegistrationModel.fromJson(Map<dynamic, dynamic> json) {
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    return EventRegistrationModel(
      userId: json['userId'] ?? '',
      eventId: json['eventId'] ?? '',
      registrationDate: json['registrationDate'] != null
          ? dateFormat.parse(json['registrationDate']) ?? DateTime.now()
          : DateTime.now(),
      paymentStatus: json['paymentStatus'] ?? false,
      paymentId: json['paymentId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventId': eventId,
      'registrationDate': registrationDate.toIso8601String(),
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
    };
  }
}
