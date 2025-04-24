class StateSecretaryModel{
  String id;
  String name;
  String address;
  String contactNumber;
  String email;
  String adharNumber;
  String docUrl;
  String stateName;
  String regDate;
  String approval;
  String createdAt;
  String updatedAt;
  String societyCertNumber;
  String societyCertUrl;
  String password;

  StateSecretaryModel(
  { required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.email,
    required this.adharNumber,
    required this.docUrl,
    required this.stateName,
    required this.regDate,
    required this.approval,
    required this.createdAt,
    required this.updatedAt,
    required this.password,
    required this.societyCertNumber,
    required this.societyCertUrl
  });

  factory StateSecretaryModel.fromJson(Map<String, dynamic> json) =>
      StateSecretaryModel(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        contactNumber: json['contactNumber'],
        email: json['email'],
        adharNumber: json['adharNumber'],
        docUrl: json['docUrl'],
        stateName: json['stateName']??'',
        regDate: json['regDate']??'',
        createdAt: json['createdAt']??'',
        updatedAt: json['updatedAt']??'',
        approval: json['approval']??'',
        password: json['password']??'',
        societyCertNumber: json['societyCertNumber']??'',
        societyCertUrl: json['societyCertUrl']??'',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'contactNumber': contactNumber,
    'email': email,
    'adharNumber': adharNumber,
    'docUrl': docUrl,
    'stateName': stateName,
    'regDate': regDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'approval':approval,
    'societyCertUrl':societyCertUrl,
    'societyCertNumber':societyCertNumber,
    'password':password
  };
}