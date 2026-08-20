import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/questions/questions_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/questions_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'questions_event.dart';

part 'questions_state.dart';

class QuestionsBloc extends Bloc<QuestionsEvent, QuestionsState> {
  QuestionsBloc()
    : super(
        QuestionsState(
          errorMessage: "",
          formStatus: FormStatus.pure,
          questionModel: QuestionsModel(
            taskUuid: "",
            taskTitle: "",
            questionCount: 0,
            questions: [],
          ),
          lastSubmitCorrect: null,
        ),
      ) {
    on<GetQuestionsByTaskId>(_getQuestionsByTaskId);
  }

  Future<void> _getQuestionsByTaskId(
    GetQuestionsByTaskId event,
    Emitter<QuestionsState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.getQuestionsByTaskIdLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .getQuestionsByTaskId(taskId: event.taskId);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      final model = QuestionsModel.fromJson(appResponse.data);
      emit(
        state.copyWith(
          formStatus: FormStatus.getQuestionsByTaskIdSuccess,
          questionModel: model,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getQuestionsByTaskIdFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
