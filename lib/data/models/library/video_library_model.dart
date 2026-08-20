import 'package:mentour_web_view/data/models/profile/profile_model.dart';

class VideoLibraryModel {
  final String itemUuid;
  final String title;
  final String description;
  final String type;
  final String contentUrl;
  final LevelModel level;
  final bool global;

  VideoLibraryModel({
    required this.itemUuid,
    required this.title,
    required this.description,
    required this.type,
    required this.contentUrl,
    required this.level,
    required this.global,
  });

  factory VideoLibraryModel.fromJson(Map<String, dynamic> json) =>
      VideoLibraryModel(
        itemUuid: json["itemUuid"] as String? ?? "",
        title: json["title"] as String? ?? "",
        description: json["description"] as String? ?? "",
        type: json["type"] as String? ?? "",
        contentUrl: json["contentUrl"] as String? ?? "",
        level: LevelModel.fromJson(
          json["level"] as Map<String, dynamic>? ?? {},
        ),
        global: json["global"] as bool? ?? true,
      );
}
