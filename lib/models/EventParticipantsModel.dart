class EventParticipantsModel {
  String id;
  String skaterId;
  String chestNumber;
  String name;
  String age;
  String dob;
  String gender;
  String eventName;
  String state;
  String district;
  String club;
  String eventID;
  String skaterCategory;
  String imgUrl;
  List<String> raceCategory;
  String paymentStatus;
  String paymentAmount;
  String paymentId;
  String paymentOrderId;
  String paymentMode;
  String createdAt;
  bool deleteStatus;

  // Constructor
  EventParticipantsModel({
    required this.id,
    required this.skaterId,
    required this.chestNumber,
    required this.name,
    required this.age,
    required this.dob,
    required this.gender,
    required this.imgUrl,
    required this.eventName,
    required this.eventID,
    required this.skaterCategory,
    required this.raceCategory,
    required this.paymentStatus,
    required this.paymentAmount,
    required this.paymentId,
    required this.paymentOrderId,
    required this.paymentMode,
    required this.createdAt,
    required this.club,
    required this.district,
    required this.state,
    this.deleteStatus =false

  });

  // fromJson method
  factory EventParticipantsModel.fromJson(Map<dynamic, dynamic> json) {
    return EventParticipantsModel(
      id: json['id'] ?? '',
      skaterId: json['skaterId'] ?? '',
      chestNumber: json['chestNumber'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? '',
      dob: json['dob'] ?? '',
      eventName: json['eventName'] ?? '',
      eventID: json['eventID'] ?? '',
      skaterCategory: json['skaterCategory'] ?? '',
      raceCategory: List<String>.from(json['raceCategory'] ?? []),
      paymentStatus: json['paymentStatus'] ?? '',
      paymentAmount: json['paymentAmount'] ?? '',
      paymentId: json['paymentId'] ?? '',
      paymentOrderId: json['paymentOrderId'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      createdAt: json['createdAt'] ?? '',
      gender: json['gender'] ?? 'Male',
      club: json['club'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
        imgUrl: json['imgUrl']??"",
        deleteStatus: json['deleteStatus']??false
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skaterId': skaterId,
      'chestNumber': chestNumber,
      'name': name,
      'age': age,
      'dob': dob,
      'eventName': eventName,
      'gender':gender,
      'eventID': eventID,
      'skaterCategory': skaterCategory,
      'raceCategory': raceCategory,
      'paymentStatus': paymentStatus,
      'paymentAmount': paymentAmount,
      'paymentId': paymentId,
      'paymentOrderId': paymentOrderId,
      'paymentMode': paymentMode,
      'createdAt': createdAt,
      'club':club,
      'district':district,
      'state' : state,
      'imgUrl':imgUrl,
      'deleteStatus':deleteStatus
    };
  }
}
