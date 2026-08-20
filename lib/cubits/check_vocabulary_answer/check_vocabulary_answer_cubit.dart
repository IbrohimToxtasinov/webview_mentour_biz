import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/vocabulary_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/data/models/vocabulary/vocabulary_result_model.dart';

part 'check_vocabulary_answer_state.dart';

class CheckVocabularyAnswerCubit extends Cubit<CheckVocabularyAnswerState> {
  CheckVocabularyAnswerCubit()
    : super(
        CheckVocabularyAnswerState(
          formStatus: FormStatus.pure,
          errorMessage: "",
          isCorrect: false,
          isLast: false,
          percentage: null,
          coinsEarned: null,
          message: null,
        ),
      );

  Future<void> submitVocabularyAnswer({
    required String wordUuid,
    required String answer,
    required String setUuid,
    bool isLast = false,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitVocabularyAnswerLoading));
    AppResponse appResponse = await sl
        .get<VocabularyRepository>()
        .submitVocabularyAnswer(
          wordUuid: wordUuid,
          answer: answer,
          setUuid: setUuid,
        );
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      bool? isCorrect;
      int? percentage;
      int? coinsEarned;
      String? message;

      final data = appResponse.data;
      if (data is Map<String, dynamic>) {
        if (data["isCorrect"] is bool) {
          isCorrect = data["isCorrect"] as bool;
        } else if (data["correct"] is bool) {
          isCorrect = data["correct"] as bool;
        }

        if (data["coinsEarned"] != null) {
          coinsEarned = data["coinsEarned"] is int
              ? data["coinsEarned"] as int
              : (data["coinsEarned"] is double
                    ? (data["coinsEarned"] as double).toInt()
                    : null);
        }

        if (data["message"] != null) {
          message = data["message"] is String
              ? data["message"] as String
              : null;
        }

        if (data["scorePercentage"] != null) {
          percentage = data["scorePercentage"] is int
              ? data["scorePercentage"] as int
              : (data["scorePercentage"] is double
                    ? (data["scorePercentage"] as double).toInt()
                    : null);
        } else if (data["percentage"] != null) {
          percentage = data["percentage"] is int
              ? data["percentage"] as int
              : (data["percentage"] is double
                    ? (data["percentage"] as double).toInt()
                    : null);
        }
      } else if (data is bool) {
        isCorrect = data;
      }

      emit(
        state.copyWith(
          formStatus: FormStatus.submitVocabularyAnswerSuccess,
          isCorrect: isCorrect ?? false,
          isLast: isLast,
          percentage: percentage,
          coinsEarned: coinsEarned,
          message: message,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitVocabularyAnswerFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> getVocabularySetResult({required String setUuid}) async {
    emit(state.copyWith(formStatus: FormStatus.getVocabularySetResultLoading));
    AppResponse appResponse = await sl
        .get<VocabularyRepository>()
        .getVocabularySetResult(setUuid: setUuid);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      try {
        final data = appResponse.data;
        final result = VocabularyResultModel.fromJson(
          data as Map<String, dynamic>? ?? {},
        );
        emit(
          state.copyWith(
            formStatus: FormStatus.getVocabularySetResultSuccess,
            vocabularyResult: result,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            formStatus: FormStatus.getVocabularySetResultFailure,
            errorMessage: e.toString(),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getVocabularySetResultFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
