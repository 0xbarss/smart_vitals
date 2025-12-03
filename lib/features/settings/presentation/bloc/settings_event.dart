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