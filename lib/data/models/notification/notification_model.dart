class NotificationModel {
  int id;
  String title;
  String content;
  String targetType;
  String targetUuid;
  String createdBy;
  bool read;
  String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.targetType,
    required this.targetUuid,
    required this.createdBy,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"] as int? ?? 0,
        title: json["title"] as String? ?? "",
        content: json["content"] as String? ?? "",
        targetType: json["targetType"] as String? ?? "",
        targetUuid: json["targetUuid"] as String? ?? "",
        createdBy: json["createdBy"] as String? ?? "",
        read: json["read"] as bool? ?? false,
        createdAt: json["createdAt"] as String? ?? "",
      );
}
