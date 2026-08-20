part of 'navigator_bloc.dart';

@immutable
abstract class NavigatorEvent {}

class ChangePageEvent extends NavigatorEvent {
  final int pageIndex;
  ChangePageEvent({required this.pageIndex});
}

class ChangeTabEvent extends NavigatorEvent {
  final int isActive;
  ChangeTabEvent({required this.isActive});
}
