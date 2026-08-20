part of 'check_vocabulary_answer_cubit.dart';

class CheckVocabularyAnswerState extends Equatable {
  final FormStatus formStatus;
  final String errorMessage;
  final bool isCorrect;
  final bool isLast;
  final int? percentage;
  final int? coinsEarned;
  final String? message;
  final VocabularyResultModel? vocabularyResult;

  const CheckVocabularyAnswerState({
    required this.formStatus,
    required this.errorMessage,
    required this.isCorrect,
    required this.isLast,
    this.percentage,
    this.coinsEarned,
    this.message,
    this.vocabularyResult,
  });

  CheckVocabularyAnswerState copyWith({
    FormStatus? formStatus,
    String? errorMessage,
    bool? isCorrect,
    bool? isLast,
    int? percentage,
    int? coinsEarned,
    String? message,
    VocabularyResultModel? vocabularyResult,
  }) {
    return CheckVocabularyAnswerState(
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      isCorrect: isCorrect ?? this.isCorrect,
      isLast: isLast ?? this.isLast,
      percentage: percentage ?? this.percentage,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      message: message ?? this.message,
      vocabularyResult: vocabularyResult ?? this.vocabularyResult,
    );
  }

  @override
  List<Object?> get props => [
    formStatus,
    errorMessage,
    isCorrect,
    isLast,
    percentage,
    coinsEarned,
    message,
    vocabularyResult,
  ];
}
