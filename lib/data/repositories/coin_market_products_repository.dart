import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';

class CoinMarketProductsRepository {
  Future<AppResponse> getCoinMarketProducts({required String schoolId}) {
    return sl.get<SecureApiService>().getCoinMarketProducts(schoolId: schoolId);
  }

  Future<AppResponse> orderCreate({
    required String itemUuid,
    required int count,
  }) {
    return sl.get<SecureApiService>().orderCreate(
      itemUuid: itemUuid,
      count: count,
    );
  }
}
