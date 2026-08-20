import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/network/open_api/open_api_client.dart';
import 'package:mentour_web_view/utils/extensions.dart';

class OpenApiService extends OpenApiClient {
  Future<AppResponse> signIn({
    required String userName,
    required String password,
  }) async {
    AppResponse appResponse = AppResponse();
    try {
      final Response response = await dio.post(
        '${dio.options.baseUrl}/api/v1/auth/sign',
        data: {"username": userName, "password": password},
      );
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        appResponse.data = response.data;
      }
    } catch (error) {
      if (error is DioException) {
        final statusCode = error.response?.statusCode;

        if (statusCode == 400) {
          appResponse.errorMessage = 'auth_user_not_found'.tr();
        } else {
          appResponse.errorMessage = extractErrorMessage(error);
        }
      } else {
        appResponse.errorMessage = error.toString();
      }
    }
    return appResponse;
  }
}
