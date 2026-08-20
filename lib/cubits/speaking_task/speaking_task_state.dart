part of 'speaking_task_cubit.dart';

class SpeakingTaskState extends Equatable {
  final String errorMessage;
  final FormStatus formStatus;
  final SpeakingQuestionModel questionModel;

  const SpeakingTaskState({
    required this.errorMessage,
    required this.formStatus,
    required this.questionModel,
  });

  SpeakingTaskState copyWith({
    String? errorMessage,
    FormStatus? formStatus,
    SpeakingQuestionModel? questionModel,
  }) {
    return SpeakingTaskState(
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
      questionModel: questionModel ?? this.questionModel,
    );
  }

  @override
  List<Object?> get props => [errorMessage, formStatus, questionModel];
}
