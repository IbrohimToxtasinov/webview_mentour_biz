import 'dart:async';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/open_api/open_api_services.dart';

class AuthRepository {
  Future<AppResponse> signIn({
    required String userName,
    required String password,
  }) => sl.get<OpenApiService>().signIn(userName: userName, password: password);
}
