part of 'group_bloc.dart';

abstract class GroupEvent extends Equatable {
  const GroupEvent();
}

class GetStudentAllGroup extends GroupEvent {
  final int page;
  final bool isLoadMore;

  const GetStudentAllGroup({this.page = 0, this.isLoadMore = false});

  @override
  List<Object?> get props => [page, isLoadMore];
}
