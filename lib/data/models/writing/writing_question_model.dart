class WritingQuestionModel {
  final String taskTitle;
  final int questionCount;
  final String instruction;
  final String taskUuid;
  final List<Question> questions;

  WritingQuestionModel({
    required this.taskTitle,
    required this.questionCount,
    required this.instruction,
    required this.taskUuid,
    required this.questions,
  });

  factory WritingQuestionModel.fromJson(Map<String, dynamic> json) =>
      WritingQuestionModel(
        taskTitle: json["taskTitle"] as String? ?? "",
        questionCount: json["questionCount"] as int? ?? 0,
        instruction: json["instruction"] as String? ?? "",
        taskUuid: json["taskUuid"] as String? ?? "",
        questions: List<Question>.from(
          json["questions"].map((x) => Question.fromJson(x)),
        ),
      );
}

class Question {
  final String questionId;
  final String exerciseId;
  final String type;
  final Content content;
  final String instruction;
  final int coinReward;
  final dynamic preFilledAnswers;
  final String submissionStatus;
  final String studentEssay;
  final String teacherFeedback;

  Question({
    required this.questionId,
    required this.exerciseId,
    required this.type,
    required this.content,
    required this.instruction,
    required this.coinReward,
    required this.preFilledAnswers,
    required this.submissionStatus,
    required this.studentEssay,
    required this.teacherFeedback,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    questionId: json["questionId"] as String? ?? "",
    exerciseId: json["exerciseId"] as String? ?? "",
    type: json["type"] as String? ?? "",
    content: Content.fromJson(json["content"] as Map<String, dynamic>? ?? {}),
    instruction: json["instruction"] as String? ?? "",
    coinReward: json["coinReward"] as int? ?? 0,
    preFilledAnswers: json["preFilledAnswers"] as String? ?? "",
    submissionStatus: json["submissionStatus"] as String? ?? "",
    studentEssay: json["studentEssay"] as String? ?? "",
    teacherFeedback: json["teacherFeedback"] as String? ?? "",
  );
}

class Content {
  final String type;
  final String instruction;
  final String example;
  final String questionContent;
  final String attachmentUrl;
  final String attachmentMediaType;
  final String writingQuestion;
  final int minWords;
  final int deadLine;

  Content({
    required this.type,
    required this.instruction,
    required this.example,
    required this.questionContent,
    required this.attachmentUrl,
    required this.attachmentMediaType,
    required this.writingQuestion,
    required this.minWords,
    required this.deadLine,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    type: json["type"] as String? ?? "",
    instruction: json["instruction"] as String? ?? "",
    example: json["example"] as String? ?? "",
    questionContent: json["questionContent"] as String? ?? "",
    attachmentUrl: json["attachmentUrl"] as String? ?? "",
    attachmentMediaType: json["attachmentMediaType"] as String? ?? "",
    writingQuestion: json["writingQuestion"] as String? ?? "",
    minWords: json["minWords"] as int? ?? 0,
    deadLine: json["deadLine"] as int? ?? 0,
  );
}
