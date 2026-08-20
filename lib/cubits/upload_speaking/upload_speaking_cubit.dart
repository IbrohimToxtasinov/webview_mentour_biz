import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/models/section/section_details_model.dart';
import 'package:mentour_web_view/data/repositories/file_repository.dart';
import 'package:mentour_web_view/data/repositories/questions_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'upload_speaking_state.dart';

class UploadSpeakingCubit extends Cubit<UploadSpeakingState> {
  UploadSpeakingCubit()
    : super(
        UploadSpeakingState(
          status: FormStatus.pure,
          errorMessage: "",
          message: "",
          aiResponse: AiResponse(
            wordRequested: "",
            totalWords: 0,
            processedWords: [],
          ),
        ),
      );

  Future<void> uploadSpeakingFileAndEvaluate({
    required File file,
    required String questionId,
  }) async {
    emit(state.copyWith(status: FormStatus.uploadFileLoading));
    AppResponse uploadResponse = await sl
        .get<FileRepository>()
        .uploadSpeakingFile(file: file);
    if (uploadResponse.errorMessage.isEmpty) {
      emit(state.copyWith(status: FormStatus.submitSpeakingTaskLoading));
      AppResponse appResponse = await sl
          .get<QuestionsRepository>()
          .submitSpeakingQuestion(
            attachmentUuid: uploadResponse.data["id"],
            questionUuid: questionId,
          );
      if (appResponse.errorMessage.isEmpty) {
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
            status: FormStatus.submitSpeakingTaskSuccess,
          ),
        );
      } else {
        emit(
          state.copyWith(
            errorMessage: appResponse.errorMessage,
            status: FormStatus.submitSpeakingTaskFailure,
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          errorMessage: uploadResponse.errorMessage,
          status: FormStatus.uploadFileFailure,
        ),
      );
    }
  }

  Future<void> uploadSpeakingPronunciationFileAndEvaluate({
    required File file,
    required String questionId,
  }) async {
    emit(state.copyWith(status: FormStatus.uploadFileLoading));
    AppResponse uploadResponse = await sl
        .get<FileRepository>()
        .uploadSpeakingFile(file: file);
    if (uploadResponse.errorMessage.isEmpty) {
      emit(state.copyWith(status: FormStatus.checkPronunciationTaskLoading));
      AppResponse appResponse = await sl
          .get<QuestionsRepository>()
          .speakingPronunciationEvaluate(
            attachmentUuid: uploadResponse.data["id"],
            questionUuid: questionId,
          );
      if (appResponse.errorMessage.isEmpty) {
        emit(
          state.copyWith(
            status: FormStatus.checkPronunciationTaskSuccess,
            aiResponse: AiResponse.fromJson(appResponse.data),
          ),
        );
      } else {
        emit(
          state.copyWith(
            errorMessage: appResponse.errorMessage,
            status: FormStatus.checkPronunciationTaskFailure,
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          errorMessage: uploadResponse.errorMessage,
          status: FormStatus.uploadFileFailure,
        ),
      );
    }
  }
}
