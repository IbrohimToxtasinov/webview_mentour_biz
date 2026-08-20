import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:mentour_web_view/data/models/user/user_model.dart';
import 'package:mentour_web_view/data/repositories/profile_repository.dart';
import 'package:mentour_web_view/data/repositories/singletons/secure_storage.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/enums/auth_status.dart';
import 'package:mentour_web_view/utils/enums/form_status.dart';
import 'package:mentour_web_view/data/repositories/auth_repository.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<SignIn>(_signIn);
    on<LogOut>(_logOut);
    on<CheckUserRole>(_checkUserRoleAndStatus);
    on<CheckAuthStatus>(_checkAuthStatus);
    on<AutoSignIn>(_autoSignIn);
  }

  Future<void> _clearTokens() async {
    await SecureStorage.deleteAll();
  }

  Future<void> _signIn(SignIn event, Emitter<AuthState> emit) async {
    emit(state.copyWith(formStatus: FormStatus.signInLoading));

    try {
      final appResponse = await sl.get<AuthRepository>().signIn(
        userName: event.userName,
        password: event.password,
      );

      if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
        await SecureStorage.save(
          key: "accessToken",
          value: appResponse.data["accessToken"],
        );
        await SecureStorage.save(
          key: "refreshToken",
          value: appResponse.data["refreshToken"],
        );

        emit(state.copyWith(formStatus: FormStatus.signInSuccess));

        add(CheckUserRole());
      } else {
        emit(
          state.copyWith(
            formStatus: FormStatus.signInFailure,
            errorMessage: appResponse.errorMessage,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          formStatus: FormStatus.signInFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _checkUserRoleAndStatus(
    CheckUserRole event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.getProfileInfoInLoading));

    try {
      final appResponse = await sl.get<ProfileRepository>().getUserInfo();

      if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
        final profile = UserModel.fromJson(appResponse.data);

        emit(state.copyWith(formStatus: FormStatus.checkUserInLoading));

        if (profile.role == "STUDENT") {
          if (profile.status == "ACTIVE") {
            emit(state.copyWith(formStatus: FormStatus.checkUserInSuccess));
            add(PostFCMToken());
          } else {
            await _clearTokens();
            emit(
              state.copyWith(
                formStatus: FormStatus.checkUserInFailure,
                errorMessage: "school_not_accepted".tr(),
              ),
            );
          }
        } else {
          await _clearTokens();
          emit(
            state.copyWith(
              formStatus: FormStatus.checkUserInFailure,
              errorMessage: "userCannotUseApp".tr(),
            ),
          );
        }
      } else {
        await _clearTokens();
        emit(
          state.copyWith(
            formStatus: FormStatus.getProfileInfoInFailure,
            errorMessage: appResponse.errorMessage,
          ),
        );
      }
    } catch (e) {
      await _clearTokens();
      emit(
        state.copyWith(
          formStatus: FormStatus.getProfileInfoInFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _logOut(LogOut event, Emitter<AuthState> emit) async {
    _clearTokens();
    emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
  }

  Future<void> _autoSignIn(AutoSignIn event, Emitter<AuthState> emit) async {
    emit(state.copyWith(formStatus: FormStatus.signInLoading));
    await Future.delayed(const Duration(milliseconds: 1000));

    String errorMessage = "";

    try {
      final appResponse = await sl.get<AuthRepository>().signIn(
        userName: event.userName,
        password: event.password,
      );

      if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
        await SecureStorage.save(
          key: "accessToken",
          value: appResponse.data["accessToken"],
        );
        await SecureStorage.save(
          key: "refreshToken",
          value: appResponse.data["refreshToken"],
        );

        // Verify that the account is an active student.
        final profileResponse = await sl.get<ProfileRepository>().getUserInfo();

        if (profileResponse.errorMessage.isEmpty &&
            profileResponse.data != null) {
          final profile = UserModel.fromJson(profileResponse.data);

          if (profile.role == "STUDENT" && profile.status == "ACTIVE") {
            emit(
              state.copyWith(
                authStatus: AuthStatus.authenticated,
                formStatus: FormStatus.signInSuccess,
              ),
            );
            return;
          } else {
            errorMessage = profile.status != "ACTIVE"
                ? "school_not_accepted".tr()
                : "userCannotUseApp".tr();
          }
        } else {
          errorMessage = profileResponse.errorMessage;
        }

        // Role/status check failed — clear tokens.
        await _clearTokens();
      } else {
        errorMessage = appResponse.errorMessage;
      }
    } catch (e) {
      log("AUTO SIGN IN ERROR: $e");
      errorMessage = e.toString();
      await _clearTokens();
    }

    // Fall back: let the user log in manually.
    emit(
      state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        formStatus: FormStatus.signInFailure,
        errorMessage: errorMessage,
      ),
    );
  }

  Future<void> _checkAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(formStatus: FormStatus.getProfileInfoInLoading));
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      final token = await SecureStorage.get(key: "accessToken");

      if (token != null && token.isNotEmpty) {
        final appResponse = await sl.get<ProfileRepository>().getUserInfo();
        if (appResponse.errorMessage.isEmpty && appResponse.data != null) {
          final profile = UserModel.fromJson(appResponse.data);
          if (profile.status == "ACTIVE") {
            emit(
              state.copyWith(
                authStatus: AuthStatus.authenticated,
                formStatus: FormStatus.getProfileInfoInSuccess,
              ),
            );
          } else {
            await _clearTokens();
            emit(
              state.copyWith(
                authStatus: AuthStatus.unauthenticated,
                formStatus: FormStatus.getProfileInfoInFailure,
              ),
            );
          }
        } else {
          await _clearTokens();
          emit(
            state.copyWith(
              authStatus: AuthStatus.unauthenticated,
              formStatus: FormStatus.getProfileInfoInFailure,
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            authStatus: AuthStatus.unauthenticated,
            formStatus: FormStatus.pure,
          ),
        );
      }
    } catch (e) {
      await _clearTokens();
      emit(
        state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          formStatus: FormStatus.getProfileInfoInFailure,
        ),
      );
    }
  }
}
