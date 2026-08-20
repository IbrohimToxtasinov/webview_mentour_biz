import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/exercise/exercise_result_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'ai_analysis_state.dart';

class AiAnalysisCubit extends Cubit<AiAnalysisState> {
  AiAnalysisCubit()
    : super(
        AiAnalysisState(
          errorMessage: "",
          aiAnalysisFormStatus: FormStatus.pure,
          aiAnalysisResultModel: ExerciseResultModel(
            taskId: "",
            title: "",
            totalQuestions: 0,
            correctAnswers: 0,
            totalCoinsEarned: 0,
            totalScoreEarned: 0,
            scorePercentage: 0,
            questions: [],
          ),
        ),
      );

  Future<void> getExerciseResultAiAnalysisByTaskId({
    required String taskId,
  }) async {
    emit(
      state.copyWith(
        aiAnalysisFormStatus: FormStatus.getExerciseAiAnalysisResultLoading,
      ),
    );

    try {
      while (!isClosed) {
        AppResponse appResponse = await sl
            .get<HomeworksRepository>()
            .getExerciseResultByTaskId(taskId: taskId, flag: true);

        if (appResponse.errorMessage.isNotEmpty) {
          emit(
            state.copyWith(
              aiAnalysisFormStatus:
                  FormStatus.getExerciseAiAnalysisResultFailure,
              errorMessage: appResponse.errorMessage,
            ),
          );
          return;
        }

        if (appResponse.data != null) {
          final resultModel = ExerciseResultModel.fromJson(
            appResponse.data as Map<String, dynamic>,
          );

          // Check if ANY incorrect question still lacks an explanation
          bool stillLoading = resultModel.questions.any(
            (q) => !q.correct && (q.explanation.trim().isEmpty),
          );

          if (!stillLoading) {
            emit(
              state.copyWith(
                aiAnalysisFormStatus:
                    FormStatus.getExerciseAiAnalysisResultSuccess,
                aiAnalysisResultModel: resultModel,
              ),
            );
            return;
          }
        }

        // Wait 5 seconds before retrying
        await Future.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            aiAnalysisFormStatus: FormStatus.getExerciseAiAnalysisResultFailure,
            errorMessage: e.toString(),
          ),
        );
      }
    }
  }
}
