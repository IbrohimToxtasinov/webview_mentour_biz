import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/course/course_detail_model.dart';
import 'package:mentour_web_view/data/models/course/course_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/course_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'course_event.dart';

part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc()
    : super(
        CourseState(
          errorMessage: "",
          formStatus: FormStatus.pure,
          courses: [],
          currentPage: 0,
          hasMore: true,
          isLoadingMore: false,
          courseDetail: CourseDetailModel(
            id: "",
            courseName: "",
            schoolId: "",
            groupId: "",
            mentorId: "",
            moderatorId: "",
            schoolName: "",
            mentorName: "",
            moderatorName: "",
            description: "",
            numberOfLessons: 0,
            courseDurationHours: 0,
            lessons: [],
            books: [],
            unitProgresses: 0,
          ),
        ),
      ) {
    on<GetStudentAllCourses>(_getStudentAllCourses);
    on<GetCourseById>(_getCourseDetail);
  }

  Future<void> _getCourseDetail(
    GetCourseById event,
    Emitter<CourseState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.getCourseDetailInLoading));
    AppResponse appResponse = await sl.get<CourseRepository>().getCourseById(
      courseId: event.courseId,
    );
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      emit(
        state.copyWith(
          formStatus: FormStatus.getCourseDetailInSuccess,
          courseDetail: CourseDetailModel.fromJson(appResponse.data),
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getCourseDetailInFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> _getStudentAllCourses(
    GetStudentAllCourses event,
    Emitter<CourseState> emit,
  ) async {
    if (event.isLoadMore) {
      if (!state.hasMore || state.isLoadingMore) {
        return;
      }
      emit(state.copyWith(isLoadingMore: true));
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getStudentAllCoursesInLoading,
          currentPage: 0,
          courses: [],
          hasMore: true,
        ),
      );
      await Future.delayed(Duration(seconds: 1));
    }

    AppResponse appResponse = await sl
        .get<CourseRepository>()
        .getStudentAllCourses(page: event.page);

    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      final List<CourseModel> newCourses = (appResponse.data["content"] as List)
          .map((data) => CourseModel.fromJson(data))
          .toList();

      final bool isLastPage = appResponse.data["last"] as bool? ?? false;
      final int currentPageNumber = appResponse.data["number"] as int? ?? 0;

      final bool hasMoreData = !isLastPage && newCourses.isNotEmpty;

      final List<CourseModel> updatedCourses = event.isLoadMore
          ? [...state.courses, ...newCourses]
          : newCourses;

      emit(
        state.copyWith(
          formStatus: FormStatus.getStudentAllCoursesInSuccess,
          courses: updatedCourses,
          currentPage: currentPageNumber,
          hasMore: hasMoreData,
          isLoadingMore: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getStudentAllCoursesInFailure,
          errorMessage: appResponse.errorMessage,
          isLoadingMore: false,
        ),
      );
    }
  }
}
