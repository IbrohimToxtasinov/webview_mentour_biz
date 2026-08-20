import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/attendance/attendance_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/attendance_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit()
    : super(
        AttendanceState(
          status: FormStatus.pure,
          errorMessage: "",
          attendance: AttendanceModel(
            lessonName: "",
            lessonDate: "",
            status: "",
            isMarked: false,
          ),
        ),
      );

  Future<void> getLastAttendance() async {
    if (isClosed) return;
    emit(state.copyWith(status: FormStatus.getLastAttendanceLoading));
    final AppResponse appResponse = await sl
        .get<AttendanceRepository>()
        .getLastAttendance();
    if (isClosed) return;
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      emit(
        state.copyWith(
          status: FormStatus.getLastAttendanceSuccess,
          attendance: AttendanceModel.fromJson(appResponse.data),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: FormStatus.getLastAttendanceFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
