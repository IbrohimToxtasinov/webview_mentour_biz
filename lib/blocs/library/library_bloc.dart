import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/library/video_library_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/library_repository.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';

part 'library_event.dart';

part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc()
    : super(
        LibraryState(
          status: FormStatus.pure,
          errorMessage: "",
          libraryVideos: [],
        ),
      ) {
    on<GetLibraryVideos>(_getLibraryVideos);
  }

  Future<void> _getLibraryVideos(
    GetLibraryVideos event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(status: FormStatus.getLibraryVideosInLoading));
    AppResponse appResponse = await sl
        .get<LibraryRepository>()
        .getLibraryContentByType(
          itemType: event.itemType,
          levelId: event.levelId,
          schoolUuid: event.schoolUuid,
        );
    if (appResponse.errorMessage.isEmpty) {
      emit(
        state.copyWith(
          status: FormStatus.getLibraryVideosInSuccess,
          libraryVideos: (appResponse.data["content"] as List)
              .map((data) => VideoLibraryModel.fromJson(data))
              .toList(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: FormStatus.getLibraryVideosInFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
