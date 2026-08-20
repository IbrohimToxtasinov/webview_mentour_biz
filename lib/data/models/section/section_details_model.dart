class SectionDetailsModel {
  final String type;
  final List<Task> tasks;

  SectionDetailsModel({required this.type, required this.tasks});

  factory SectionDetailsModel.fromJson(Map<String, dynamic> json) =>
      SectionDetailsModel(
        type: json["type"] as String? ?? "",
        tasks: List<Task>.from(json["tasks"].map((x) => Task.fromJson(x))),
      );
}

class Task {
  final String id;
  final String title;
  final int sortOrder;
  final int totalQuestions;
  final int percentages;
  final String topic;
  final String lessonSectionType;
  final String exerciseSubType;
  final List<ResWriting> resWriting;
  final List<ResSpeaking> resSpeaking;
  final bool answeredAll;
  final bool limitInstalled;
  final int attempts;

  Task({
    required this.id,
    required this.title,
    required this.sortOrder,
    required this.totalQuestions,
    required this.percentages,
    required this.topic,
    required this.lessonSectionType,
    required this.resWriting,
    required this.resSpeaking,
    required this.exerciseSubType,
    required this.answeredAll,
    required this.limitInstalled,
    required this.attempts,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json["id"] as String? ?? "",
    title: json["title"] as String? ?? "",
    sortOrder: json["sortOrder"] as int? ?? 0,
    totalQuestions: json["totalQuestions"] as int? ?? 0,
    percentages: json["percentages"] as int? ?? 0,
    topic: json["topic"] as String? ?? "",
    lessonSectionType: json["lessonSectionType"] as String? ?? "",
    exerciseSubType: json["exerciseSubType"] as String? ?? "",
    answeredAll: json["answeredAll"] as bool? ?? false,
    resWriting: json["resWriting"] != null
        ? List<ResWriting>.from(
      (json["resWriting"] as List).map((x) => ResWriting.fromJson(x)),
    )
        : [],
    resSpeaking: json["resSpeaking"] != null
        ? List<ResSpeaking>.from(
      (json["resSpeaking"] as List).map((x) => ResSpeaking.fromJson(x)),
    )
        : [],
    limitInstalled: json["limitInstalled"] as bool? ?? false,
    attempts: json["attempts"] as int? ?? 0,
  );
}

class ResWriting {
  final String studentAnswer;
  final String previousFeedback;
  final int coinsAwarded;
  final int scoreReward;
  final int score;
  final String status;

  ResWriting({
    required this.studentAnswer,
    required this.previousFeedback,
    required this.coinsAwarded,
    required this.scoreReward,
    required this.score,
    required this.status,
  });

  factory ResWriting.fromJson(Map<String, dynamic> json) => ResWriting(
    studentAnswer: json["studentAnswer"] as String? ?? "",
    previousFeedback: json["previousFeedback"] as String? ?? "",
    coinsAwarded: json["coinsAwarded"] as int? ?? 0,
    scoreReward: json["scoreReward"] as int? ?? 0,
    score: json["score"] as int? ?? 0,
    status: json["status"] as String? ?? "",
  );
}

class ResSpeaking {
  final ResExerciseQuestion resExerciseQuestion;
  final String studentAudioUrl;
  final Scores scores;
  final List<String> feedbackBullets;
  final String status;
  final int attempts;
  final AiResponse aiResponse;

  ResSpeaking({
    required this.resExerciseQuestion,
    required this.studentAudioUrl,
    required this.scores,
    required this.feedbackBullets,
    required this.status,
    required this.attempts,
    required this.aiResponse,
  });

  factory ResSpeaking.fromJson(Map<String, dynamic> json) => ResSpeaking(
    resExerciseQuestion: ResExerciseQuestion.fromJson(
      json["resExerciseQuestion"] as Map<String, dynamic>? ?? {},
    ),
    studentAudioUrl: json["studentAudioUrl"] as String? ?? "",
    scores: Scores.fromJson(json["scores"] as Map<String, dynamic>? ?? {}),
    feedbackBullets: json["feedbackBullets"] != null
        ? List<String>.from(json["feedbackBullets"].map((x) => x))
        : [],
    status: json["status"] as String? ?? "",
    attempts: json["attempts"] as int? ?? 0,
    aiResponse: AiResponse.fromJson(
      json["aiResponse"] as Map<String, dynamic>? ?? {},
    ),
  );
}

class Scores {
  final int grammarScore;
  final int vocabularyScore;
  final int coherenceScore;
  final int overallScore;

  Scores({
    required this.grammarScore,
    required this.vocabularyScore,
    required this.coherenceScore,
    required this.overallScore,
  });

  factory Scores.fromJson(Map<String, dynamic> json) => Scores(
    grammarScore: json["grammarScore"] as int? ?? 0,
    vocabularyScore: json["vocabularyScore"] as int? ?? 0,
    coherenceScore: json["coherenceScore"] as int? ?? 0,
    overallScore: json["overallScore"] as int? ?? 0,
  );
}

class ResExerciseQuestion {
  final String uuid;
  final String type;
  final Content content;
  final int coinReward;
  final int scoreReward;

  ResExerciseQuestion({
    required this.uuid,
    required this.type,
    required this.content,
    required this.coinReward,
    required this.scoreReward,
  });

  factory ResExerciseQuestion.fromJson(Map<String, dynamic> json) =>
      ResExerciseQuestion(
        uuid: json["uuid"] as String? ?? "",
        type: json["type"] as String? ?? "",
        content: Content.fromJson(
          json["content"] as Map<String, dynamic>? ?? {},
        ),
        coinReward: json["coinReward"] as int? ?? 0,
        scoreReward: json["scoreReward"] as int? ?? 0,
      );
}

class Content {
  final String type;
  final String instruction;
  final dynamic example;
  final dynamic questionContent;
  final dynamic attachmentUrl;
  final dynamic attachmentMediaType;
  final String targetWord;
  final String maxTries;

  Content({
    required this.type,
    required this.instruction,
    required this.example,
    required this.questionContent,
    required this.attachmentUrl,
    required this.attachmentMediaType,
    required this.targetWord,
    required this.maxTries,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    type: json["type"] as String? ?? "",
    instruction: json["instruction"] as String? ?? "",
    example: json["example"] as String? ?? "",
    questionContent: json["questionContent"] as String? ?? "",
    attachmentUrl: json["attachmentUrl"] as String? ?? "",
    attachmentMediaType: json["attachmentMediaType"] as String? ?? "",
    targetWord: json["targetWord"] as String? ?? "",
    maxTries: json["maxTries"] as String? ?? "",
  );
}

class AiResponse {
  final String wordRequested;
  final int totalWords;
  final List<ProcessedWord> processedWords;

  AiResponse({
    required this.wordRequested,
    required this.totalWords,
    required this.processedWords,
  });

  factory AiResponse.fromJson(Map<String, dynamic> json) => AiResponse(
    wordRequested: json["word_requested"] as String? ?? "",
    totalWords: json["total_words"] as int? ?? 0,
    processedWords: (json["processed_words"] as List? ?? [])
        .map((x) => ProcessedWord.fromJson(x))
        .toList(),
  );
}

class ProcessedWord {
  final String word;
  final PronunciationAssessment pronunciationAssessment;
  final List<Syllable> syllables;

  ProcessedWord({
    required this.word,
    required this.pronunciationAssessment,
    required this.syllables,
  });

  factory ProcessedWord.fromJson(Map<String, dynamic> json) => ProcessedWord(
    word: json["Word"] as String? ?? "",
    pronunciationAssessment: PronunciationAssessment.fromJson(
      json["PronunciationAssessment"] as Map<String, dynamic>? ?? {},
    ),
    syllables: (json["Syllables"] as List? ?? [])
        .map((x) => Syllable.fromJson(x))
        .toList(),
  );
}

class PronunciationAssessment {
  final double accuracyScore;

  PronunciationAssessment({required this.accuracyScore});

  factory PronunciationAssessment.fromJson(Map<String, dynamic> json) =>
      PronunciationAssessment(
        accuracyScore: json["AccuracyScore"] as double? ?? 0,
      );
}

class Syllable {
  final String syllable;
  final String grapheme;
  final PronunciationAssessment pronunciationAssessment;

  Syllable({
    required this.syllable,
    required this.grapheme,
    required this.pronunciationAssessment,
  });

  factory Syllable.fromJson(Map<String, dynamic> json) => Syllable(
    syllable: json["Syllable"] as String? ?? "",
    grapheme: json["Grapheme"] as String? ?? "",
    pronunciationAssessment: PronunciationAssessment.fromJson(
      json["PronunciationAssessment"] as Map<String, dynamic>? ?? {},
    ),
  );
}
