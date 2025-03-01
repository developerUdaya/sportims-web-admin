class PaymentReport {
  String id;
  String skaterName;
  String skaterId;
  String orderId;
  String paymentRefId;
  String amount;
  String dateTime;
  String paymentMode;
  String paymentStatus;
  String eventName;
  String eventId;
  String createAt;
  String updatedAt;

  PaymentReport({
    required this.id,
    required this.skaterName,
    required this.skaterId,
    required this.orderId,
    required this.paymentRefId,
    required this.amount,
    required this.dateTime,
    required this.paymentMode,
    required this.paymentStatus,
    required this.eventName,
    required this.eventId,
    required this.createAt,
    required this.updatedAt
  });

  factory PaymentReport.fromJson(Map<String, dynamic> json) {
    return PaymentReport(
      id: json['id'] ?? '',
      skaterName: json['skaterName'] ?? '',
      orderId: json['orderId'] ?? '',
      paymentRefId: json['paymentRefId'] ?? '',
      amount: json['amount'] ?? '',
      dateTime: json['dateTime'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      eventName: json['eventName'] ?? '',
      eventId:  json['eventId'] ?? '',
      skaterId: json['skaterId'] ?? '',
      createAt: json['createAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skaterName': skaterName,
      'orderId': orderId,
      'paymentRefId': paymentRefId,
      'amount': amount,
      'dateTime': dateTime,
      'paymentMode': paymentMode,
      'paymentStatus': paymentStatus,
      'eventName': eventName,
      'skaterId':skaterId,
      'updatedAt':updatedAt,
      'createAt':createAt
    };
  }
}
