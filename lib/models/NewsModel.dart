class NewsModel {
  String id;
  String title;
  String subtitle;
  String date;
  String content;
  String createdAt;
  String updatedAt;
  bool deleteStatus;
  String imgUrl;

  NewsModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.deleteStatus = false,
    required this.imgUrl,
  });

  // To map NewsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'date': date,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deleteStatus': deleteStatus,
      'imgUrl': imgUrl,
    };
  }

  // From JSON to NewsModel
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      date: json['date'],
      content: json['content'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deleteStatus: json['deleteStatus'],
      imgUrl: json['imgUrl'],
    );
  }
}
