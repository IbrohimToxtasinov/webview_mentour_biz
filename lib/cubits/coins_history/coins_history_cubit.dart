import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/coins_history/coins_history_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'coins_history_state.dart';

class CoinsHistoryCubit extends Cubit<CoinsHistoryState> {
  CoinsHistoryCubit()
    : super(
        CoinsHistoryState(
          status: FormStatus.pure,
          errorMessage: "",
          coinsHistory: [],
        ),
      );

  void getCoinsHistory() async {
    emit(state.copyWith(status: FormStatus.getCoinsHistoryLoading));
    AppResponse appResponse = AppResponse();
    // await sl.get<HistoryRepository>().getCoinsHistory(
    //   page: 0,
    // );
    if (appResponse.errorMessage.isNotEmpty) {
      emit(
        state.copyWith(
          status: FormStatus.getCoinsHistoryFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        coinsHistory: [],
        status: FormStatus.getCoinsHistorySuccess,
      ),
    );
  }
}
