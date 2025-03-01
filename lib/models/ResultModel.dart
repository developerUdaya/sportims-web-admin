class ResultModel {
  String resultId;
  String skaterName;
  String skaterId;
  String ageCategory;
  String skaterCategory;
  String certificateNumber;
  String chestNumber;
  String eventId;
  String eventName;
  String certificateUrl;
  List<CategoryResultModel> categoryResultModel;
  String createdAt;
  String updatedAt;
  String published;

  ResultModel({
    required this.resultId,
    required this.skaterName,
    required this.skaterId,
    required this.ageCategory,
    required this.skaterCategory,
    required this.certificateNumber,
    required this.chestNumber,
    required this.eventId,
    required this.eventName,
    required this.certificateUrl,
    required this.categoryResultModel,
    required this.createdAt,
    required this.updatedAt,
    required this.published
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    List<CategoryResultModel> categoryResultModelList = [];
    if (json['categoryResultModel'] != null && json['categoryResultModel'] is List) {
      for (var value in json['categoryResultModel']) {
        try {
          CategoryResultModel categoryResult = CategoryResultModel.fromJson(Map<String, dynamic>.from(value));
          categoryResultModelList.add(categoryResult);
        } catch (e) {
          print('Error parsing CategoryResultModel: $e');
        }
      }
    }

    return ResultModel(
      resultId: json['resultId'] as String,
      skaterName: json['skaterName'] as String,
      skaterId: json['skaterId'] as String,
      ageCategory: json['ageCategory'] as String,
      skaterCategory: json['skaterCategory'] as String,
      certificateNumber: json['certificateNumber'] as String,
      chestNumber: json['chestNumber'] as String,
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      certificateUrl: json['certificateUrl'] as String,
      categoryResultModel: categoryResultModelList,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      published: json.containsValue("published")?json['published'] as String:"",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resultId': resultId,
      'skaterName': skaterName,
      'skaterId': skaterId,
      'ageCategory': ageCategory,
      'skaterCategory': skaterCategory,
      'certificateNumber': certificateNumber,
      'chestNumber': chestNumber,
      'eventId': eventId,
      'eventName': eventName,
      'certificateUrl': certificateUrl,
      'categoryResultModel': categoryResultModel.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'published' : published
    };
  }
}

class CategoryResultModel {
  String H1;
  String H2;
  String H3;
  String SF;
  String F;
  String result;
  String raceCategory;
  String eventScheduleId;
  String createdAt;
  String updatedAt;

  CategoryResultModel({
    required this.H1,
    required this.H2,
    required this.H3,
    required this.SF,
    required this.F,
    required this.result,
    required this.raceCategory,
    required this.eventScheduleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryResultModel.fromJson(Map<String, dynamic> json) {
    return CategoryResultModel(
      H1: json['H1'] as String,
      H2: json['H2'] as String,
      H3: json['H3'] as String,
      SF: json['SF'] as String,
      F: json['F'] as String,
      result: json['result'] as String,
      raceCategory: json['raceCategory'] as String,
      eventScheduleId: json['eventScheduleId'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'H1': H1,
      'H2': H2,
      'H3': H3,
      'SF': SF,
      'F': F,
      'result': result,
      'raceCategory': raceCategory,
      'eventScheduleId': eventScheduleId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

}
