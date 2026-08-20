import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'navigator_event.dart';

part 'navigator_state.dart';

class NavigatorBloc extends Bloc<NavigatorEvent, NavigatorUpdated> {
  NavigatorBloc()
    : super(
        const NavigatorUpdated(currentPage: 0, previousPage: 0, isActive: 0),
      ) {
    on<ChangePageEvent>(_changePageEvent);
    on<ChangeTabEvent>(_changeTabEvent);
  }

  void _changePageEvent(ChangePageEvent event, Emitter<NavigatorUpdated> emit) {
    emit(
      state.copyWith(
        previousPage: state.currentPage,
        currentPage: event.pageIndex,
      ),
    );
  }

  void _changeTabEvent(ChangeTabEvent event, Emitter<NavigatorUpdated> emit) {
    emit(state.copyWith(isActive: event.isActive));
  }
}
