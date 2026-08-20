class VocabularyWordModel {
  final String uuid;
  final String word;
  final String translation;
  final String definition;
  final List<ResVocabLearnWord> translations;
  final String exampleSentence;
  final String partOfSpeech;
  final String transcription;
  final String audioUrl;
  final String image;

  VocabularyWordModel({
    required this.uuid,
    required this.word,
    required this.translation,
    required this.definition,
    required this.translations,
    required this.exampleSentence,
    required this.partOfSpeech,
    required this.transcription,
    required this.audioUrl,
    required this.image,
  });

  factory VocabularyWordModel.fromJson(Map<String, dynamic> json) =>
      VocabularyWordModel(
        uuid: json["uuid"] as String? ?? "",
        word: json["word"] as String? ?? "",
        translation: json["translation"] as String? ?? "",
        definition: json["definition"] as String? ?? "",
        translations:
            (json["translations"] as List<dynamic>?)
                ?.map(
                  (e) => ResVocabLearnWord.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        exampleSentence: json["exampleSentence"] as String? ?? "",
        partOfSpeech: json["partOfSpeech"] as String? ?? "",
        transcription: json["transcription"] as String? ?? "",
        audioUrl: json["audioUrl"] as String? ?? "",
        image: json["image"] as String? ?? "",
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
