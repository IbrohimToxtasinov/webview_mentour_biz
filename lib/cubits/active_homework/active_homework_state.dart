part of 'active_homework_cubit.dart';

class ActiveHomeworkState extends Equatable {
  final List<ActiveHomeworkGroup> groups;
  final String errorMessage;
  final FormStatus formStatus;

  const ActiveHomeworkState({
    required this.groups,
    required this.errorMessage,
    required this.formStatus,
  });

  ActiveHomeworkState copyWith({
    List<ActiveHomeworkGroup>? groups,
    String? errorMessage,
    FormStatus? formStatus,
  }) {
    return ActiveHomeworkState(
      groups: groups ?? this.groups,
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
    );
  }

  @override
  List<Object> get props => [groups, errorMessage, formStatus];
}
