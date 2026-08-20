import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/data/models/profile/profile_model.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/profile_repository.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc()
    : super(
        ProfileState(
          formStatus: FormStatus.pure,
          errorMessage: "",
          profileModel: ProfileModel(
            balance: 0,
            firstName: "",
            lastName: "",
            rankingPosition: 0,
            profilePhoto: LogoModel(
              uuid: "",
              contentType: "",
              path: "",
              name: "",
            ),
            rankingLabel: "",
            schoolName: "",
            level: LevelModel(uuid: "", name: ""),
            fullName: "",
            coins: 0,
            score: 0,
            schoolInfo: SchoolInfo(
              region: ResRegion(
                name: "",
                country: "",
                phoneCode: "",
                currency: "",
                lang: "",
              ),
              uuid: "",
              logo: LogoModel(uuid: "", contentType: "", path: "", name: ""),
              name: "",
              address: "",
              studentCount: 0,
              classCount: 0,
              phoneNumber: "",
              teacherCount: 0,
              telegramLink: "",
            ),
          ),
        ),
      ) {
    on<GetProfileInfo>(_getProfile);
    on<UpdateProfile>(_updateProfile);
    on<EditPassword>(_editPassword);
  }

  Future<void> _getProfile(
    GetProfileInfo event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.getProfileInfoInLoading));
    await Future.delayed(const Duration(seconds: 1));
    try {
      AppResponse appResponse = await sl
          .get<ProfileRepository>()
          .getProfileInfo();
      if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
        emit(
          state.copyWith(
            formStatus: FormStatus.getProfileInfoInSuccess,
            profileModel: ProfileModel.fromJson(
              appResponse.data as Map<String, dynamic>,
            ),
          ),
        );
      } else {
        emit(
          state.copyWith(
            formStatus: FormStatus.getProfileInfoInFailure,
            errorMessage: appResponse.errorMessage,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          formStatus: FormStatus.getProfileInfoInFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _updateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.updateProfileInLoading));
    AppResponse appResponse = await sl.get<ProfileRepository>().updateProfile(
      firstName: event.firstName,
      lastName: event.lastName,
      imageId: event.imageId,
    );
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      emit(state.copyWith(formStatus: FormStatus.updateProfileInSuccess));
      add(GetProfileInfo());
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.updateProfileInFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }

  Future<void> _editPassword(
    EditPassword event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.editPasswordInLoading));
    AppResponse appResponse = await sl.get<ProfileRepository>().editPassword(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );
    if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
      emit(state.copyWith(formStatus: FormStatus.editPasswordInSuccess));
      add(GetProfileInfo());
    } else {
      emit(
        state.copyWith(
          formStatus: FormStatus.editPasswordInFailure,
          errorMessage: appResponse.errorMessage,
        ),
      );
    }
  }
}
