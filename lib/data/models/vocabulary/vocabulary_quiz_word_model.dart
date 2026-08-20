class VocabularyQuizWordModel {
  final String wordUuid;
  final String setUuid;
  final List<ResVocabLearnWord> translations;
  final String word;
  final String partOfSpeech;
  final String image;
  final String audioUrl;

  VocabularyQuizWordModel({
    required this.wordUuid,
    required this.setUuid,
    required this.translations,
    required this.word,
    required this.partOfSpeech,
    required this.image,
    required this.audioUrl,
  });

  factory VocabularyQuizWordModel.fromJson(Map<String, dynamic> json) =>
      VocabularyQuizWordModel(
        wordUuid: json["wordUuid"] as String? ?? "",
        setUuid: json["setUuid"] as String? ?? "",
        translations:
            (json["translations"] as List<dynamic>?)
                ?.map(
                  (e) => ResVocabLearnWord.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        word: json["word"] as String? ?? "",
        partOfSpeech: json["partOfSpeech"] as String? ?? "",
        image: json["image"] as String? ?? "",
        audioUrl: json["audioUrl"] as String? ?? "",
      );
}

class ResVocabLearnWord {
  final String lang;
  final String value;
  final bool primary;

  ResVocabLearnWord({
    required this.lang,
    required this.value,
    required this.primary,
  });

  factory ResVocabLearnWord.fromJson(Map<String, dynamic> json) {
    return ResVocabLearnWord(
      lang: json["lang"] as String? ?? "",
      value: json["value"] as String? ?? "",
      primary: json["primary"] as bool? ?? false,
    );
  }
}
