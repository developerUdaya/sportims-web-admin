class EventOrganiser {
  String id;
  String name;
  String userName;
  String password;
  String eventId;
  String eventName;
  String createdAt;
  String updatedAt;
  String approval;
  bool deleteStatus;

  EventOrganiser({
    required this.id,
    required this.name,
    required this.userName,
    required this.password,
    required this.eventId,
    required this.eventName,
    required this.createdAt,
    required this.updatedAt,
    required this.approval,
    this.deleteStatus=false
  });

  factory EventOrganiser.fromJson(Map<String, dynamic> json) {
    try {
      return EventOrganiser(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        userName: json['userName'] ?? '',
        password: json['password'] ?? '',
        eventId: json['eventId'] ?? '',
        eventName: json['eventName'] ?? '',
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
        approval: json['approval'] ?? 'Pending',
        deleteStatus: json['deleteStatus'] ?? false,
      );
    } catch (e) {
      print('Error in fromJson: $e');
      throw e;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userName': userName,
      'password': password,
      'eventId': eventId,
      'eventName': eventName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'approval': approval,
      'deleteStatus':deleteStatus
    };
  }
}
