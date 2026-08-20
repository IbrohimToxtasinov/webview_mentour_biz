part of 'navigator_bloc.dart';

class NavigatorUpdated extends Equatable {
  final int currentPage;
  final int previousPage;
  final int isActive;

  const NavigatorUpdated({
    required this.currentPage,
    required this.previousPage,
    required this.isActive,
  });

  NavigatorUpdated copyWith({
    int? currentPage,
    int? previousPage,
    int? isActive,
  }) => NavigatorUpdated(
    currentPage: currentPage ?? this.currentPage,
    previousPage: previousPage ?? this.previousPage,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [currentPage, previousPage, isActive];
}
