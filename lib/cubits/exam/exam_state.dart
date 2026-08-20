part of 'exam_cubit.dart';

class ExamState extends Equatable {
  final FormStatus formStatus;
  final String errorMessage;
  final String unitUuid;
  final int globalRemainingSeconds;
  final ExamPolicy? examPolicy;

  const ExamState({
    this.formStatus = FormStatus.pure,
    this.errorMessage = "",
    this.unitUuid = "",
    this.globalRemainingSeconds = 0,
    this.examPolicy,
  });

  ExamState copyWith({
    FormStatus? formStatus,
    String? errorMessage,
    String? unitUuid,
    int? globalRemainingSeconds,
    ExamPolicy? examPolicy,
  }) {
    return ExamState(
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      unitUuid: unitUuid ?? this.unitUuid,
      globalRemainingSeconds:
          globalRemainingSeconds ?? this.globalRemainingSeconds,
      examPolicy: examPolicy ?? this.examPolicy,
    );
  }

  @override
  List<Object?> get props => [
    formStatus,
    errorMessage,
    unitUuid,
    globalRemainingSeconds,
    examPolicy,
  ];
}
