import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/exercise/exercise_result_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/data/repositories/questions_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/app_utils.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'check_answer_state.dart';

class CheckAnswerCubit extends Cubit<CheckAnswerState> {
  CheckAnswerCubit()
    : super(
        CheckAnswerState(
          resultModel: ExerciseResultModel(
            taskId: "",
            title: "",
            totalQuestions: 0,
            correctAnswers: 0,
            totalCoinsEarned: 0,
            totalScoreEarned: 0,
            scorePercentage: 0,
            questions: [],
          ),
          formStatus: FormStatus.pure,
          errorMessage: "",
          isCorrect: false,
          isLast: false,
          percentage: null,
          incorrectGaps: null,
          gapFeedback: null,
          coinsEarned: null,
          message: null,
          orderingFeedback: null,
        ),
      );

  Future<void> getExerciseResultByTaskId({required String taskId}) async {
    emit(state.copyWith(formStatus: FormStatus.getExerciseResultLoading));
    AppResponse appResponse = await sl
        .get<HomeworksRepository>()
        .getExerciseResultByTaskId(taskId: taskId);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      try {
        final resultModel = ExerciseResultModel.fromJson(
          appResponse.data as Map<String, dynamic>,
        );
        emit(
          state.copyWith(
            formStatus: FormStatus.getExerciseResultSuccess,
            resultModel: resultModel,
          ),
        );
      } catch (e) {
        emit(
          state.copyWith(
            formStatus: FormStatus.getExerciseResultFailure,
            errorMessage: e.toString(),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getExerciseResultFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitWritingQuestion({
    required String questionId,
    required String taskId,
    required String writingText,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitWritingTaskLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitWritingQuestion(
          questionId: questionId,
          taskId: taskId,
          writingText: writingText,
        );
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      String? message;
      final data = appResponse.data;
      if (data is Map<String, dynamic>) {
        if (data["message"] != null) {
          message = data["message"] is String
              ? data["message"] as String
              : null;
        }
      }
      emit(
        state.copyWith(
          message: message,
          formStatus: FormStatus.submitWritingTaskSuccess,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitWritingTaskFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitQuestionForGapFill({
    required String questionId,
    required String taskId,
    required List<String> answers,
    bool isLast = false,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitGapFillLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitQuestionForGapFill(
          questionId: questionId,
          taskId: taskId,
          answers: AppUtils.listToAnswerMap(answers),
        );
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      bool? isCorrect;
      int? percentage;
      List<int>? incorrectGaps;
      Map<String, bool>? gapFeedback;

      final data = appResponse.data;
      if (data is Map<String, dynamic>) {
        if (data["isCorrect"] is bool) {
          isCorrect = data["isCorrect"] as bool;
        } else if (data["correct"] is bool) {
          isCorrect = data["correct"] as bool;
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

        if (data["gapFeedback"] != null && data["gapFeedback"] is Map) {
          final gapFeedbackMap = data["gapFeedback"] as Map;
          gapFeedback = {};
          gapFeedbackMap.forEach((key, value) {
            final keyString = key.toString();
            if (value is bool) {
              gapFeedback![keyString] = value;
            }
          });

          incorrectGaps = [];
          gapFeedback.forEach((key, value) {
            if (value == false) {
              final gapIndex = int.tryParse(key);
              if (gapIndex != null) {
                incorrectGaps!.add(gapIndex - 1);
              }
            }
          });
          if (incorrectGaps.isEmpty) {
            incorrectGaps = null;
          }
        } else if (data["incorrectGaps"] != null &&
            data["incorrectGaps"] is List) {
          incorrectGaps = (data["incorrectGaps"] as List)
              .map((e) => e is int ? e : (e is String ? int.tryParse(e) : null))
              .whereType<int>()
              .toList();
        } else if (data["wrongGaps"] != null && data["wrongGaps"] is List) {
          incorrectGaps = (data["wrongGaps"] as List)
              .map((e) => e is int ? e : (e is String ? int.tryParse(e) : null))
              .whereType<int>()
              .toList();
        }
      } else if (data is bool) {
        isCorrect = data;
      }

      emit(
        state.copyWith(
          formStatus: FormStatus.submitGapFillSuccess,
          isCorrect: isCorrect,
          isLast: isLast,
          percentage: percentage,
          incorrectGaps: incorrectGaps,
          gapFeedback: gapFeedback,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitGapFillFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitSpeakingPronunciation({
    required String questionId,
    required String taskId,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitPronunciationLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitSpeakingPronunciation(questionId: questionId, taskId: taskId);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      emit(state.copyWith(formStatus: FormStatus.submitPronunciationSuccess));
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitPronunciationFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitQuestionForOrdering({
    required String questionId,
    required String taskId,
    required List<String> answers,
    bool isLast = false,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitOrderingLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitQuestionForOrdering(
          taskId: taskId,
          questionId: questionId,
          answers: answers,
        );
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      bool? isCorrect;
      int? percentage;
      List<int>? incorrectGaps;
      Map<String, bool>? gapFeedback;
      int? coinsEarned;
      String? message;
      List<bool>? orderingFeedback;

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

        if (data["orderingFeedback"] != null &&
            data["orderingFeedback"] is List) {
          orderingFeedback = (data["orderingFeedback"] as List)
              .map((e) => e is bool ? e : null)
              .whereType<bool>()
              .toList();
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

        if (data["gapFeedback"] != null && data["gapFeedback"] is Map) {
          final gapFeedbackMap = data["gapFeedback"] as Map;
          gapFeedback = {};
          gapFeedbackMap.forEach((key, value) {
            final keyString = key.toString();
            if (value is bool) {
              gapFeedback![keyString] = value;
            }
          });

          incorrectGaps = [];
          gapFeedback.forEach((key, value) {
            if (value == false) {
              final gapIndex = int.tryParse(key);
              if (gapIndex != null) {
                incorrectGaps!.add(gapIndex - 1);
              }
            }
          });
          if (incorrectGaps.isEmpty) {
            incorrectGaps = null;
          }
        } else if (data["incorrectGaps"] != null &&
            data["incorrectGaps"] is List) {
          incorrectGaps = (data["incorrectGaps"] as List)
              .map((e) => e is int ? e : (e is String ? int.tryParse(e) : null))
              .whereType<int>()
              .toList();
        } else if (data["wrongGaps"] != null && data["wrongGaps"] is List) {
          incorrectGaps = (data["wrongGaps"] as List)
              .map((e) => e is int ? e : (e is String ? int.tryParse(e) : null))
              .whereType<int>()
              .toList();
        }
      } else if (data is bool) {
        isCorrect = data;
      }

      emit(
        state.copyWith(
          formStatus: FormStatus.submitOrderingSuccess,
          isCorrect: isCorrect,
          isLast: isLast,
          percentage: percentage,
          incorrectGaps: incorrectGaps,
          gapFeedback: gapFeedback,
          coinsEarned: coinsEarned,
          message: message,
          orderingFeedback: orderingFeedback,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitOrderingFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitQuestionForSelection({
    required String questionId,
    required String taskId,
    required String selectedOptionId,
    bool isLast = false,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitSelectionLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitQuestionForSelection(
          questionId: questionId,
          taskId: taskId,
          selectedOptionId: selectedOptionId,
        );
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      bool? isCorrect;
      int? percentage;
      List<int>? incorrectGaps;
      Map<String, bool>? gapFeedback;
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

        if (data["gapFeedback"] != null && data["gapFeedback"] is Map) {
          final gapFeedbackMap = data["gapFeedback"] as Map;
          gapFeedback = {};
          gapFeedbackMap.forEach((key, value) {
            final keyString = key.toString();
            if (value is bool) {
              gapFeedback![keyString] = value;
            }
          });

          incorrectGaps = [];
          gapFeedback.forEach((key, value) {
            if (value == false) {
              final gapIndex = int.tryParse(key);
              if (gapIndex != null) {
                incorrectGaps!.add(gapIndex - 1);
              }
            }
          });
          if (incorrectGaps.isEmpty) {
            incorrectGaps = null;
          }
        } else if (data["incorrectGaps"] != null &&
            data["incorrectGaps"] is List) {
          incorrectGaps = (data["incorrectGaps"] as List)
              .map((e) => e is int ? e : (e is String ? int.tryParse(e) : null))
              .whereType<int>()
              .toList();
        } else if (data["wrongGaps"] != null && data["wrongGaps"] is List) {
          incorrectGaps = (data["wrongGaps"] as List)
              .map((e) => e is int ? e : (e is String ? int.tryParse(e) : null))
              .whereType<int>()
              .toList();
        }
      } else if (data is bool) {
        isCorrect = data;
      }

      emit(
        state.copyWith(
          formStatus: FormStatus.submitSelectionSuccess,
          isCorrect: isCorrect,
          isLast: isLast,
          percentage: percentage,
          incorrectGaps: incorrectGaps,
          gapFeedback: gapFeedback,
          coinsEarned: coinsEarned,
          message: message,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitSelectionFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitQuestionForMatching({
    required String questionId,
    required String taskId,
    required Map<String, String> matchingPairs,
    bool isLast = false,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitMatchingLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitQuestionForMatching(
          questionId: questionId,
          taskId: taskId,
          matchingPairs: matchingPairs,
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
          formStatus: FormStatus.submitMatchingSuccess,
          isCorrect: isCorrect,
          isLast: isLast,
          percentage: percentage,
          coinsEarned: coinsEarned,
          message: message,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitMatchingFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitQuestionForMultiSelect({
    required String questionId,
    required String taskId,
    required List<String> multiSelectAnswer,
    bool isLast = false,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitMultiSelectLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitQuestionForMultiSelect(
          questionId: questionId,
          taskId: taskId,
          multiSelectAnswer: multiSelectAnswer,
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
          formStatus: FormStatus.submitMultiSelectSuccess,
          isCorrect: isCorrect,
          isLast: isLast,
          percentage: percentage,
          coinsEarned: coinsEarned,
          message: message,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitMultiSelectFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitQuestionForCircle({
    required String questionId,
    required String taskId,
    required List<String> selectedCharIds,
    bool isLast = false,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitCircleLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitQuestionForCircle(
          questionId: questionId,
          taskId: taskId,
          selectedCharIds: selectedCharIds,
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
          formStatus: FormStatus.submitCircleSuccess,
          isCorrect: isCorrect,
          isLast: isLast,
          percentage: percentage,
          coinsEarned: coinsEarned,
          message: message,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitCircleFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitQuestionForTracing({
    required String questionId,
    required String taskId,
    required Map<String, dynamic> tracingResults,
    bool isLast = false,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitTracingLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitQuestionForTracing(
          questionId: questionId,
          taskId: taskId,
          tracingResults: tracingResults,
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
          formStatus: FormStatus.submitTracingSuccess,
          isCorrect: isCorrect,
          isLast: isLast,
          percentage: percentage,
          coinsEarned: coinsEarned,
          message: message,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitTracingFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> submitQuestionForFixing({
    required String questionId,
    required String taskId,
    required String fixingAnswer,
    bool isLast = false,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.submitFixingLoading));
    AppResponse appResponse = await sl
        .get<QuestionsRepository>()
        .submitQuestionForFixing(
          questionId: questionId,
          taskId: taskId,
          fixingAnswer: fixingAnswer,
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
          formStatus: FormStatus.submitFixingSuccess,
          isCorrect: isCorrect,
          isLast: isLast,
          percentage: percentage,
          coinsEarned: coinsEarned,
          message: message,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.submitFixingFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
