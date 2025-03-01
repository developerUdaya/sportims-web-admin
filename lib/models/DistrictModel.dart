class District {
  final String name;
  final String code;
  final String state;

  District({
    required this.name,
    required this.code,
    required this.state
  });
  //
  // factory District.fromJson(Map<dynamic, dynamic> json) {
  //   return District(
  //     name: json['name'],
  //     code: json['code'],
  //     stateName: json['stateName'],
  //   );
  // }
  //
  // Map<String, dynamic> toJson() {
  //   return {
  //     'name': name,
  //     'code': code,
  //     'stateName': stateName,
  //   };
  // }
}
