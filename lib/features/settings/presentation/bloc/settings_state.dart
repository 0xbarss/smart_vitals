class SettingsState {
  final bool highContrast;
  final double fontSizeLevel;
  final bool reduceMotion;

  const SettingsState({
    this.highContrast = false,
    this.fontSizeLevel = 1.0,
    this.reduceMotion = false,
  });

  SettingsState copyWith({
    bool? highContrast,
    double? fontSizeLevel,
    bool? reduceMotion,
  }) {
    return SettingsState(
      highContrast: highContrast ?? this.highContrast,
      fontSizeLevel: fontSizeLevel ?? this.fontSizeLevel,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}