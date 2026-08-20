import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/homeworks/homework_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/models/vocabulary/vocabulary_model.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'unit_detail_event.dart';

part 'unit_detail_state.dart';

class UnitDetailBloc extends Bloc<UnitDetailEvent, UnitDetailState> {
  UnitDetailBloc()
    : super(
        UnitDetailState(
          unit: HomeworkModel(
            unitUuid: "",
            unitTitle: "",
            dueDate: "",
            topicName: "",
            overallStatus: "",
            progressPercentage: 0,
            isAdditional: false,
            sections: [],
            unitType: "",
            examPolicy: ExamPolicy(
              noScreenshot: false,
              freezeScreen: false,
              freezeTimer: 0,
              separateSection: false,
              timeLimit: 0,
              isStarted: false,
              isFinished: false,
              globalRemainingSeconds: 0,
            ),
          ),
          vocabularies: [],
          formStatus: FormStatus.pure,
          errorMessage: "",
        ),
      ) {
    on<GetUnitDetail>(_getUnitDetail);
  }

  Future<void> _getUnitDetail(
    GetUnitDetail event,
    Emitter<UnitDetailState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.getUnitDetailLoading));

    final results = await Future.wait([
      sl.get<HomeworksRepository>().getUnitById(unitId: event.unitId),
      // sl.get<HomeworksRepository>().getUnitTasksByIdAndType(
      //   unitId: event.unitId,
      //   type: "VOCABULARY",
      // ),
      // sl.get<HomeworksRepository>().getUnitTasksByIdAndType(
      //   unitId: event.unitId,
      //   type: "GRAMMAR",
      // ),
      // sl.get<HomeworksRepository>().getUnitTasksByIdAndType(
      //   unitId: event.unitId,
      //   type: "LISTENING",
      // ),
      // sl.get<HomeworksRepository>().getUnitTasksByIdAndType(
      //   unitId: event.unitId,
      //   type: "READING",
      // ),
      // sl.get<HomeworksRepository>().getUnitTasksByIdAndType(
      //   unitId: event.unitId,
      //   type: "WRITING",
      // ),
      // sl.get<HomeworksRepository>().getUnitVocabulariesById(
      //   unitId: event.unitId,
      // ),
    ]);

    final AppResponse unitDetailResponse = results[0];
    // final AppResponse exerciseResponse = results[1];
    // final AppResponse vocabularyResponse = results[2];

    if (unitDetailResponse.errorMessage.isNotEmpty) {
      emit(
        state.copyWith(
          formStatus: FormStatus.getUnitDetailFailure,
          errorMessage: unitDetailResponse.errorMessage,
        ),
      );
      return;
    }

    // if (vocabularyResponse.errorMessage.isNotEmpty) {
    //   emit(
    //     state.copyWith(
    //       formStatus: FormStatus.getUnitDetailFailure,
    //       errorMessage: vocabularyResponse.errorMessage,
    //     ),
    //   );
    //   return;
    // }

    // if (exerciseResponse.errorMessage.isNotEmpty) {
    //   emit(
    //     state.copyWith(
    //       formStatus: FormStatus.getUnitDetailFailure,
    //       errorMessage: exerciseResponse.errorMessage,
    //     ),
    //   );
    //   return;
    // }
    emit(
      state.copyWith(
        formStatus: FormStatus.getUnitDetailSuccess,
        unit: HomeworkModel.fromJson(unitDetailResponse.data),
        // vocabularies: (vocabularyResponse.data as List)
        //     .map((data) => VocabularyModel.fromJson(data))
        //     .toList(),
        // grammarExercises: (exerciseResponse.data["grammarInfos"] as List)
        //     .map((data) => ExerciseModel.fromJson(data))
        //     .toList(),
        // listeningExercises: (exerciseResponse.data["listeningTaskInfo"] as List)
        //     .map((data) => ExerciseModel.fromJson(data))
        //     .toList(),
      ),
    );
  }
}
