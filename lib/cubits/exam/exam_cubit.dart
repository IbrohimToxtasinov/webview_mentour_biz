import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/data/models/homeworks/homework_model.dart';

part 'exam_state.dart';

class ExamCubit extends Cubit<ExamState> {
  final HomeworksRepository _repository;

  ExamCubit(this._repository) : super(const ExamState());

  Future<void> startExam(String unitUuid) async {
    emit(
      state.copyWith(
        formStatus: FormStatus.startExamLoading,
        unitUuid: unitUuid,
      ),
    );

    final response = await _repository.startExam(unitUuid: unitUuid);

    if (response.errorMessage.isEmpty) {
      ExamPolicy? policy;
      if (response.data is Map<String, dynamic>) {
        policy = ExamPolicy.fromJson(response.data as Map<String, dynamic>);
      }
      emit(state.copyWith(
        formStatus: FormStatus.startExamSuccess,
        examPolicy: policy,
      ));
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.startExamFailure,
          errorMessage: response.errorMessage,
        ),
      );
    }
  }

  Future<void> resumeExam(String unitUuid) async {
    emit(
      state.copyWith(
        formStatus: FormStatus.resumeExamLoading,
        unitUuid: unitUuid,
      ),
    );

    final response = await _repository.resumeExam(unitUuid: unitUuid);

    if (response.errorMessage.isEmpty) {
      int remainingSeconds = 0;
      ExamPolicy? policy;
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        remainingSeconds = data['globalRemainingSeconds'] as int? ?? 0;
        policy = ExamPolicy.fromJson(data);
      }
      emit(
        state.copyWith(
          formStatus: FormStatus.resumeExamSuccess,
          globalRemainingSeconds: remainingSeconds,
          examPolicy: policy,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.resumeExamFailure,
          errorMessage: response.errorMessage,
        ),
      );
    }
  }
}
