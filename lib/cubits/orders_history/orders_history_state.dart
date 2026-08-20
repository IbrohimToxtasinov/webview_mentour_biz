part of 'orders_history_cubit.dart';

class OrdersHistoryState extends Equatable {
  final String errorMessage;
  final FormStatus status;
  final List<OrdersHistoryModel> ordersHistory;

  const OrdersHistoryState({
    required this.errorMessage,
    required this.status,
    required this.ordersHistory,
  });

  OrdersHistoryState copyWith({
    String? errorMessage,
    FormStatus? status,
    List<OrdersHistoryModel>? ordersHistory,
  }) {
    return OrdersHistoryState(
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      ordersHistory: ordersHistory ?? this.ordersHistory,
    );
  }

  @override
  List<Object> get props => [errorMessage, status, ordersHistory];
}
