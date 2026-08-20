class ExerciseResultModel {
  final String taskId;
  final String title;
  final int totalQuestions;
  final int correctAnswers;
  final int totalCoinsEarned;
  final int totalScoreEarned;
  final int scorePercentage;
  final List<Question> questions;

  ExerciseResultModel({
    required this.taskId,
    required this.title,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalCoinsEarned,
    required this.totalScoreEarned,
    required this.scorePercentage,
    required this.questions,
  });

  factory ExerciseResultModel.fromJson(Map<String, dynamic> json) =>
      ExerciseResultModel(
        taskId: json["taskId"] as String? ?? "",
        title: json["title"] as String? ?? "",
        totalQuestions: json["totalQuestions"] as int? ?? 0,
        correctAnswers: json["correctAnswers"] as int? ?? 0,
        totalCoinsEarned: json["totalCoinsEarned"] as int? ?? 0,
        totalScoreEarned: json["totalScoreEarned"] as int? ?? 0,
        scorePercentage: json["scorePercentage"] as int? ?? 0,
        questions: List<Question>.from(
          json["questions"].map((x) => Question.fromJson(x)),
        ),
      );
}

class Question {
  final String questionId;
  final String type;
  final int coinReward;
  final bool correct;
  final String explanation;

  Question({
    required this.questionId,
    required this.type,
    required this.coinReward,
    required this.correct,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    questionId: json["questionId"] as String? ?? "",
    type: json["type"] as String? ?? "",
    coinReward: json["coinReward"] as int? ?? 0,
    correct: json["correct"] as bool? ?? false,
    explanation: json["explanation"] as String? ?? "",
  );
}
