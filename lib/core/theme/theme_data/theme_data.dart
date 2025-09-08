import '../../core.dart';

final class Themes {
  static final cupertinoDarkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    selectionHandleColor: CupertinoColors.white.withValues(alpha: .25),
    textTheme: const CupertinoTextThemeData(
      primaryColor: CupertinoColors.white,
    ),
  );

  static final cupertinoLightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    selectionHandleColor: CupertinoColors.black.withValues(alpha: .25),
    textTheme: const CupertinoTextThemeData(
      primaryColor: CupertinoColors.black,
    ),
  );
}
