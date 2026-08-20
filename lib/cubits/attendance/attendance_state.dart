part of 'attendance_cubit.dart';

class AttendanceState extends Equatable {
  final FormStatus status;
  final String errorMessage;
  final AttendanceModel attendance;

  const AttendanceState({
    required this.status,
    required this.errorMessage,
    required this.attendance,
  });

  AttendanceState copyWith({
    FormStatus? status,
    String? errorMessage,
    AttendanceModel? attendance,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      attendance: attendance ?? this.attendance,
    );
  }

  @override
  List<Object> get props => [status, errorMessage, attendance];
}
