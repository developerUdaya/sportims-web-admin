class EventOfficialModel {
  String id;
  String officialName;
  String userName;
  String password;
  String eventName;
  String eventId;
  String content;
  String imgUrl;
  String createdAt;
  String updatedAt;
  bool cetificateStatus;
  bool deleteStatus;

  EventOfficialModel({
    required this.id,
    required this.officialName,
    required this.userName,
    required this.password,
    required this.eventId,
    required this.eventName,
    required this.content,
    required this.imgUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.cetificateStatus,
    this.deleteStatus=false
  });

  factory EventOfficialModel.fromJson(Map<String, dynamic> json) {

    try {
      return EventOfficialModel(
        id: json['id'] ?? '',
        userName: json['userName'] ?? '',
        password: json['password'] ?? '',
        eventId: json['eventId'] ?? '',
        eventName: json['eventName'] ?? '',
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
        officialName: json['officialName'] ?? '',
        content: json['content'] ?? '',
        imgUrl: json['imgUrl'] ?? '',
        cetificateStatus: json['cetificateStatus'] ?? false,
        deleteStatus: json['deleteStatus']??false,
      );
    } catch (e) {
      print('Error in fromJson: $e');
      throw e;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'officialName': officialName,
      'userName': userName,
      'password': password,
      'eventId': eventId,
      'eventName': eventName,
      'content': content,
      'imgUrl': imgUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'cetificateStatus' : cetificateStatus
    };
  }
}
