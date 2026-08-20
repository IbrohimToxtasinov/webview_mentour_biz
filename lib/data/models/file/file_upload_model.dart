class FileUploadModel {
  final String id;
  final String contentType;
  final String path;
  final String name;

  FileUploadModel({
    required this.id,
    required this.contentType,
    required this.path,
    required this.name,
  });

  factory FileUploadModel.fromJson(Map<String, dynamic> json) =>
      FileUploadModel(
        id: json["id"] as String? ?? "",
        contentType: json["contentType"] as String? ?? "",
        path: json["path"] as String? ?? "",
        name: json["name"] as String? ?? "",
      );
}
