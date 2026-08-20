import 'dart:async';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class RankingRepository {
  Future<AppResponse> getRankingByGroup() {
    return sl.get<SecureApiService>().getRankingByGroup();
  }

  Future<AppResponse> getRankingBySchool() {
    return sl.get<SecureApiService>().getRankingBySchool();
  }
}
