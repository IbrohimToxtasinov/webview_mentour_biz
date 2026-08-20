import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class LibraryRepository {
  Future<AppResponse> getLibraryContentByType({
    required String itemType,
    required String levelId,
    required String schoolUuid,
  }) {
    return sl.get<SecureApiService>().getLibraryContentByType(
      itemType: itemType,
      levelId: levelId,
      schoolUuid: schoolUuid,
    );
  }
}
