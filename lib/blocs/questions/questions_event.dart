part of 'questions_bloc.dart';

abstract class QuestionsEvent extends Equatable {}

class GetQuestionsByTaskId extends QuestionsEvent {
  final String taskId;

  GetQuestionsByTaskId({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}
