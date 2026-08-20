class VocabularyModel {
  final String uuid;
  final int sortOrder;
  final String title;
  final int questionCount;
  final int percentage;
  final bool answeredAll;

  VocabularyModel({
    required this.uuid,
    required this.sortOrder,
    required this.title,
    required this.questionCount,
    required this.percentage, required this.answeredAll,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) =>
      VocabularyModel(
        uuid: json["uuid"] as String? ?? "",
        sortOrder: json["sortOrder"] as int? ?? 0,
        title: json["title"] as String? ?? "",
        questionCount: json["questionCount"] as int? ?? 0,
        percentage: json["percentage"] as int? ?? 0,
        answeredAll: json["answeredAll"] as bool? ?? false,
      );
}
