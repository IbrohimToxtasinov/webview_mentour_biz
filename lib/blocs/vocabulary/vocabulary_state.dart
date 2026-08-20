part of 'vocabulary_bloc.dart';

class VocabularyState extends Equatable {
  final FormStatus formStatus;
  final String errorMessage;
  final List<VocabularyWordModel> learnWords;
  final List<VocabularyQuizWordModel> quizWords;

  const VocabularyState({
    required this.formStatus,
    required this.errorMessage,
    required this.learnWords,
    required this.quizWords,
  });

  VocabularyState cpyWith({
    FormStatus? formStatus,
    String? errorMessage,
    List<VocabularyWordModel>? learnWords,
    List<VocabularyQuizWordModel>? quizWords,
  }) {
    return VocabularyState(
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      learnWords: learnWords ?? this.learnWords,
      quizWords: quizWords ?? this.quizWords,
    );
  }

  @override
  List<Object> get props => [formStatus, errorMessage, learnWords, quizWords];
}
