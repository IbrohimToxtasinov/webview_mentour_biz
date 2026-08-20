class TaskDetailModel {
  final String taskTitle;
  final String questionCount;
  final List<Question> questions;

  TaskDetailModel({
    required this.taskTitle,
    required this.questionCount,
    required this.questions,
  });

  factory TaskDetailModel.fromJson(Map<String, dynamic> json) =>
      TaskDetailModel(
        taskTitle: json["taskTitle"] as String? ?? "",
        questionCount: json["questionCount"] as String? ?? "",
        questions: List<Question>.from(
          json["questions"].map((x) => Question.fromJson(x)),
        ),
      );
}

class Question {
  final String questionId;
  final String type;
  final Content content;
  final int coinReward;
  final dynamic resQuestionsTasks;
  final dynamic preFilledAnswers;

  Question({
    required this.questionId,
    required this.type,
    required this.content,
    required this.coinReward,
    required this.resQuestionsTasks,
    required this.preFilledAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    questionId: json["questionId"] as String? ?? "",
    type: json["type"] as String? ?? "",
    content: Content.fromJson(json["content"] as Map<String, dynamic>? ?? {}),
    coinReward: json["coinReward"] as int? ?? 0,
    resQuestionsTasks: json["resQuestionsTasks"] as List? ?? [],
    preFilledAnswers: json["preFilledAnswers"],
  );

  Map<String, dynamic> toJson() => {
    "questionId": questionId,
    "type": type,
    "content": content.toJson(),
    "coinReward": coinReward,
    "resQuestionsTasks": resQuestionsTasks,
    "preFilledAnswers": preFilledAnswers,
  };
}

class Content {
  final String type;
  final String instruction;
  final String attachmentUrl;
  final String attachmentMediaType;
  final String text;
  final List<Input> inputs;

  Content({
    required this.type,
    required this.instruction,
    required this.attachmentUrl,
    required this.attachmentMediaType,
    required this.text,
    required this.inputs,
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    type: json["type"],
    instruction: json["instruction"],
    attachmentUrl: json["attachmentUrl"],
    attachmentMediaType: json["attachmentMediaType"],
    text: json["text"],
    inputs: List<Input>.from(json["inputs"].map((x) => Input.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "instruction": instruction,
    "attachmentUrl": attachmentUrl,
    "attachmentMediaType": attachmentMediaType,
    "text": text,
    "inputs": List<dynamic>.from(inputs.map((x) => x.toJson())),
  };
}

class Input {
  final The1 the1;

  Input({required this.the1});

  factory Input.fromJson(Map<String, dynamic> json) =>
      Input(the1: The1.fromJson(json["1"]));

  Map<String, dynamic> toJson() => {"1": the1.toJson()};
}

class The1 {
  final String mode;
  final dynamic options;
  final String hint;

  The1({required this.mode, required this.options, required this.hint});

  factory The1.fromJson(Map<String, dynamic> json) =>
      The1(mode: json["mode"], options: json["options"], hint: json["hint"]);

  Map<String, dynamic> toJson() => {
    "mode": mode,
    "options": options,
    "hint": hint,
  };
}
