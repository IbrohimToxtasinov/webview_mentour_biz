import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/models/writing/writing_question_model.dart';
import 'package:mentour_web_view/data/repositories/questions_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'writing_task_state.dart';

class WritingTaskCubit extends Cubit<WritingTaskState> {
  WritingTaskCubit()
    : super(
        WritingTaskState(
          errorMessage: "",
          formStatus: FormStatus.pure,
          questionModel: WritingQuestionModel(
            instruction: "",
            taskUuid: "",
            taskTitle: "",
            questionCount: 0,
            questions: [],
          ),
        ),
      );

  Future<void> getWritingQuestion({required String taskId}) async {
    emit(state.copyWith(formStatus: FormStatus.getWritingQuestionLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .getWritingQuestionByTaskId(taskId: taskId);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      emit(
        state.copyWith(
          formStatus: FormStatus.getWritingQuestionSuccess,
          questionModel: WritingQuestionModel.fromJson(appResponse.data),
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getWritingQuestionFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
