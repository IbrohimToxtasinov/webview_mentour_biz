import 'dart:async';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class HomeworksRepository {
  Future<AppResponse> getAllHomeworks({required String groupUuid}) =>
      sl.get<SecureApiService>().getAllHomeWorks(groupUuid: groupUuid);

  Future<AppResponse> getHomeworksByLesson({String? groupUuid}) =>
      sl.get<SecureApiService>().getHomeworksByLesson(groupUuid: groupUuid);

  Future<AppResponse> startExam({required String unitUuid}) =>
      sl.get<SecureApiService>().startExam(unitUuid: unitUuid);

  Future<AppResponse> resumeExam({required String unitUuid}) =>
      sl.get<SecureApiService>().resumeExam(unitUuid: unitUuid);

  Future<AppResponse> getActiveHomework() =>
      sl.get<SecureApiService>().getActiveHomeWork();

  Future<AppResponse> getUnitById({required String unitId}) =>
      sl.get<SecureApiService>().getUnitById(unitId: unitId);

  Future<AppResponse> getUnitVocabulariesById({required String unitId}) =>
      sl.get<SecureApiService>().getUnitVocabulariesById(unitId: unitId);

  Future<AppResponse> getUnitSectionByIdAndType({
    required String unitId,
    required String type,
  }) {
    return sl.get<SecureApiService>().getUnitSectionByIdAndType(
      unitId: unitId,
      type: type,
    );
  }

  Future<AppResponse> getExerciseResultByTaskId({
    required String taskId,
    bool flag = false,
  }) => sl.get<SecureApiService>().getExerciseResultByTaskId(
    taskId: taskId,
    flag: flag,
  );
}
