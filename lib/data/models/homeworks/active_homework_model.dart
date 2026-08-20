import 'package:mentour_web_view/data/models/homeworks/homework_model.dart';

class ActiveHomeworkGroup {
  final String groupUuid;
  final String groupName;
  final List<HomeworkModel> activeHomeworks;

  ActiveHomeworkGroup({
    required this.groupUuid,
    required this.groupName,
    required this.activeHomeworks,
  });

  factory ActiveHomeworkGroup.fromJson(Map<String, dynamic> json) =>
      ActiveHomeworkGroup(
        groupUuid: json["groupUuid"]?.toString() ?? "",
        groupName: json["groupName"]?.toString() ?? "",
        activeHomeworks: List<HomeworkModel>.from(
          (json["activeHomeworks"] as List? ?? [])
              .map((x) => HomeworkModel.fromJson(x)),
        ),
      );
}
