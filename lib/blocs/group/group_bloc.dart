import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/course/course_detail_model.dart';
import 'package:mentour_web_view/data/models/group/group_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/group_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'group_event.dart';

part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  GroupBloc()
    : super(
        GroupState(
          errorMessage: "",
          formStatus: FormStatus.pure,
          groups: [],
          currentPage: 0,
          hasMore: true,
          isLoadingMore: false,
        ),
      ) {
    on<GetStudentAllGroup>(_getStudentAllGroups);
  }

  Future<void> _getStudentAllGroups(
    GetStudentAllGroup event,
    Emitter<GroupState> emit,
  ) async {
    if (event.isLoadMore) {
      if (!state.hasMore || state.isLoadingMore) {
        return;
      }
      emit(state.copyWith(isLoadingMore: true));
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getStudentAllCoursesInLoading,
          currentPage: 0,
          groups: [],
          hasMore: true,
        ),
      );
      await Future.delayed(Duration(seconds: 1));
    }

    AppResponse appResponse = await sl
        .get<GroupRepository>()
        .getStudentAllGroups(page: event.page);

    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      final List<GroupModel> newGroups = (appResponse.data as List)
          .map((data) => GroupModel.fromJson(data as Map<String, dynamic>))
          .toList();

      // API returns a flat list (no pagination metadata)
      final bool hasMoreData = false;

      final List<GroupModel> updatedCourses = event.isLoadMore
          ? [...state.groups, ...newGroups]
          : newGroups;

      emit(
        state.copyWith(
          formStatus: FormStatus.getStudentAllCoursesInSuccess,
          groups: updatedCourses,
          currentPage: 0,
          hasMore: hasMoreData,
          isLoadingMore: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.getStudentAllCoursesInFailure,
          errorMessage: appResponse.errorMessage,
          isLoadingMore: false,
        ),
      );
    }
  }
}
