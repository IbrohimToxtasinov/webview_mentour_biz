part of 'questions_bloc.dart';

class QuestionsState extends Equatable {
  final String errorMessage;
  final FormStatus formStatus;
  final QuestionsModel questionModel;
  final bool? lastSubmitCorrect;

  const QuestionsState({
    required this.errorMessage,
    required this.formStatus,
    required this.questionModel,
    this.lastSubmitCorrect,
  });

  QuestionsState copyWith({
    String? errorMessage,
    FormStatus? formStatus,
    QuestionsModel? questionModel,
    bool? lastSubmitCorrect,
  }) {
    return QuestionsState(
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
      questionModel: questionModel ?? this.questionModel,
      lastSubmitCorrect: lastSubmitCorrect,
    );
  }

  @override
  List<Object?> get props => [
    errorMessage,
    formStatus,
    questionModel,
    lastSubmitCorrect,
  ];
}
