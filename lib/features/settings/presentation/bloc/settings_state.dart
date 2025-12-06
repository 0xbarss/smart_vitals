enum AppMode { normal, sports, sleep }

class SettingsState {
  final bool highContrast;
  final double fontSizeLevel;
  final bool reduceMotion;
  final AppMode appMode;

  const SettingsState({
    this.highContrast = false,
    this.fontSizeLevel = 1.0,
    this.reduceMotion = false,
    this.appMode = AppMode.normal,
  });

  SettingsState copyWith({
    bool? highContrast,
    double? fontSizeLevel,
    bool? reduceMotion,
    AppMode? appMode,
  }) {
    return SettingsState(
      highContrast: highContrast ?? this.highContrast,
      fontSizeLevel: fontSizeLevel ?? this.fontSizeLevel,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      appMode: appMode ?? this.appMode,
    );
  }
}