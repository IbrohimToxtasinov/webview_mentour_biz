part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final String language;
  final bool updateRequired;
  final ThemeMode themeMode;

  const SettingsState({
    required this.language,
    required this.updateRequired,
    required this.themeMode,
  });

  SettingsState copyWith({
    String? language,
    ThemeMode? themeMode,
    bool? updateRequired,
  }) {
    return SettingsState(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      updateRequired: updateRequired ?? this.updateRequired,
    );
  }

  @override
  List<Object?> get props => [language, themeMode, updateRequired];
}
