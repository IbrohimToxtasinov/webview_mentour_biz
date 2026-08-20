part of 'course_bloc.dart';

abstract class CourseEvent extends Equatable {
  const CourseEvent();
}

class GetCourseById extends CourseEvent {
  final String courseId;

  const GetCourseById({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

class GetStudentAllCourses extends CourseEvent {
  final int page;
  final bool isLoadMore;

  const GetStudentAllCourses({this.page = 0, this.isLoadMore = false});

  @override
  List<Object?> get props => [page, isLoadMore];
}
