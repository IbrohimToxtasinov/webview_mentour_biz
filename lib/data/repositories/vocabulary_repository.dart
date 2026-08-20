import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class VocabularyRepository {
  Future<AppResponse> getVocabularySetLearnById({required String setUuid}) {
    return sl.get<SecureApiService>().getVocabularySetLearnById(
      setUuid: setUuid,
    );
  }

  Future<AppResponse> getVocabularySetQuizById({required String setUuid}) {
    return sl.get<SecureApiService>().getVocabularySetQuizById(
      setUuid: setUuid,
    );
  }

  Future<AppResponse> submitVocabularyAnswer({
    required String wordUuid,
    required String answer,
    required String setUuid,
  }) {
    return sl.get<SecureApiService>().submitVocabularyAnswer(
      wordUuid: wordUuid,
      answer: answer,
      setUuid: setUuid,
    );
  }

  Future<AppResponse> getVocabularySetResult({required String setUuid}) {
    return sl.get<SecureApiService>().getVocabularySetResult(setUuid: setUuid);
  }
}
