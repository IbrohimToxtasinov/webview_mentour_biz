part of 'group_details_cubit.dart';

class GroupDetailsState extends Equatable {
  final List<GroupDetailModel> groupDetails;
  final FormStatus formStatus;
  final String errorMessage;

  const GroupDetailsState({
    required this.groupDetails,
    required this.formStatus,
    required this.errorMessage,
  });

  GroupDetailsState copyWith({
    List<GroupDetailModel>? groupDetails,
    FormStatus? formStatus,
    String? errorMessage,
  }) {
    return GroupDetailsState(
      groupDetails: groupDetails ?? this.groupDetails,
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [groupDetails, formStatus, errorMessage];
}
