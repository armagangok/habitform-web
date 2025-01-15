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
    final currentTheme = state.themeMode;
    ThemeMode newTheme;

    switch (currentTheme) {
      case ThemeMode.dark:
        newTheme = ThemeMode.light;
        break;
      case ThemeMode.light:
        newTheme = ThemeMode.system;
        break;
      case ThemeMode.system:
        newTheme = ThemeMode.dark;
        break;
    }

    HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, newTheme.toString());
    emit(ThemeState(newTheme));
  }

  void _onSetDarkTheme(SetDarkThemeEvent event, Emitter<ThemeState> emit) {
    HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.dark.toString());
    emit(ThemeState(ThemeMode.dark));
  }

  void _onSetLightTheme(SetLightThemeEvent event, Emitter<ThemeState> emit) {
    HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.light.toString());
    emit(ThemeState(ThemeMode.light));
  }

  void _onSetSystemTheme(SetSystemThemeEvent event, Emitter<ThemeState> emit) {
    HiveHelper.shared.putData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey, ThemeMode.system.toString());
    emit(ThemeState(ThemeMode.system));
  }
}
