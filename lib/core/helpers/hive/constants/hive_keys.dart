final class HiveKeys {
  const HiveKeys._();

  static const String habitBoxKey = "singleHabitBoxKey";
  static const String themeKey = "themeKeyHabitRise";
  static const String userDefaultsKey = 'userDefaultsKeyHabitRise';
  static const String habitRiseDefaultsKeys = 'habitRiseDefaultsKeys';
  static const String localeKey = 'localeKeyHabitForm';

  /// Stable per-app-install id (UUID); persists across login/logout, not cleared with user data.
  static const String installIdKey = 'appInstallIdKeyHabitForm';
}
