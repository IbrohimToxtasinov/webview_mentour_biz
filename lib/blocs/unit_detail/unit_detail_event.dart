part of 'unit_detail_bloc.dart';

abstract class UnitDetailEvent extends Equatable {
  const UnitDetailEvent();
}

class GetUnitDetail extends UnitDetailEvent {
  final String unitId;

  const GetUnitDetail({required this.unitId});

  @override
  List<Object?> get props => [unitId];
}
