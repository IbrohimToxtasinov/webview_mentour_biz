class AttendanceModel {
  final String lessonName;
  final String lessonDate;
  final String status;
  final bool isMarked;

  AttendanceModel({
    required this.lessonName,
    required this.lessonDate,
    required this.status,
    required this.isMarked,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        lessonName: json["lessonName"] as String? ?? "",
        lessonDate: json["lessonDate"] as String? ?? "",
        status: json["status"] as String? ?? "",
        isMarked: json["isMarked"] as bool? ?? false,
      );
}
