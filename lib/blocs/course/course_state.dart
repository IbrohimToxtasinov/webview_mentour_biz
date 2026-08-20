part of 'course_bloc.dart';

class CourseState extends Equatable {
  final List<CourseModel> courses;
  final CourseDetailModel courseDetail;
  final String errorMessage;
  final FormStatus formStatus;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const CourseState({
    required this.courses,
    required this.courseDetail,
    required this.errorMessage,
    required this.formStatus,
    required this.currentPage,
    required this.hasMore,
    required this.isLoadingMore,
  });

  CourseState copyWith({
    List<CourseModel>? courses,
    CourseDetailModel? courseDetail,
    String? errorMessage,
    FormStatus? formStatus,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      courseDetail: courseDetail ?? this.courseDetail,
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    courses,
    courseDetail,
    errorMessage,
    formStatus,
    currentPage,
    hasMore,
    isLoadingMore,
  ];
}
