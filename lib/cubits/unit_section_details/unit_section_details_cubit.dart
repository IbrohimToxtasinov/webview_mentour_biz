import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/models/section/section_details_model.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'unit_section_details_state.dart';

class UnitSectionDetailCubit extends Cubit<UnitSectionDetailState> {
  UnitSectionDetailCubit()
    : super(
        UnitSectionDetailState(
          errorMessage: "",
          formStatus: FormStatus.pure,
          section: SectionDetailsModel(type: "", tasks: []),
        ),
      );

  Future<void> getUnitSectionByIdAndType({
    required String unitId,
    required String type,
  }) async {
    emit(state.copyWith(formStatus: FormStatus.getUnitSectionLoading));
    AppResponse appResponse = await sl
        .get<HomeworksRepository>()
        .getUnitSectionByIdAndType(unitId: unitId, type: type);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      if (appResponse.data["sections"].isNotEmpty) {
        emit(
          state.copyWith(
            formStatus: FormStatus.getUnitSectionSuccess,
            section: SectionDetailsModel.fromJson(
              appResponse.data["sections"][0],
            ),
          ),
        );
      } else {
        emit(
          state.copyWith(
            formStatus: FormStatus.getUnitSectionSuccess,
            section: SectionDetailsModel(type: type, tasks: []),
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getUnitSectionFailure,
          errorMessage: appResponse.errorMessage.isNotEmpty
              ? appResponse.errorMessage
              : "An error occurred. Please try again.",
        ),
      );
    }
  }
}
