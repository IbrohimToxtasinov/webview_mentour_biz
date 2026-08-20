class VocabularyResultModel {
  final String title;
  final int percentage;
  final int correctCount;
  final int totalCount;
  final int coinsEarned;
  final int totalScoreEarned;
  final List<VocabularyResultWord> words;

  const VocabularyResultModel({
    required this.title,
    required this.percentage,
    required this.correctCount,
    required this.totalCount,
    required this.coinsEarned,
    required this.totalScoreEarned,
    required this.words,
  });

  factory VocabularyResultModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    final wordsJson =
        (json['words'] as List?) ?? (json['items'] as List?) ?? [];
    return VocabularyResultModel(
      title: (json['title'] ?? json['setTitle'] ?? json['name'] ?? '')
          .toString(),
      percentage: asInt(
        json['percentage'] ?? json['scorePercentage'] ?? json['score'],
      ),
      correctCount: asInt(
        json['correct'] ?? json['correctCount'] ?? json['correctAnswers'],
      ),
      totalCount: asInt(
        json['total'] ??
            json['totalCount'] ??
            json['totalQuestions'] ??
            json['questionCount'] ??
            wordsJson.length,
      ),
      coinsEarned: asInt(json['coins'] ?? json['coinsEarned']),
      totalScoreEarned: json["totalScoreEarned"] as int? ?? 0,
      words: wordsJson
          .map(
            (e) =>
                VocabularyResultWord.fromJson(e as Map<String, dynamic>? ?? {}),
          )
          .toList(),
    );
  }
}

class VocabularyResultWord {
  final String word;
  final String translation;
  final bool isCorrect;
  final String userAnswer;
  final String correctAnswer;
  final int coinReward;

  const VocabularyResultWord({
    required this.word,
    required this.translation,
    required this.isCorrect,
    required this.userAnswer,
    required this.correctAnswer,
    required this.coinReward,
  });

  factory VocabularyResultWord.fromJson(Map<String, dynamic> json) {
    return VocabularyResultWord(
      word: (json['word'] ?? json['question'] ?? '').toString(),
      translation: (json['translation'] ?? json['meaning'] ?? '').toString(),
      isCorrect:
          (json['correct'] ?? json['isCorrect'] ?? false) as bool? ?? false,
      userAnswer: (json['userAnswer'] ?? json['answer'] ?? '').toString(),
      correctAnswer: (json['correctAnswer'] ?? json['rightAnswer'] ?? '')
          .toString(),
      coinReward: json["coinReward"] as int? ?? 0,
    );
  }
}
