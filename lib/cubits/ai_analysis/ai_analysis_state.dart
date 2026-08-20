part of 'ai_analysis_cubit.dart';

class AiAnalysisState extends Equatable {
  final ExerciseResultModel aiAnalysisResultModel;
  final FormStatus aiAnalysisFormStatus;
  final String errorMessage;

  const AiAnalysisState({
    required this.aiAnalysisResultModel,
    required this.aiAnalysisFormStatus,
    required this.errorMessage,
  });

  AiAnalysisState copyWith({
    ExerciseResultModel? aiAnalysisResultModel,
    FormStatus? aiAnalysisFormStatus,
    String? errorMessage,
  }) {
    return AiAnalysisState(
      aiAnalysisResultModel:
          aiAnalysisResultModel ?? this.aiAnalysisResultModel,
      aiAnalysisFormStatus: aiAnalysisFormStatus ?? this.aiAnalysisFormStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
    aiAnalysisResultModel,
    aiAnalysisFormStatus,
    errorMessage,
  ];
}
