import 'package:mentour_web_view/data/models/homeworks/homework_model.dart';

class HomeworkByLessonModel {
  final String lessonName;
  final String lessonDate;
  final String startTime;
  final String endTime;
  final List<HomeworkModel> units;

  HomeworkByLessonModel({
    required this.lessonName,
    required this.lessonDate,
    required this.startTime,
    required this.endTime,
    required this.units,
  });

  factory HomeworkByLessonModel.fromJson(Map<String, dynamic> json) {
    return HomeworkByLessonModel(
      lessonName: json['lessonName'] as String? ?? "",
      lessonDate: json['lessonDate'] as String? ?? "",
      startTime: json['startTime'] as String? ?? "",
      endTime: json['endTime'] as String? ?? "",
      units: List<HomeworkModel>.from(
        (json['units'] as List? ?? [])
            .map((x) => HomeworkModel.fromJson(x as Map<String, dynamic>))
            .toList(),
      ),
    );
  }
}
