import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class GroupRepository {
  Future<AppResponse> getStudentAllGroups({required int page}) {
    return sl.get<SecureApiService>().getAllGroups(page: page);
  }
}
