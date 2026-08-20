part of 'coins_history_cubit.dart';

class CoinsHistoryState extends Equatable {
  final String errorMessage;
  final FormStatus status;
  final List<CoinsHistoryModel> coinsHistory;

  const CoinsHistoryState({
    required this.errorMessage,
    required this.status,
    required this.coinsHistory,
  });

  CoinsHistoryState copyWith({
    String? errorMessage,
    FormStatus? status,
    List<CoinsHistoryModel>? coinsHistory,
  }) {
    return CoinsHistoryState(
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      coinsHistory: coinsHistory ?? this.coinsHistory,
    );
  }

  @override
  List<Object> get props => [errorMessage, status, coinsHistory];
}
