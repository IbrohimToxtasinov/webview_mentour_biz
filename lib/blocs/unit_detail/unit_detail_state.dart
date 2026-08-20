part of 'unit_detail_bloc.dart';

class UnitDetailState extends Equatable {
  final List<VocabularyModel> vocabularies;
  final HomeworkModel unit;
  final String errorMessage;
  final FormStatus formStatus;

  const UnitDetailState({
    required this.unit,
    required this.vocabularies,
    required this.formStatus,
    required this.errorMessage,
  });

  UnitDetailState copyWith({
    String? errorMessage,
    FormStatus? formStatus,
    List<VocabularyModel>? vocabularies,
    HomeworkModel? unit,
  }) {
    return UnitDetailState(
      unit: unit ?? this.unit,
      vocabularies: vocabularies ?? this.vocabularies,
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
    );
  }

  @override
  List<Object> get props => [errorMessage, formStatus, vocabularies, unit];
}
