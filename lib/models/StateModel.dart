
class States {
  final String name;
  final String code;

  States({
    required this.name,
    required this.code,
  });

  factory States.fromJson(Map<dynamic, dynamic> json) {
    return States(
      name: json['name'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
    };
  }

}

