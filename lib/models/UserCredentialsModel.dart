class UserCredentials{
  String? username;
  String? password;
  String? name;
  String? mobileNumber;
  String? role;
  String? eventId;
  bool? status;
  String? createdAt;
  List<String>? accessLog;

  // Named constructor
  UserCredentials({
    this.username,
    this.password,
    this.name,
    this.mobileNumber,
    this.role,
    this.status,
    this.createdAt,
    this.accessLog,
    this.eventId
  });

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'mobileNumber': mobileNumber,
      'role': role,
      'status': status,
      'createdAt': createdAt,
      'accessLog': accessLog,
      'eventId':eventId
    };
  }

  factory UserCredentials.fromJson(Map<dynamic,dynamic> json){
    return UserCredentials(
      name: json['name']??"",
      role: json['role']??"",
      mobileNumber: json['mobileNumber'] ?? '',
      eventId :json['eventId']??'',
      password: json['password']??"",
      username: json['username']??"",
      accessLog: [],
      status: json['status']??false,
      createdAt: json['createdAt']??""
    );
  }
}