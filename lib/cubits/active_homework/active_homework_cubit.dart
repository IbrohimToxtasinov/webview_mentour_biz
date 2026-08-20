import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/homeworks/active_homework_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'active_homework_state.dart';

class ActiveHomeworkCubit extends Cubit<ActiveHomeworkState> {
  ActiveHomeworkCubit()
    : super(
        const ActiveHomeworkState(
          groups: [],
          errorMessage: "",
          formStatus: FormStatus.pure,
        ),
      );

  Future<void> getActiveHomework() async {
    debugPrint("ActiveHomeworkCubit.getActiveHomework() called");
    emit(state.copyWith(formStatus: FormStatus.getActiveHomeworkLoading));
    await Future.delayed(Duration(seconds: 1));
    try {
      debugPrint("ActiveHomeworkCubit.getActiveHomework: Fetching from repository...");
      AppResponse appResponse = await sl
          .get<HomeworksRepository>()
          .getActiveHomework();
      debugPrint("ActiveHomeworkCubit.getActiveHomework: Received response. ErrorMessage = '${appResponse.errorMessage}', Data = ${appResponse.data}");
      if (appResponse.errorMessage.isEmpty) {
        if (appResponse.data != null) {
          final List<dynamic> data = appResponse.data as List<dynamic>;
          debugPrint("ActiveHomeworkCubit.getActiveHomework: Parsing data list (length = ${data.length})");
          final groups = data
              .map((e) => ActiveHomeworkGroup.fromJson(e as Map<String, dynamic>))
              .toList();
          debugPrint("ActiveHomeworkCubit.getActiveHomework: Parsing completed successfully");
          emit(
            state.copyWith(
              formStatus: FormStatus.getActiveHomeworkSuccess,
              groups: groups,
            ),
          );
        } else {
          debugPrint("ActiveHomeworkCubit.getActiveHomework: Data is null");
          emit(
            state.copyWith(
              formStatus: FormStatus.getActiveHomeworkSuccess,
              groups: [],
            ),
          );
        }
      } else {
        debugPrint("ActiveHomeworkCubit.getActiveHomework FAILURE: ${appResponse.errorMessage}");
        emit(
          state.copyWith(
            formStatus: FormStatus.getActiveHomeworkFailure,
            errorMessage: appResponse.errorMessage,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("ActiveHomeworkCubit.getActiveHomework EXCEPTION: $e");
      debugPrint(stackTrace.toString());
      emit(
        state.copyWith(
          formStatus: FormStatus.getActiveHomeworkFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
