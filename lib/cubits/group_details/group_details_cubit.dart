import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/course/group_detail_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/course_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'group_details_state.dart';

class GroupDetailsCubit extends Cubit<GroupDetailsState> {
  GroupDetailsCubit()
    : super(
        const GroupDetailsState(
          groupDetails: [],
          formStatus: FormStatus.pure,
          errorMessage: '',
        ),
      );

  Future<void> getGroupDetails({required String courseId}) async {
    emit(state.copyWith(formStatus: FormStatus.getCourseGroupDetailsInLoading));
    AppResponse appResponse = await sl
        .get<CourseRepository>()
        .getCourseGroupDetails(courseId: courseId);
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      List<dynamic> rawList = [];
      if (appResponse.data is List) {
        rawList = appResponse.data as List;
      } else if (appResponse.data is Map) {
        rawList = appResponse.data["students"] as List;
      }

      final List<GroupDetailModel> groupDetails = rawList
          .map(
            (data) => GroupDetailModel.fromJson(data as Map<String, dynamic>),
          )
          .toList();
      emit(
        state.copyWith(
          formStatus: FormStatus.getCourseGroupDetailsInSuccess,
          groupDetails: groupDetails,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getCourseGroupDetailsInFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
