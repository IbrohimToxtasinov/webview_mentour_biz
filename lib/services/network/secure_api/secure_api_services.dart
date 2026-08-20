import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_client.dart';
import 'package:mentour_web_view/utils/extensions.dart';
import 'package:mentour_web_view/utils/file_bytes_helper/file_bytes_helper.dart';

class SecureApiService extends SecureApiClient {
  Future<AppResponse> getAllGroups({required int page}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/units/groups/my',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getLibraryContentByType({
    required String itemType,
    required String levelId,
    required String schoolUuid,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/library/view',
        queryParameters: {
          "itemType": itemType,
          "levelId": levelId,
          "schoolUuid": schoolUuid,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getLastAttendance() async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/units/last-attendance',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> speakingPronunciationEvaluate({
    required String questionUuid,
    required String attachmentUuid,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/speaking/evaluate/pronunciation',
        queryParameters: {
          "questionUuid": questionUuid,
          "attachmentUuid": attachmentUuid,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> speakingEvaluate({
    required String questionUuid,
    required String attachmentUuid,
    bool isScoringActive = false,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/speaking/evaluate',
        queryParameters: {
          "questionUuid": questionUuid,
          "attachmentUuid": attachmentUuid,
          "isScoringActive": isScoringActive,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> uploadSpeakingFile({required File file}) async {
    AppResponse appResponse = AppResponse();

    try {
      FormData formData;
      if (kIsWeb) {
        final result = await getFileBytes(file.path);
        String fileName = 'speaking_audio.${result.extension}';
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(result.bytes, filename: fileName),
        });
      } else {
        String fileName = file.path.split('/').last;
        formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path, filename: fileName),
        });
      }

      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/speaking/upload/speaking',
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }

    return appResponse;
  }

  Future<AppResponse> uploadFile({required File file}) async {
    AppResponse appResponse = AppResponse();

    try {
      FormData formData;
      if (kIsWeb) {
        final result = await getFileBytes(file.path);
        String fileName = 'uploaded_file.${result.extension}';
        formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(result.bytes, filename: fileName),
        });
      } else {
        String fileName = file.path.split('/').last;
        formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path, filename: fileName),
        });
      }

      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/file/upload',
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }

    return appResponse;
  }

  Future<AppResponse> orderCreate({
    required String itemUuid,
    required int count,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/shop/item/purchase/$itemUuid',
        queryParameters: {"count": count},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getAppVersion({
    required String version,
    required String platform,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/check/version',
        queryParameters: {"platform": platform, "version": version},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getCoinMarketProducts({required String schoolId}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/shop/item/all',
        queryParameters: {"schoolUuid": schoolId, "type": "ALL"},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getCoinsHistory({required int page}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/history/coins',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getOrdersHistory({required int page}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/history/orders',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getRankingByGroup() async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/ranking/groups',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getRankingBySchool() async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/ranking/schools?page=0&size=20',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getVocabularySetLearnById({
    required String setUuid,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/vocab/set/$setUuid/learn',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getVocabularySetQuizById({
    required String setUuid,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/vocab/set/$setUuid/quiz',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitVocabularyAnswer({
    required String wordUuid,
    required String answer,
    required String setUuid,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/vocab/submit/$wordUuid',
        queryParameters: {'answer': answer, 'setUuid': setUuid},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getVocabularySetResult({required String setUuid}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/vocab/set/$setUuid/result',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitWritingQuestion({
    required String questionId,
    required String writingText,
    required String taskId,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {
          "type": "WRITING",
          "taskUuid": taskId,
          "writingText": writingText,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitQuestionForTracing({
    required String questionId,
    required String taskId,
    required Map<String, dynamic> tracingResults,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {
          "type": "TRACING",
          "taskUuid": taskId,
          "tracingResults": tracingResults,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitQuestionForFixing({
    required String questionId,
    required String taskId,
    required String fixingAnswer,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {
          "type": "FIXING_ANSWER",
          "taskUuid": taskId,
          "fixingAnswer": fixingAnswer,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitQuestionForSelection({
    required String questionId,
    required String selectedOptionId,
    required String taskId,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {
          "type": "SELECTION",
          "taskUuid": taskId,
          "selectedOptionId": selectedOptionId,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitQuestionForGapFill({
    required String questionId,
    required String taskId,
    required Map<String, dynamic> answers,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {"type": "GAP_FILL", "taskUuid": taskId, "answers": answers},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitSpeakingPronunciation({
    required String questionId,
    required String taskId,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {"taskUuid": taskId},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitQuestionForOrdering({
    required String questionId,
    required String taskId,
    required List<String> answers,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {
          "type": "ORDERING",
          "taskUuid": taskId,
          "orderingAnswer": answers,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitQuestionForMatching({
    required String questionId,
    required String taskId,
    required Map<String, String> matchingPairs,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {
          "type": "MATCHING",
          "taskUuid": taskId,
          "matchingPairs": matchingPairs,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitQuestionForMultiSelect({
    required String questionId,
    required List<String> multiSelectAnswer,
    required String taskId,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {
          "type": "MULTI_SELECT",
          "taskUuid": taskId,
          "multiSelectAnswer": multiSelectAnswer,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> submitQuestionForCircle({
    required String questionId,
    required List<String> selectedCharIds,
    required String taskId,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exercise/$questionId/submit',
        data: {
          "type": "CIRCLE",
          "taskUuid": taskId,
          "multiSelectAnswer": selectedCharIds,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getQuestionsByTaskId({required String taskId}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/exercise/$taskId/questions',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getWritingQuestionByTaskId({
    required String taskId,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/exercise/$taskId/questions',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getSpeakingQuestionByTaskId({
    required String taskId,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/exercise/$taskId/questions',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getCourseById({required String courseId}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/courses/$courseId',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getUnitVocabulariesById({required String unitId}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/vocab/unit/$unitId/sets',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getExerciseResultByTaskId({
    required String taskId,
    required bool flag,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/exercise/$taskId/result',
        queryParameters: {"flag": flag},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getUnitSectionByIdAndType({
    required String unitId,
    required String type,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/exercise/list/$unitId',
        queryParameters: {"type": type.toUpperCase()},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getUnitById({required String unitId}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/units/$unitId',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> startExam({required String unitUuid}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/exam/$unitUuid/start',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> resumeExam({required String unitUuid}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/exam/$unitUuid/resume',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getAllHomeWorks({required String groupUuid}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/units/student',
        queryParameters: {"groupUuid": groupUuid},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getHomeworksByLesson({String? groupUuid}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Map<String, dynamic> queryParams = {};
      if (groupUuid != null && groupUuid.isNotEmpty) {
        queryParams['groupUuid'] = groupUuid;
      }
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/units/student/by-lesson',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getActiveHomeWork() async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v2/units/active-homework',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> updateProfile({
    required String firstName,
    required String lastName,
    required String imageId,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.patch(
        '${dio.options.baseUrl}/api/v1/profile/update',
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "imageId": imageId,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> editPassword({
    required String oldPassword,
    required String newPassword,
    required confirmPassword,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.put(
        '${dio.options.baseUrl}/api/v1/profile/password',
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> createStudentPay({required String orderId}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/payments/student/$orderId/initiate',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getAllPayments({required int page}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/payments/student?page=$page&size=10',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getUserInfo() async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/profile/info',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getProfileInfo() async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/student/home/profile',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> postFCMToken({
    required String fcmToken,
    required String platform,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/user/device-token',
        queryParameters: {"token": fcmToken, "platform": platform},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      } else {}
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getMyLessons({required int page}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/dashboard/lessons?page=$page&size=10',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getMyCourses({required int page}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/dashboard/courses?page=$page&size=10',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getNotifications({
    required int page,
    required int size,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/user/notifications?page=$page&size=$size',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }

  Future<AppResponse> getCourseGroupDetails({required String courseId}) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.get(
        '${dio.options.baseUrl}/api/v1/courses/$courseId/group-details',
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        appResponse.errorMessage = extractErrorMessage(error);
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }
}
