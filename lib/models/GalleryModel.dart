class GalleryModel {
  String id;
  String title;
  String altText;
  String imgUrl;
  bool deleteStatus;

  GalleryModel({
    required this.id,
    required this.title,
    required this.altText,
    required this.imgUrl,
    this.deleteStatus = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'altText': altText,
      'imgUrl': imgUrl,
      'deleteStatus': deleteStatus,
    };
  }

  factory GalleryModel.fromJson(Map<String, dynamic> json) {
    return GalleryModel(
      id: json['id'],
      title: json['title'],
      altText: json['altText'],
      imgUrl: json['imgUrl'],
      deleteStatus: json['deleteStatus'],
    );
  }
}
