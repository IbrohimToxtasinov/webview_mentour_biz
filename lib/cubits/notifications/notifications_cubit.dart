import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/notification/notification_model.dart';
import 'package:mentour_web_view/data/repositories/notifications_repository.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;

  NotificationsCubit(this._repository) : super(const NotificationsState());

  int _currentPage = 0;
  final int _pageSize = 20;

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      emit(
        state.copyWith(
          formStatus: FormStatus.fetchNotificationsInLoading,
          notifications: [],
          hasReachedMax: false,
        ),
      );
    } else {
      if (state.hasReachedMax || state.formStatus == FormStatus.fetchNotificationsInLoading) return;
      emit(state.copyWith(formStatus: FormStatus.fetchNotificationsInLoading));
    }

    final response = await _repository.getNotifications(page: _currentPage, size: _pageSize);

    if (response.errorMessage.isEmpty) {
      final List<dynamic> jsonList = response.data['content'] ?? response.data;
      
      final List<NotificationModel> newNotifications = 
          jsonList.map((e) => NotificationModel.fromJson(e)).toList();

      final hasReachedMax = newNotifications.isEmpty || newNotifications.length < _pageSize;

      emit(
        state.copyWith(
          formStatus: FormStatus.fetchNotificationsInSuccess,
          notifications: List.of(state.notifications)..addAll(newNotifications),
          hasReachedMax: hasReachedMax,
        ),
      );
      _currentPage++;
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.fetchNotificationsInFailure,
          errorMessage: response.errorMessage,
        ),
      );
    }
  }
}
