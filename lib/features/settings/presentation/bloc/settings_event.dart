import 'settings_state.dart';

abstract class SettingsEvent {}

class ToggleHighContrast extends SettingsEvent {
  final bool isEnabled;
  ToggleHighContrast(this.isEnabled);
}

class SetFontSize extends SettingsEvent {
  final double level;
  SetFontSize(this.level);
}

class ToggleReduceMotion extends SettingsEvent {
  final bool isEnabled;
  ToggleReduceMotion(this.isEnabled);
}

class ChangeAppMode extends SettingsEvent {
  final AppMode mode;
  ChangeAppMode(this.mode);
}

class UpdateDietaryPreference extends SettingsEvent {
  final String key;
  final bool value;
  UpdateDietaryPreference(this.key, this.value);
}

class UpdateAllergyPreference extends SettingsEvent {
  final String key;
  final bool value;
  UpdateAllergyPreference(this.key, this.value);
}