import 'package:hive_flutter/hive_flutter.dart';

import '../../core.dart';

part 'theme_event.dart';
part 'theme_state.dart';

extension EasyString on String {
  ThemeMode toThemeMode() {
    switch (this) {
      case "ThemeMode.dark":
        return ThemeMode.dark;
      case "ThemeMode.light":
        return ThemeMode.light;
      case "ThemeMode.system":
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(ThemeMode.system)) {
    on<InitializeThemeEvent>(_onInitializeTheme);
    on<SwitchThemeEvent>(_onSwitchTheme);
    on<SetDarkThemeEvent>(_onSetDarkTheme);
    on<SetLightThemeEvent>(_onSetLightTheme);
    on<SetSystemThemeEvent>(_onSetSystemTheme);

    // Trigger the initialization event
    add(InitializeThemeEvent());
  }

  void _onInitializeTheme(InitializeThemeEvent event, Emitter<ThemeState> emit) {
    final themeMode = HiveHelper.shared.getData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey);
    if (themeMode != null) {
      emit(ThemeState(themeMode.toThemeMode()));
    }
  }

  void _onSwitchTheme(SwitchThemeEvent event, Emitter<ThemeState> emit) {
    final newTheme = event.themeMode;
    emit(ThemeState(newTheme));
    Hive.box<String?>(HiveBoxes.themeBox).put(HiveKeys.themeKey, newTheme.toString());
  }

  void _onSetDarkTheme(SetDarkThemeEvent event, Emitter<ThemeState> emit) {
    emit(ThemeState(ThemeMode.dark));
    Hive.box<String?>(HiveBoxes.themeBox).put(HiveKeys.themeKey, ThemeMode.dark.toString());
  }

  void _onSetLightTheme(SetLightThemeEvent event, Emitter<ThemeState> emit) {
    emit(ThemeState(ThemeMode.light));
    Hive.box<String?>(HiveBoxes.themeBox).put(HiveKeys.themeKey, ThemeMode.light.toString());
  }

  void _onSetSystemTheme(SetSystemThemeEvent event, Emitter<ThemeState> emit) {
    emit(ThemeState(ThemeMode.system));
    Hive.box<String?>(HiveBoxes.themeBox).put(HiveKeys.themeKey, ThemeMode.system.toString());
  }
}
