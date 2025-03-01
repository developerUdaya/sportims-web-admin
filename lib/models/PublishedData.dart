class PublishData {
  String skaterId;
  String scheduleId;
  bool published;

  PublishData({
    required this.skaterId,
    required this.scheduleId,
    required this.published,
  });

  factory PublishData.fromJson(Map<String, dynamic> json) {
    return PublishData(
      skaterId: json['skaterId'] as String,
      scheduleId: json['scheduleId'] as String,
      published: json['published'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skaterId': skaterId,
      'scheduleId': scheduleId,
      'published': published,
    };
  }
}
