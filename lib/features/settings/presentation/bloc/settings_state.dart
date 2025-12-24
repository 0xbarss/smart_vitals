enum AppMode { normal, sports, sleep }

class SettingsState {
  final bool highContrast;
  final double fontSizeLevel;
  final bool reduceMotion;
  final AppMode appMode;
  final Map<String, bool> dietary;
  final Map<String, bool> allergies;

  const SettingsState({
    this.highContrast = false,
    this.fontSizeLevel = 1.0,
    this.reduceMotion = false,
    this.appMode = AppMode.normal,
    this.dietary = const {
      'vegan': false,
      'vegetarian': false,
      'halal': false,
      'kosher': false,
    },
    this.allergies = const {
      'nuts': false,
      'gluten': false,
      'dairy': false,
      'soy': false,
      'shellfish': false,
      'eggs': false,
    },
  });

  SettingsState copyWith({
    bool? highContrast,
    double? fontSizeLevel,
    bool? reduceMotion,
    AppMode? appMode,
    Map<String, bool>? dietary,
    Map<String, bool>? allergies,
  }) {
    return SettingsState(
      highContrast: highContrast ?? this.highContrast,
      fontSizeLevel: fontSizeLevel ?? this.fontSizeLevel,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      appMode: appMode ?? this.appMode,
      dietary: dietary ?? this.dietary,
      allergies: allergies ?? this.allergies,
    );
  }
}