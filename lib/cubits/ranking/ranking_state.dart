part of 'ranking_cubit.dart';

class RankingState extends Equatable {
  final String errorMessage;
  final FormStatus status;
  final List<RankingUserModel> groupRanking;
  final List<RankingUserModel> schoolRanking;

  const RankingState({
    required this.errorMessage,
    required this.status,
    required this.groupRanking,
    required this.schoolRanking,
  });

  RankingState copyWith({
    String? errorMessage,
    FormStatus? status,
    List<RankingUserModel>? groupRanking,
    List<RankingUserModel>? schoolRanking,
  }) {
    return RankingState(
      errorMessage: errorMessage ?? this.errorMessage,
      status: status ?? this.status,
      groupRanking: groupRanking ?? this.groupRanking,
      schoolRanking: schoolRanking ?? this.schoolRanking,
    );
  }

  @override
  List<Object> get props => [errorMessage, status, groupRanking, schoolRanking];
}
