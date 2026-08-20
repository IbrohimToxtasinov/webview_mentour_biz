part of 'vocabulary_detail_cubit.dart';

class VocabularyDetailState extends Equatable {
  final List<VocabularyModel> vocabularies;
  final String errorMessage;
  final FormStatus formStatus;

  const VocabularyDetailState({
    required this.vocabularies,
    required this.formStatus,
    required this.errorMessage,
  });

  VocabularyDetailState copyWith({
    String? errorMessage,
    FormStatus? formStatus,
    List<VocabularyModel>? vocabularies,
  }) {
    return VocabularyDetailState(
      vocabularies: vocabularies ?? this.vocabularies,
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
    );
  }

  @override
  List<Object> get props => [errorMessage, formStatus, vocabularies];
}
