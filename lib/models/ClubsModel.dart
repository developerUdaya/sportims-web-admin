class Club {
  String? id;
  String? clubName;
  String? address;
  String? district;
  String? state;
  String? contactNumber;
  String? email;
  String? password;
  String? coachName;
  String? masterName;
  String? docUrl;
  String? aadharNumber;
  String? regDate;
  String? approval;
  String? username;

  Club({
    this.id,
    this.clubName,
    this.address,
    this.district,
    this.state,
    this.contactNumber,
    this.email,
    this.coachName,
    this.masterName,
    this.docUrl,
    this.aadharNumber,
    this.regDate,
    this.approval,
    this.username,
    this.password
  });


  factory Club.fromJson(Map<String, dynamic> json) => Club(
    id: json['id'],
    clubName: json['clubName'] ?? json['clubname'],
    address: json['address']??'',
    district: json['district']??'',
    state: json['state']??'',
    contactNumber: json['contactNumber'] ?? json['contactnumber'],
    email: json['email'],
    coachName: json['coachName'] ?? json['coachname'],
    masterName: json['masterName'] ?? json['mastername'],
    docUrl: json['docUrl']??"",
    approval: json['approval']??'Not Approved',
    regDate: json['regDate']??DateTime.now().toString(),
    aadharNumber: json['aadharNumber'] ?? json['aadharnumber'] ?? '',
    username:json.containsKey('username')?json['username']:json['id'],
    password:json.containsKey('password')?json['password']:json['id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'clubName': clubName,
    'address': address,
    'district': district,
    'state': state,
    'contactNumber': contactNumber,
    'email': email,
    'coachName': coachName,
    'masterName': masterName,
    'docUrl': docUrl,
    'aadharNumber': aadharNumber,
    'regDate':regDate,
    'approval':approval,
    'password':id,
    'username':username
  };

}
