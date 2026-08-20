import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/product/product_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/coin_market_products_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'coins_market_products_state.dart';

class CoinsMarketProductsCubit extends Cubit<CoinsMarketProductsState> {
  CoinsMarketProductsCubit()
    : super(
        CoinsMarketProductsState(
          errorMessage: "",
          status: FormStatus.pure,
          products: [],
        ),
      );

  void getCoinMarketProducts({required String schoolId}) async {
    emit(state.copyWith(status: FormStatus.getCoinMarketProductsLoading));
    AppResponse appResponse = await sl
        .get<CoinMarketProductsRepository>()
        .getCoinMarketProducts(schoolId: schoolId);
    if (appResponse.errorMessage.isNotEmpty) {
      emit(
        state.copyWith(
          errorMessage: appResponse.errorMessage,
          status: FormStatus.getCoinMarketProductsFailure,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        products: (appResponse.data["content"] as List)
            .map((data) => ProductModel.fromJson(data))
            .toList(),
        status: FormStatus.getCoinMarketProductsSuccess,
      ),
    );
  }

  void orderCreate({required String itemUuid, required int count}) async {
    emit(state.copyWith(status: FormStatus.orderCreateLoading));
    AppResponse appResponse = await sl
        .get<CoinMarketProductsRepository>()
        .orderCreate(itemUuid: itemUuid, count: count);
    if (appResponse.errorMessage.isNotEmpty) {
      emit(
        state.copyWith(
          errorMessage: appResponse.errorMessage,
          status: FormStatus.orderCreateFailure,
        ),
      );
      return;
    }
    emit(state.copyWith(status: FormStatus.orderCreateSuccess));
  }
}
