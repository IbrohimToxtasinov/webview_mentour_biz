part of 'writing_task_cubit.dart';

class WritingTaskState extends Equatable {
  final String errorMessage;
  final FormStatus formStatus;
  final WritingQuestionModel questionModel;

  const WritingTaskState({
    required this.errorMessage,
    required this.formStatus,
    required this.questionModel,
  });

  WritingTaskState copyWith({
    String? errorMessage,
    FormStatus? formStatus,
    WritingQuestionModel? questionModel,
  }) {
    return WritingTaskState(
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
      questionModel: questionModel ?? this.questionModel,
    );
  }

  @override
  List<Object?> get props => [errorMessage, formStatus, questionModel];
}
