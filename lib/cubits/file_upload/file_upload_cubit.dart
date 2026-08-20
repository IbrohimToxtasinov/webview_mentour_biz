import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/file/file_upload_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/file_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  FileUploadCubit()
    : super(
        FileUploadState(
          status: FormStatus.pure,
          errorMessage: "",
          fileUploadModel: FileUploadModel(
            id: "",
            contentType: "",
            path: "",
            name: "",
          ),
        ),
      );

  Future<void> uploadFile({required File file}) async {
    emit(state.copyWith(status: FormStatus.uploadFileLoading));
    AppResponse appResponse = await sl.get<FileRepository>().uploadFile(
      file: file,
    );
    if (appResponse.errorMessage.isEmpty) {
      emit(
        state.copyWith(
          fileUploadModel: FileUploadModel.fromJson(appResponse.data),
          status: FormStatus.uploadFileSuccess,
        ),
      );
    } else {
      emit(
        state.copyWith(
          errorMessage: appResponse.errorMessage,
          status: FormStatus.uploadFileFailure,
        ),
      );
    }
  }
}
