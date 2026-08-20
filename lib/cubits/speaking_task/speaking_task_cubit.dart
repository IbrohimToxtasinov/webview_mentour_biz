import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/models/speaking/speaking_question_model.dart';
import 'package:mentour_web_view/data/repositories/questions_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'speaking_task_state.dart';

class SpeakingTaskCubit extends Cubit<SpeakingTaskState> {
  SpeakingTaskCubit()
    : super(
        SpeakingTaskState(
          errorMessage: "",
          formStatus: FormStatus.pure,
          questionModel: SpeakingQuestionModel(
            instruction: "",
            taskUuid: "",
            taskTitle: "",
            questionCount: 0,
            questions: [],
          ),
        ),
      );

  Future<void> getSpeakingQuestion({required String taskId}) async {
    emit(state.copyWith(formStatus: FormStatus.getSpeakingQuestionLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .getSpeakingQuestionByTaskId(taskId: taskId);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      emit(
        state.copyWith(
          formStatus: FormStatus.getSpeakingQuestionSuccess,
          questionModel: SpeakingQuestionModel.fromJson(appResponse.data),
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getSpeakingQuestionFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
