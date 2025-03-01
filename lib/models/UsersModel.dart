class Users {

  String _skaterID;
  String _name;
  String _address;
  String _state;
  String _district;
  String _school;
  String _schoolAffiliationNumber;
  String _club;
  String _email;
  String _contactNumber;
  String _bloodGroup;
  String _gender;
  String _skateCategory;
  String _aadharBirthCertificateNumber;
  String _dateOfBirth;
  String _profileImageUrl;
  String _docFileUrl;
  String _regDate;
  String _approval;

  Users({
    required String skaterID,
    required String name,
    required String address,
    required String state,
    required String district,
    required String school,
    required String schoolAffiliationNumber,
    required String club,
    required String email,
    required String contactNumber,
    required String bloodGroup,
    required String gender,
    required String skateCategory,
    required String aadharBirthCertificateNumber,
    required String dateOfBirth,
    required String profileImageUrl,
    required String docFileUrl,
    required String regDate,
    required String approval
  })  :
        _skaterID = skaterID,
        _name = name,
        _address = address,
        _state = state,
        _district = district,
        _school = school,
        _schoolAffiliationNumber = schoolAffiliationNumber,
        _club = club,
        _email = email,
        _contactNumber = contactNumber,
        _bloodGroup = bloodGroup,
        _gender = gender,
        _skateCategory = skateCategory,
        _aadharBirthCertificateNumber = aadharBirthCertificateNumber,
        _dateOfBirth = dateOfBirth,
        _profileImageUrl = profileImageUrl,
        _docFileUrl = docFileUrl,
        _regDate = regDate,
        _approval = approval;



  // Getters and setters
  String get skaterID => _skaterID;
  set skaterID(String skaterID) => _skaterID = skaterID;

  String get name => _name;
  set name(String name) => _name = name;

  String get address => _address;
  set address(String address) => _address = address;

  String get state => _state;
  set state(String state) => _state = state;

  String get district => _district;
  set district(String district) => _district = district;

  String get school => _school;
  set school(String school) => _school = school;

  String get schoolAffiliationNumber => _schoolAffiliationNumber;
  set schoolAffiliationNumber(String schoolAffiliationNumber) => _schoolAffiliationNumber = schoolAffiliationNumber;

  String get club => _club;
  set club(String club) => _club = club;

  String get email => _email;
  set email(String email) => _email = email;

  String get contactNumber => _contactNumber;
  set contactNumber(String contactNumber) => _contactNumber = contactNumber;

  String get bloodGroup => _bloodGroup;
  set bloodGroup(String bloodGroup) => _bloodGroup = bloodGroup;

  String get gender => _gender;
  set gender(String gender) => _gender = gender;

  String get skateCategory => _skateCategory;
  set skateCategory(String skateCategory) => _skateCategory = skateCategory;

  String get aadharBirthCertificateNumber => _aadharBirthCertificateNumber;
  set aadharBirthCertificateNumber(String aadharBirthCertificateNumber) => _aadharBirthCertificateNumber = aadharBirthCertificateNumber;

  String get dateOfBirth => _dateOfBirth;
  set dateOfBirth(String dateOfBirth) => _dateOfBirth = dateOfBirth;

  String get profileImageUrl => _profileImageUrl;
  set profileImageUrl(String profileImageUrl) => _profileImageUrl = profileImageUrl;

  String get docFileUrl => _docFileUrl;
  set docFileUrl(String docFileUrl) => _docFileUrl = docFileUrl;

  String get regDate => _regDate;
  set regDate(String regDate) => _regDate = regDate;

  String get approval => _approval;
  set approval(String approval) => _approval = approval;


  // Convert instance to Map
  Map<String, dynamic> toMap() {
    return {
      'skaterID': _skaterID,
      'name': _name,
      'address': _address,
      'state': _state,
      'district': _district,
      'school': _school,
      'schoolAffiliationNumber': _schoolAffiliationNumber,
      'club': _club,
      'email': _email,
      'contactNumber': _contactNumber,
      'bloodGroup': _bloodGroup,
      'gender': _gender,
      'skateCategory': _skateCategory,
      'aadharBirthCertificateNumber': _aadharBirthCertificateNumber,
      'dateOfBirth': _dateOfBirth,
      'profileImageUrl': _profileImageUrl,
      'docFileUrl': _docFileUrl,
      'regDate': _regDate,
      'approval': _approval,
    };
  }

  // Factory constructor to create an instance from JSON
  factory Users.fromJson(Map<dynamic, dynamic> json) {
    return Users(
      skaterID: json['skaterID'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      school: json['school'] ?? '',
      schoolAffiliationNumber: json['schoolAffiliationNumber'] ?? '',
      club: json['club'] ?? '',
      email: json['email'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      gender: json['gender'] ?? '',
      skateCategory: json['skateCategory'] ?? '',
      aadharBirthCertificateNumber: json['aadharBirthCertificateNumber'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      docFileUrl: json['docFileUrl'] ?? '',
      regDate: json['regDate'] ?? DateTime.now().toString().substring(0,10),
      approval: json['approval'] ?? 'Not approved',
    );
  }

  // Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'skaterID': _skaterID,
      'name': _name,
      'address': _address,
      'state': _state,
      'district': _district,
      'school': _school,
      'schoolAffiliationNumber': _schoolAffiliationNumber,
      'club': _club,
      'email': _email,
      'contactNumber': _contactNumber,
      'bloodGroup': _bloodGroup,
      'gender': _gender,
      'skateCategory': _skateCategory,
      'aadharBirthCertificateNumber': _aadharBirthCertificateNumber,
      'dateOfBirth': _dateOfBirth,
      'profileImageUrl': _profileImageUrl,
      'docFileUrl': _docFileUrl,
      'regDate': _regDate,
      'approval': _approval,
    };
  }
}
