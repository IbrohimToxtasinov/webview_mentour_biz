import 'dart:io';

import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class FileRepository {
  Future<AppResponse> uploadFile({required File file}) {
    return sl.get<SecureApiService>().uploadFile(file: file);
  }

  Future<AppResponse> uploadSpeakingFile({required File file}) {
    return sl.get<SecureApiService>().uploadSpeakingFile(file: file);
  }
}
