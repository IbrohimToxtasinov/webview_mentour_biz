import 'dart:async';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class NotificationsRepository {
  Future<AppResponse> getNotifications({required int page, required int size}) {
    return sl.get<SecureApiService>().getNotifications(page: page, size: size);
  }
}
