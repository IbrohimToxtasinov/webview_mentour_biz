part of 'check_answer_cubit.dart';

class CheckAnswerState extends Equatable {
  final FormStatus formStatus;
  final String errorMessage;
  final bool isCorrect;
  final bool isLast;
  final int? percentage;
  final List<int>? incorrectGaps;
  final Map<String, bool>? gapFeedback;
  final ExerciseResultModel resultModel;
  final int? coinsEarned;
  final String? message;
  final List<bool>? orderingFeedback;

  const CheckAnswerState({
    required this.formStatus,
    required this.errorMessage,
    required this.isCorrect,
    required this.isLast,
    required this.resultModel,
    this.percentage,
    this.incorrectGaps,
    this.gapFeedback,
    this.coinsEarned,
    this.message,
    this.orderingFeedback,
  });

  CheckAnswerState copyWith({
    FormStatus? formStatus,
    String? errorMessage,
    bool? isCorrect,
    bool? isLast,
    int? percentage,
    List<int>? incorrectGaps,
    Map<String, bool>? gapFeedback,
    ExerciseResultModel? resultModel,
    int? coinsEarned,
    String? message,
    List<bool>? orderingFeedback,
  }) {
    return CheckAnswerState(
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      isCorrect: isCorrect ?? this.isCorrect,
      isLast: isLast ?? this.isLast,
      percentage: percentage ?? this.percentage,
      incorrectGaps: incorrectGaps ?? this.incorrectGaps,
      gapFeedback: gapFeedback ?? this.gapFeedback,
      resultModel: resultModel ?? this.resultModel,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      message: message ?? this.message,
      orderingFeedback: orderingFeedback ?? this.orderingFeedback,
    );
  }

  @override
  List<Object?> get props => [
    formStatus,
    errorMessage,
    isCorrect,
    isLast,
    percentage,
    incorrectGaps,
    gapFeedback,
    resultModel,
    coinsEarned,
    message,
    orderingFeedback,
  ];
}
