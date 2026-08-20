import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/models/vocabulary/vocabulary_model.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'vocabulary_detail_state.dart';

class VocabularyDetailCubit extends Cubit<VocabularyDetailState> {
  VocabularyDetailCubit()
    : super(
        VocabularyDetailState(
          vocabularies: [],
          formStatus: FormStatus.pure,
          errorMessage: "",
        ),
      );

  Future<void> getVocabularyDetail({required String unitId}) async {
    emit(state.copyWith(formStatus: FormStatus.getVocabularyDetailLoading));

    final AppResponse vocabularyResponse = await sl
        .get<HomeworksRepository>()
        .getUnitVocabulariesById(unitId: unitId);
    if (vocabularyResponse.errorMessage.isNotEmpty) {
      emit(
        state.copyWith(
          formStatus: FormStatus.getVocabularyDetailFailure,
          errorMessage: vocabularyResponse.errorMessage,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        formStatus: FormStatus.getVocabularyDetailSuccess,
        vocabularies: (vocabularyResponse.data as List)
            .map((data) => VocabularyModel.fromJson(data))
            .toList(),
      ),
    );
  }
}
