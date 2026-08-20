import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/models/vocabulary/vocabulary_quiz_word_model.dart';
import 'package:mentour_web_view/data/models/vocabulary/vocabulary_word_model.dart';
import 'package:mentour_web_view/data/repositories/vocabulary_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'vocabulary_state.dart';
part 'vocabulary_event.dart';

class VocabularyBloc extends Bloc<VocabularyEvent, VocabularyState> {
  VocabularyBloc()
    : super(
        VocabularyState(
          formStatus: FormStatus.pure,
          errorMessage: "",
          learnWords: [],
          quizWords: [],
        ),
      ) {
    on<GetVocabularySetLearnById>(_getVocabularySetLearnById);
    on<GetVocabularySetQuizById>(_getVocabularySetQuizById);
  }

  Future<void> _getVocabularySetLearnById(
    GetVocabularySetLearnById event,
    Emitter<VocabularyState> emit,
  ) async {
    emit(state.cpyWith(formStatus: FormStatus.getVocabularySetLearnLoading));
    AppResponse appResponse = await sl
        .get<VocabularyRepository>()
        .getVocabularySetLearnById(setUuid: event.setUuid);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      try {
        final data = appResponse.data;
        List<VocabularyWordModel> words = [];
        if (data is List) {
          words = data
              .map(
                (x) => VocabularyWordModel.fromJson(x as Map<String, dynamic>),
              )
              .toList();
        }
        emit(
          state.cpyWith(
            formStatus: FormStatus.getVocabularySetLearnSuccess,
            learnWords: words,
          ),
        );
      } catch (e) {
        emit(
          state.cpyWith(
            formStatus: FormStatus.getVocabularySetLearnFailure,
            errorMessage: e.toString(),
          ),
        );
      }
    } else {
      emit(
        state.cpyWith(
          formStatus: FormStatus.getVocabularySetLearnFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> _getVocabularySetQuizById(
    GetVocabularySetQuizById event,
    Emitter<VocabularyState> emit,
  ) async {
    emit(state.cpyWith(formStatus: FormStatus.getVocabularySetQuizLoading));
    AppResponse appResponse = await sl
        .get<VocabularyRepository>()
        .getVocabularySetQuizById(setUuid: event.setUuid);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      try {
        final data = appResponse.data;
        List<VocabularyQuizWordModel> words = [];
        if (data is List) {
          words = data
              .map(
                (x) =>
                    VocabularyQuizWordModel.fromJson(x as Map<String, dynamic>),
              )
              .toList();
        }
        emit(
          state.cpyWith(
            formStatus: FormStatus.getVocabularySetQuizSuccess,
            quizWords: words,
          ),
        );
      } catch (e) {
        emit(
          state.cpyWith(
            formStatus: FormStatus.getVocabularySetQuizFailure,
            errorMessage: e.toString(),
          ),
        );
      }
    } else {
      emit(
        state.cpyWith(
          formStatus: FormStatus.getVocabularySetQuizFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
