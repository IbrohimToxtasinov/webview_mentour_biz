import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/responses/app_response.dart';
import 'package:mentour_web_view/data/repositories/profile_repository.dart';
import 'package:mentour_web_view/data/repositories/singletons/storage.dart';
import 'package:mentour_web_view/services/di/locator.dart';
import 'package:mentour_web_view/utils/app_utils.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
    : super(
        const SettingsState(
          language: "en",
          themeMode: ThemeMode.light,
          updateRequired: false,
        ),
      ) {
    _loadLocale();
    _loadTheme();
  }

  Future<void> updateChecker({
    required String version,
    required String platform,
  }) async {
    AppResponse appResponse = await sl.get<ProfileRepository>().getAppVersion(
      version: version,
      platform: platform,
    );
    if (appResponse.data != null && appResponse.data["updateRequired"]) {
      emit(state.copyWith(updateRequired: true));
    } else {
      emit(state.copyWith(updateRequired: false));
    }
  }

  Future<void> _loadLocale() async {
    final language = StorageRepository.getString('language', defValue: "en");
    emit(state.copyWith(language: language));
  }

  Future<void> changeLocale(String language) async {
    await StorageRepository.putString('language', language);
    emit(state.copyWith(language: language));
  }

  Future<void> changeTheme(ThemeMode themMode) async {
    await StorageRepository.putString(
      'themeMode',
      AppUtils.themeModeToString(themMode),
    );
    emit(state.copyWith(themeMode: themMode));
  }

  Future<void> _loadTheme() async {
    final themeMode = StorageRepository.getString(
      'themeMode',
      defValue: "light",
    );
    emit(state.copyWith(themeMode: AppUtils.themeModeFromString(themeMode)));
  }
}
