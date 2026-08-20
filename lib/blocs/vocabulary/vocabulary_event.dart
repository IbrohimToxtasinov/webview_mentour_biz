part of 'vocabulary_bloc.dart';

abstract class VocabularyEvent extends Equatable {}

class GetVocabularySetLearnById extends VocabularyEvent {
  final String setUuid;

  GetVocabularySetLearnById({required this.setUuid});

  @override
  List<Object?> get props => [setUuid];
}

class GetVocabularySetQuizById extends VocabularyEvent {
  final String setUuid;

  GetVocabularySetQuizById({required this.setUuid});

  @override
  List<Object?> get props => [setUuid];
}
