class PaymentModel {
  final String uuid;
  final String studentUuid;
  final String studentFullName;
  final String courseUuid;
  final String courseName;
  final int lessonsToCharge;
  final int pricePerLesson;
  final int totalAmount;
  final String status;
  final String ofdUrl;
  final String createdAt;
  final String paidAt;

  PaymentModel({
    required this.uuid,
    required this.studentUuid,
    required this.studentFullName,
    required this.courseUuid,
    required this.courseName,
    required this.lessonsToCharge,
    required this.pricePerLesson,
    required this.totalAmount,
    required this.status,
    required this.ofdUrl,
    required this.createdAt,
    required this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    uuid: json["uuid"] as String? ?? "",
    studentUuid: json["studentUuid"] as String? ?? "",
    studentFullName: json["studentFullName"] as String? ?? "",
    courseUuid: json["courseUuid"] as String? ?? "",
    courseName: json["courseName"] as String? ?? "",
    lessonsToCharge: json["lessonsToCharge"] as int? ?? 0,
    pricePerLesson: json["pricePerLesson"] as int? ?? 0,
    totalAmount: json["totalAmount"] as int? ?? 0,
    status: json["status"] as String? ?? "",
    ofdUrl: json["ofdUrl"] as String? ?? "",
    createdAt: json["createdAt"] as String? ?? "",
    paidAt: json["paidAt"] as String? ?? "",
  );
}
