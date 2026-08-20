part of 'home_work_bloc.dart';

abstract class HomeworkEvent extends Equatable {
  const HomeworkEvent();
}

class GetAllHomeWorks extends HomeworkEvent {
  final String groupUuid;

  const GetAllHomeWorks({required this.groupUuid});

  @override
  List<Object?> get props => [groupUuid];
}

class GetHomeworksByLesson extends HomeworkEvent {
  final String groupUuid;

  const GetHomeworksByLesson({required this.groupUuid});

  @override
  List<Object?> get props => [groupUuid];
}
