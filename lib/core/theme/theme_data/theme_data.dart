import '../../core.dart';

final class Themes {
  static final cupertinoDarkTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.deepOrangeAccent,
    selectionHandleColor: CupertinoColors.white.withValues(alpha: .25),
    textTheme: const CupertinoTextThemeData(
      primaryColor: CupertinoColors.white,
    ),
  );

  static final cupertinoLightTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.deepOrangeAccent,
    selectionHandleColor: CupertinoColors.black.withValues(alpha: .25),
    textTheme: const CupertinoTextThemeData(
      primaryColor: CupertinoColors.black,
    ),
  );
}
