class HomeworkModel {
  final String unitUuid;
  final String unitTitle;
  final bool isAdditional;
  final String dueDate;
  final String topicName;
  final String overallStatus;
  final int progressPercentage;
  final List<Section> sections;
  final String unitType;
  final ExamPolicy examPolicy;

  HomeworkModel({
    required this.unitUuid,
    required this.unitTitle,
    required this.isAdditional,
    required this.dueDate,
    required this.topicName,
    required this.overallStatus,
    required this.progressPercentage,
    required this.sections,
    this.unitType = "",
    this.examPolicy = const ExamPolicy(
      noScreenshot: false,
      freezeScreen: false,
      freezeTimer: 0,
      separateSection: false,
      timeLimit: 0,
      isStarted: false,
      isFinished: false,
      globalRemainingSeconds: 0,
    ),
  });

  HomeworkModel copyWith({
    String? unitUuid,
    String? unitTitle,
    bool? isAdditional,
    String? dueDate,
    String? topicName,
    String? overallStatus,
    int? progressPercentage,
    List<Section>? sections,
    String? unitType,
    ExamPolicy? examPolicy,
  }) {
    return HomeworkModel(
      unitUuid: unitUuid ?? this.unitUuid,
      unitTitle: unitTitle ?? this.unitTitle,
      isAdditional: isAdditional ?? this.isAdditional,
      dueDate: dueDate ?? this.dueDate,
      topicName: topicName ?? this.topicName,
      overallStatus: overallStatus ?? this.overallStatus,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      sections: sections ?? this.sections,
      unitType: unitType ?? this.unitType,
      examPolicy: examPolicy ?? this.examPolicy,
    );
  }

  factory HomeworkModel.fromJson(Map<String, dynamic> json) => HomeworkModel(
    unitUuid: json["unitUuid"] as String? ?? "",
    unitTitle: json["unitTitle"] as String? ?? "",
    isAdditional: json["isAdditional"] as bool? ?? false,
    dueDate: json["dueDate"] as String? ?? "",
    topicName: json["topicName"] as String? ?? "",
    overallStatus: json["overallStatus"] as String? ?? "",
    progressPercentage: json["progressPercentage"] as int? ?? 0,
    sections: List<Section>.from(
      (json["sections"] as List? ?? [])
          .map((x) => Section.fromJson(x as Map<String, dynamic>))
          .toList(),
    ),
    unitType: json["unitType"] as String? ?? "",
    examPolicy: ExamPolicy.fromJson(
      json["examPolicy"] as Map<String, dynamic>? ?? {},
    ),
  );
}

class Section {
  final String type;
  final String title;
  final int progressPercentage;
  final bool locked;

  Section({
    required this.type,
    required this.locked,
    required this.title,
    required this.progressPercentage,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    title: json["title"] as String? ?? "",
    progressPercentage: json["progressPercentage"] as int? ?? 0,
    type: json["type"] as String? ?? "",
    locked: json["locked"] as bool? ?? false,
  );
}

class ExamPolicy {
  final bool noScreenshot;
  final bool freezeScreen;
  final int freezeTimer;
  final bool separateSection;
  final int timeLimit;
  final bool isStarted;
  final bool isFinished;
  final int globalRemainingSeconds;

  const ExamPolicy({
    required this.noScreenshot,
    required this.freezeScreen,
    required this.freezeTimer,
    required this.separateSection,
    required this.timeLimit,
    required this.isStarted,
    required this.isFinished,
    required this.globalRemainingSeconds,
  });

  ExamPolicy copyWith({
    bool? noScreenshot,
    bool? freezeScreen,
    int? freezeTimer,
    bool? separateSection,
    int? timeLimit,
    bool? isStarted,
    bool? isFinished,
    int? globalRemainingSeconds,
  }) {
    return ExamPolicy(
      noScreenshot: noScreenshot ?? this.noScreenshot,
      freezeScreen: freezeScreen ?? this.freezeScreen,
      freezeTimer: freezeTimer ?? this.freezeTimer,
      separateSection: separateSection ?? this.separateSection,
      timeLimit: timeLimit ?? this.timeLimit,
      isStarted: isStarted ?? this.isStarted,
      isFinished: isFinished ?? this.isFinished,
      globalRemainingSeconds:
          globalRemainingSeconds ?? this.globalRemainingSeconds,
    );
  }

  factory ExamPolicy.fromJson(Map<String, dynamic> json) => ExamPolicy(
    noScreenshot: json["noScreenshot"] as bool? ?? false,
    freezeScreen: json["freezeScreen"] as bool? ?? false,
    freezeTimer: json["freezeTimer"] as int? ?? 0,
    separateSection: json["separateSection"] as bool? ?? false,
    timeLimit: json["timeLimit"] as int? ?? 0,
    isStarted: json["isStarted"] as bool? ?? false,
    isFinished: json["isFinished"] as bool? ?? false,
    globalRemainingSeconds: json["globalRemainingSeconds"] as int? ?? 0,
  );
}
