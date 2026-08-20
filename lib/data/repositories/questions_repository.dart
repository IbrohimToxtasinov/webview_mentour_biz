import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class QuestionsRepository {
  Future<AppResponse> getQuestionsByTaskId({required String taskId}) {
    return sl.get<SecureApiService>().getQuestionsByTaskId(taskId: taskId);
  }

  Future<AppResponse> getWritingQuestionByTaskId({required String taskId}) {
    return sl.get<SecureApiService>().getWritingQuestionByTaskId(
      taskId: taskId,
    );
  }

  Future<AppResponse> getSpeakingQuestionByTaskId({required String taskId}) {
    return sl.get<SecureApiService>().getSpeakingQuestionByTaskId(
      taskId: taskId,
    );
  }

  Future<AppResponse> submitQuestionForGapFill({
    required String questionId,
    required String taskId,
    required Map<String, dynamic> answers,
  }) {
    return sl.get<SecureApiService>().submitQuestionForGapFill(
      taskId: taskId,
      questionId: questionId,
      answers: answers,
    );
  }

  Future<AppResponse> submitSpeakingPronunciation({
    required String questionId,
    required String taskId,
  }) {
    return sl.get<SecureApiService>().submitSpeakingPronunciation(
      taskId: taskId,
      questionId: questionId,
    );
  }

  Future<AppResponse> submitQuestionForOrdering({
    required String questionId,
    required String taskId,
    required List<String> answers,
  }) {
    return sl.get<SecureApiService>().submitQuestionForOrdering(
      taskId: taskId,
      questionId: questionId,
      answers: answers,
    );
  }

  Future<AppResponse> submitQuestionForMatching({
    required String questionId,
    required String taskId,
    required Map<String, String> matchingPairs,
  }) {
    return sl.get<SecureApiService>().submitQuestionForMatching(
      taskId: taskId,
      questionId: questionId,
      matchingPairs: matchingPairs,
    );
  }

  Future<AppResponse> submitQuestionForMultiSelect({
    required String questionId,
    required String taskId,
    required List<String> multiSelectAnswer,
  }) {
    return sl.get<SecureApiService>().submitQuestionForMultiSelect(
      taskId: taskId,
      questionId: questionId,
      multiSelectAnswer: multiSelectAnswer,
    );
  }

  Future<AppResponse> submitQuestionForCircle({
    required String questionId,
    required String taskId,
    required List<String> selectedCharIds,
  }) {
    return sl.get<SecureApiService>().submitQuestionForCircle(
      taskId: taskId,
      questionId: questionId,
      selectedCharIds: selectedCharIds,
    );
  }

  Future<AppResponse> submitQuestionForTracing({
    required String questionId,
    required String taskId,
    required Map<String, dynamic> tracingResults,
  }) {
    return sl.get<SecureApiService>().submitQuestionForTracing(
      taskId: taskId,
      questionId: questionId,
      tracingResults: tracingResults,
    );
  }

  Future<AppResponse> submitQuestionForFixing({
    required String questionId,
    required String taskId,
    required String fixingAnswer,
  }) {
    return sl.get<SecureApiService>().submitQuestionForFixing(
      taskId: taskId,
      questionId: questionId,
      fixingAnswer: fixingAnswer,
    );
  }

  Future<AppResponse> submitQuestionForSelection({
    required String questionId,
    required String taskId,
    required String selectedOptionId,
  }) {
    return sl.get<SecureApiService>().submitQuestionForSelection(
      taskId: taskId,
      questionId: questionId,
      selectedOptionId: selectedOptionId,
    );
  }

  Future<AppResponse> submitWritingQuestion({
    required String questionId,
    required String taskId,
    required String writingText,
  }) {
    return sl.get<SecureApiService>().submitWritingQuestion(
      taskId: taskId,
      questionId: questionId,
      writingText: writingText,
    );
  }

  Future<AppResponse> submitSpeakingQuestion({
    required String attachmentUuid,
    required String questionUuid,
  }) {
    return sl.get<SecureApiService>().speakingEvaluate(
      attachmentUuid: attachmentUuid,
      questionUuid: questionUuid,
    );
  }

  Future<AppResponse> speakingPronunciationEvaluate({
    required String attachmentUuid,
    required String questionUuid,
  }) {
    return sl.get<SecureApiService>().speakingPronunciationEvaluate(
      attachmentUuid: attachmentUuid,
      questionUuid: questionUuid,
    );
  }
}
