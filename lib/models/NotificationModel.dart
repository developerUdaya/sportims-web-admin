class NotificationModel {
  final String message;
  final String time;
  final String title;

  NotificationModel({
    required this.message,
    required this.time,
    required this.title,
  });

  factory NotificationModel.fromJson(Map<dynamic, dynamic> json) {
    return NotificationModel(
      message: json['message'] ?? '',
      time: json['time'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'time': time,
      'title': title,
    };
  }
}