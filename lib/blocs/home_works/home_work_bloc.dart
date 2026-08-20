import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/homeworks/homework_by_lesson_model.dart';
import 'package:mentour_web_view/data/models/homeworks/homework_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'home_work_event.dart';

part 'home_work_state.dart';

class HomeworkBloc extends Bloc<HomeworkEvent, HomeworkState> {
  HomeworkBloc() : super(HomeworkState()) {
    on<GetAllHomeWorks>(_getAllHomeWorks);
    on<GetHomeworksByLesson>(_getHomeworksByLesson);
  }

  Future<void> _getAllHomeWorks(
    GetAllHomeWorks event,
    Emitter<HomeworkState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.getAllHomeWorksLoading));
    AppResponse appResponse = await sl
        .get<HomeworksRepository>()
        .getAllHomeworks(groupUuid: event.groupUuid);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      emit(
        state.copyWith(
          formStatus: FormStatus.getAllHomeWorksSuccess,
          homeworks: (appResponse.data as List)
              .map((data) => HomeworkModel.fromJson(data))
              .toList(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getAllHomeWorksFailure,
          errorMessage: appResponse.errorMessage.isNotEmpty
              ? appResponse.errorMessage
              : "An error occurred. Please try again.",
        ),
      );
    }
  }

  Future<void> _getHomeworksByLesson(
    GetHomeworksByLesson event,
    Emitter<HomeworkState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.getHomeworksByLessonLoading));
    AppResponse appResponse = await sl
        .get<HomeworksRepository>()
        .getHomeworksByLesson(groupUuid: event.groupUuid);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      emit(
        state.copyWith(
          formStatus: FormStatus.getHomeworksByLessonSuccess,
          homeworksByLesson: (appResponse.data as List)
              .map((data) => HomeworkByLessonModel.fromJson(data))
              .toList(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getHomeworksByLessonFailure,
          errorMessage: appResponse.errorMessage.isNotEmpty
              ? appResponse.errorMessage
              : "An error occurred. Please try again.",
        ),
      );
    }
  }
}
