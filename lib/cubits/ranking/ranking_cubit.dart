import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/ranking/ranking_user_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/ranking_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'ranking_state.dart';

class RankingCubit extends Cubit<RankingState> {
  RankingCubit()
    : super(
        RankingState(
          errorMessage: "",
          status: FormStatus.pure,
          groupRanking: [],
          schoolRanking: [],
        ),
      );

  Future<void> getRankingByGroupAndSchool() async {
    emit(state.copyWith(status: FormStatus.getRankingLoading));

    final results = await Future.wait([
      sl.get<RankingRepository>().getRankingByGroup(),
      sl.get<RankingRepository>().getRankingBySchool(),
    ]);

    final AppResponse groupResponse = results[0];
    final AppResponse schoolResponse = results[1];

    if (groupResponse.errorMessage.isNotEmpty) {
      emit(
        state.copyWith(
          status: FormStatus.getRankingFailure,
          errorMessage: groupResponse.errorMessage,
        ),
      );
      return;
    }

    if (schoolResponse.errorMessage.isNotEmpty) {
      emit(
        state.copyWith(
          status: FormStatus.getRankingFailure,
          errorMessage: schoolResponse.errorMessage,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        groupRanking: (groupResponse.data["content"] as List)
            .map((data) => RankingUserModel.fromJson(data))
            .toList(),
        schoolRanking: (schoolResponse.data["content"] as List)
            .map((data) => RankingUserModel.fromJson(data))
            .toList(),
        status: FormStatus.getRankingSuccess,
      ),
    );
  }

  // Future<void> getRankingByGroup() async {
  //   emit(state.copyWith(status: FormStatus.getRankingByGroupLoading));
  //   AppResponse appResponse = await sl
  //       .get<RankingRepository>()
  //       .getRankingByGroup();
  //
  //   if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
  //     emit(
  //       state.copyWith(
  //         groupRanking: (appResponse.data["content"] as List)
  //             .map((data) => RankingUserModel.fromJson(data))
  //             .toList(),
  //         status: FormStatus.getRankingByGroupSuccess,
  //       ),
  //     );
  //   } else {
  //     emit(
  //       state.copyWith(
  //         status: FormStatus.getRankingByGroupFailure,
  //         errorMessage: appResponse.errorMessage.isNotEmpty
  //             ? appResponse.errorMessage
  //             : "An error occurred. Please try again.",
  //       ),
  //     );
  //   }
  // }
  //
  // Future<void> getRankingBySchool() async {
  //   emit(state.copyWith(status: FormStatus.getRankingBySchoolLoading));
  //   AppResponse appResponse = await sl
  //       .get<RankingRepository>()
  //       .getRankingBySchool();
  //
  //   if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
  //     emit(
  //       state.copyWith(
  //         schoolRanking: (appResponse.data["content"] as List)
  //             .map((data) => RankingUserModel.fromJson(data))
  //             .toList(),
  //         status: FormStatus.getRankingBySchoolSuccess,
  //       ),
  //     );
  //   } else {
  //     emit(
  //       state.copyWith(
  //         status: FormStatus.getRankingBySchoolFailure,
  //         errorMessage: appResponse.errorMessage.isNotEmpty
  //             ? appResponse.errorMessage
  //             : "An error occurred. Please try again.",
  //       ),
  //     );
  //   }
  // }
}
