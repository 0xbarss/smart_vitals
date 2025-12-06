import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<ToggleHighContrast>((event, emit) {
      emit(state.copyWith(highContrast: event.isEnabled));
    });

    on<SetFontSize>((event, emit) {
      emit(state.copyWith(fontSizeLevel: event.level));
    });

    on<ToggleReduceMotion>((event, emit) {
      emit(state.copyWith(reduceMotion: event.isEnabled));
    });

    on<ChangeAppMode>((event, emit) {
      emit(state.copyWith(appMode: event.mode));
    });
  }
}