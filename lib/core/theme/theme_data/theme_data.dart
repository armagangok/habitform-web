import '../../core.dart';

final class Themes {
  static final cupertinoDarkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: CupertinoColors.systemOrange.darkColor,
    selectionHandleColor: CupertinoColors.black.withValues(alpha: .25),
    primaryContrastingColor: CupertinoColors.white.withValues(alpha: .25),
    textTheme: const CupertinoTextThemeData(
      primaryColor: CupertinoColors.white,
    ),
  );

  static final cupertinoLightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    
    primaryColor: CupertinoColors.systemOrange,
    selectionHandleColor: CupertinoColors.white,
    primaryContrastingColor: CupertinoColors.black.withValues(alpha: .25),
    scaffoldBackgroundColor: CupertinoColors.tertiarySystemGroupedBackground,
    textTheme: const CupertinoTextThemeData(
      primaryColor: CupertinoColors.black,
    ),
  );

}
