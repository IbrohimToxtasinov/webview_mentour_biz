part of 'home_work_bloc.dart';

class HomeworkState extends Equatable {
  final FormStatus formStatus;
  final String errorMessage;
  final List<HomeworkModel> homeworks;
  final List<HomeworkByLessonModel> homeworksByLesson;

  const HomeworkState({
    this.formStatus = FormStatus.pure,
    this.errorMessage = "",
    this.homeworks = const [],
    this.homeworksByLesson = const [],
  });

  HomeworkState copyWith({
    FormStatus? formStatus,
    String? errorMessage,
    List<HomeworkModel>? homeworks,
    List<HomeworkByLessonModel>? homeworksByLesson,
  }) {
    return HomeworkState(
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      homeworks: homeworks ?? this.homeworks,
      homeworksByLesson: homeworksByLesson ?? this.homeworksByLesson,
    );
  }

  @override
  List<Object> get props => [formStatus, errorMessage, homeworks, homeworksByLesson];
}
