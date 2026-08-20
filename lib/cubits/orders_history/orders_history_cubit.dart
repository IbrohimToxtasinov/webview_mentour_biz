import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/orders_history/orders_history_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'orders_history_state.dart';

class OrdersHistoryCubit extends Cubit<OrdersHistoryState> {
  OrdersHistoryCubit()
    : super(
        OrdersHistoryState(
          status: FormStatus.pure,
          errorMessage: "",
          ordersHistory: [],
        ),
      );

  void getOrdersHistory() async {
    emit(state.copyWith(status: FormStatus.getOrdersHistoryLoading));
    AppResponse appResponse = AppResponse();
    // await sl.get<HistoryRepository>().getOrdersHistory(
    //   page: 0,
    // );
    if (appResponse.errorMessage.isNotEmpty) {
      emit(
        state.copyWith(
          status: FormStatus.getOrdersHistoryFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        ordersHistory: [],
        status: FormStatus.getOrdersHistorySuccess,
      ),
    );
  }
}
