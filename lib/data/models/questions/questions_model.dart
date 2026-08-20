class QuestionsModel {
  final String taskTitle;
  final int questionCount;
  final String taskUuid;
  final List<Question> questions;

  QuestionsModel({
    required this.taskTitle,
    required this.questionCount,
    required this.taskUuid,
    required this.questions,
  });

  factory QuestionsModel.fromJson(Map<String, dynamic> json) => QuestionsModel(
    taskTitle: json["taskTitle"] as String? ?? "",
    questionCount: json["questionCount"] as int? ?? 0,
    taskUuid: json["taskUuid"] as String? ?? "",
    questions: (json["questions"] as List? ?? [])
        .map((x) => Question.fromJson(x))
        .toList(),
  );
}

class Question {
  final String questionId;
  final String exerciseId;
  final String type;
  final Content content;
  final int coinReward;
  final Map<String, String> preFilledAnswers;

  // final dynamic resQuestionsTasks;
  // final dynamic preFilledAnswers;

  Question({
    required this.questionId,
    required this.exerciseId,
    required this.type,
    required this.content,
    required this.coinReward,
    required this.preFilledAnswers,
    // required this.resQuestionsTasks,
    // required this.preFilledAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    questionId: json["questionId"] as String? ?? "",
    exerciseId: json["exerciseId"] as String? ?? "",
    type: json["type"] as String? ?? "",
    content: json["content"] != null
        ? Content.fromJson(json["content"])
        : Content(
            type: "",
            instruction: "",
            attachmentUrl: "",
            attachmentMediaType: "",
            text: "",
            inputs: [],
            words: [],
            texts: [],
            question: "",
            options: [],
          ),
    coinReward: json["coinReward"] as int? ?? 0,
    preFilledAnswers: json["preFilledAnswers"] != null
        ? Map<String, String>.from(json["preFilledAnswers"])
        : {},
    // resQuestionsTasks: json["resQuestionsTasks"],
    // preFilledAnswers: json["preFilledAnswers"],
  );
}

class Content {
  final String type;
  final String instruction;
  final String attachmentUrl;
  final String attachmentMediaType;
  final String text;
  final List<Map<String, Input>> inputs;
  final List<OrderingWord> words;
  final List<String> texts;
  final String question;
  final List<SelectionOption> options;
  final List<SelectionOption> leftOptions;
  final List<SelectionOption> rightOptions;
  final List<CirclePart> parts;
  final List<TracingLetter> tracingLetters;
  final String tracingWord;
  final String questionText;

  Content({
    required this.type,
    required this.instruction,
    required this.attachmentUrl,
    required this.attachmentMediaType,
    required this.text,
    required this.inputs,
    required this.words,
    required this.texts,
    required this.question,
    required this.options,
    this.leftOptions = const [],
    this.rightOptions = const [],
    this.parts = const [],
    this.tracingLetters = const [],
    this.tracingWord = "",
    this.questionText = "",
  });

  factory Content.fromJson(Map<String, dynamic> json) => Content(
    type: json["type"] as String? ?? "",
    instruction: json["instruction"] as String? ?? "",
    attachmentUrl: json["attachmentUrl"] as String? ?? "",
    attachmentMediaType: json["attachmentMediaType"] as String? ?? "",
    text: json["text"] as String? ?? "",
    inputs: json["inputs"] != null
        ? List<Map<String, Input>>.from(
            json["inputs"].map(
              (x) => Map.from(
                x,
              ).map((k, v) => MapEntry<String, Input>(k, Input.fromJson(v))),
            ),
          )
        : [],
    words: json["words"] != null
        ? List<OrderingWord>.from(
            json["words"].map((x) => OrderingWord.fromJson(x)),
          )
        : [],
    texts: json["texts"] != null
        ? List<String>.from(json["texts"].map((x) => x.toString()))
        : [],
    question: json["question"] as String? ?? "",
    options: json["options"] != null
        ? _parseSelectionOptions(json["options"])
        : [],
    leftOptions: json["leftItems"] != null
        ? _parseSelectionOptions(json["leftItems"])
        : [],
    rightOptions: json["rightItems"] != null
        ? _parseSelectionOptions(json["rightItems"])
        : [],
    parts: json["parts"] != null
        ? List<CirclePart>.from(
            json["parts"].map((x) => CirclePart.fromJson(x)),
          )
        : [],
    tracingLetters: json["letters"] != null
        ? List<TracingLetter>.from(
            json["letters"].map((x) => TracingLetter.fromJson(x)),
          )
        : [],
    tracingWord: json["targetWord"] as String? ?? json["word"] as String? ?? "",
    questionText: json["questionText"] as String? ?? "",
  );
}

List<SelectionOption> _parseSelectionOptions(dynamic optionsData) {
  if (optionsData is! List) return [];

  final List<SelectionOption> options = [];
  for (final item in optionsData) {
    if (item is Map<String, dynamic>) {
      // Handle format: [{"id": "1", "text": "one"}] or [{"id": "1", "image": "..."}]
      if (item.containsKey("id") &&
          (item.containsKey("text") || item.containsKey("image"))) {
        options.add(SelectionOption.fromJson(item));
      } else {
        // Handle format: [{1: "one"}, {2: "two"}] where each map has one key-value pair
        item.forEach((key, value) {
          options.add(
            SelectionOption(id: key.toString(), text: value.toString()),
          );
        });
      }
    } else if (item is Map) {
      // Handle format: [{1: "one"}, {2: "two"}] where each map has one key-value pair
      item.forEach((key, value) {
        options.add(
          SelectionOption(id: key.toString(), text: value.toString()),
        );
      });
    }
  }
  return options;
}

class OrderingWord {
  final String id;
  final String text;

  OrderingWord({required this.id, required this.text});

  factory OrderingWord.fromJson(Map<String, dynamic> json) => OrderingWord(
    id: json["id"] as String? ?? "",
    text: json["text"] as String? ?? "",
  );

  Map<String, dynamic> toJson() => {"id": id, "text": text};
}

class SelectionOption {
  final String id;
  final String text;
  final String image;

  SelectionOption({required this.id, required this.text, this.image = ""});

  factory SelectionOption.fromJson(Map<String, dynamic> json) =>
      SelectionOption(
        id: json["id"] as String? ?? "",
        text: json["text"] as String? ?? "",
        image: json["image"] as String? ?? "",
      );

  Map<String, dynamic> toJson() => {"id": id, "text": text, "image": image};
}

class Input {
  final String mode;
  final List<String> options;
  final String hint;

  Input({required this.mode, required this.options, required this.hint});

  factory Input.fromJson(Map<String, dynamic> json) => Input(
    mode: json["mode"] as String? ?? "",
    options: json["options"] != null
        ? List<String>.from(json["options"].map((x) => x))
        : [],
    hint: json["hint"] as String? ?? "",
  );
}

class CircleChar {
  final String id;
  final String value;

  CircleChar({required this.id, required this.value});

  factory CircleChar.fromJson(Map<String, dynamic> json) => CircleChar(
    id: json["id"] as String? ?? "",
    value: json["value"] as String? ?? "",
  );
}

class CirclePart {
  final String wordId;
  final List<CircleChar> chars;
  final bool space;

  CirclePart({required this.wordId, required this.chars, required this.space});

  factory CirclePart.fromJson(Map<String, dynamic> json) => CirclePart(
    wordId: json["wordId"] as String? ?? "",
    chars: json["chars"] != null
        ? List<CircleChar>.from(
            json["chars"].map((x) => CircleChar.fromJson(x)),
          )
        : [],
    space: json["space"] as bool? ?? false,
  );
}

class TracingLetter {
  final String char;
  final List<String> svgPaths;
  final String? placeholderId;
  final bool placeholder;

  TracingLetter({
    required this.char,
    required this.svgPaths,
    required this.placeholderId,
    required this.placeholder,
  });

  factory TracingLetter.fromJson(Map<String, dynamic> json) => TracingLetter(
    char: json["character"] as String? ?? json["char"] as String? ?? "",
    svgPaths: json["svgPaths"] != null
        ? List<String>.from(json["svgPaths"].map((x) => x.toString()))
        : json["svg_paths"] != null
        ? List<String>.from(json["svg_paths"].map((x) => x.toString()))
        : [],
    placeholderId: json["placeholderId"] as String?,
    placeholder: json["placeholder"] as bool? ?? false,
  );
}
