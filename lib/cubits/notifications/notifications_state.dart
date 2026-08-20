part of 'notifications_cubit.dart';

class NotificationsState extends Equatable {
  final FormStatus formStatus;
  final String errorMessage;
  final List<NotificationModel> notifications;
  final bool hasReachedMax;

  const NotificationsState({
    this.formStatus = FormStatus.pure,
    this.errorMessage = "",
    this.notifications = const [],
    this.hasReachedMax = false,
  });

  NotificationsState copyWith({
    FormStatus? formStatus,
    String? errorMessage,
    List<NotificationModel>? notifications,
    bool? hasReachedMax,
  }) {
    return NotificationsState(
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [
        formStatus,
        errorMessage,
        notifications,
        hasReachedMax,
      ];
}
