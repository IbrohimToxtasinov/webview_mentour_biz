part of 'group_bloc.dart';

class GroupState extends Equatable {
  final List<GroupModel> groups;
  final String errorMessage;
  final FormStatus formStatus;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const GroupState({
    required this.groups,
    required this.errorMessage,
    required this.formStatus,
    required this.currentPage,
    required this.hasMore,
    required this.isLoadingMore,
  });

  GroupState copyWith({
    List<GroupModel>? groups,
    CourseDetailModel? courseDetail,
    String? errorMessage,
    FormStatus? formStatus,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return GroupState(
      groups: groups ?? this.groups,
      errorMessage: errorMessage ?? this.errorMessage,
      formStatus: formStatus ?? this.formStatus,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    groups,
    errorMessage,
    formStatus,
    currentPage,
    hasMore,
    isLoadingMore,
  ];
}
