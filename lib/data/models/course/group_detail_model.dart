import 'package:mentour_web_view/data/models/product/product_model.dart';

class GroupDetailModel {
  final String studentUuid;
  final String fullName;
  final Attachment attachment;
  final int attendancePercentage;
  final int resultPercentage;

  GroupDetailModel({
    required this.studentUuid,
    required this.fullName,
    required this.attachment,
    required this.attendancePercentage,
    required this.resultPercentage,
  });

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) =>
      GroupDetailModel(
        studentUuid: json["studentUuid"] as String? ?? "",
        fullName: json["fullName"] as String? ?? "",
        attachment: Attachment.fromJson(
          json["attachment"] as Map<String, dynamic>? ?? {},
        ),
        attendancePercentage: json["attendancePercentage"] as int? ?? 0,
        resultPercentage: json["resultPercentage"] as int? ?? 0,
      );
}
