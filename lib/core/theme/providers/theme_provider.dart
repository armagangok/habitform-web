import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/core.dart';

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

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(_loadThemeMode()) {
    _initializeTheme();
  }

  static ThemeMode _loadThemeMode() {
    return ThemeMode.system;
  }

  void _initializeTheme() {
    final themeMode = HiveHelper.shared.getData<String?>(HiveBoxes.themeBox, HiveKeys.themeKey);
    if (themeMode != null) {
      state = themeMode.toThemeMode();
    }
  }

  void switchTheme(ThemeMode themeMode) {
    state = themeMode;
    Hive.box<String?>(HiveBoxes.themeBox).put(HiveKeys.themeKey, themeMode.toString());
  }

  void setDarkTheme() {
    state = ThemeMode.dark;
    Hive.box<String?>(HiveBoxes.themeBox).put(HiveKeys.themeKey, ThemeMode.dark.toString());
  }

  void setLightTheme() {
    state = ThemeMode.light;
    Hive.box<String?>(HiveBoxes.themeBox).put(HiveKeys.themeKey, ThemeMode.light.toString());
  }

  void setSystemTheme() {
    state = ThemeMode.system;
    Hive.box<String?>(HiveBoxes.themeBox).put(HiveKeys.themeKey, ThemeMode.system.toString());
  }
}
