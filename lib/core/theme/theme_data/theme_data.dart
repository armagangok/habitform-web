import '../../core.dart';

final class Themes {
  static final darkTheme = ThemeData.dark().copyWith(
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.black,
    // platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.dark(
      primary: Colors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xff3D3C41),
    ),
    appBarTheme: AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color.fromARGB(255, 18, 20, 24),
    ),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      color: const Color(0XFF1C1C1E),
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
      ),
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: CupertinoColors.white.withValues(alpha: .7)),
    cupertinoOverrideTheme: CupertinoThemeData(
      applyThemeToAll: true,
      scaffoldBackgroundColor: Colors.black,
      brightness: Brightness.dark,
      barBackgroundColor: Colors.transparent.withAlpha(0),
      textTheme: CupertinoTextThemeData(),
    ),
  );

  static final lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.black,
    // platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.dark(
      primary: Colors.black,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xffC6C6C8),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color.fromARGB(255, 231, 231, 231),
    ),
    appBarTheme: AppBarTheme(
      foregroundColor: Colors.black,
      backgroundColor: Colors.transparent,
    ),
    iconTheme: IconThemeData(color: CupertinoColors.black.withValues(alpha: .5)),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
      ),
      elevation: 0,
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      applyThemeToAll: true,
      barBackgroundColor: Color(0xffF2F2F7).withAlpha(0),
      scaffoldBackgroundColor: Color(0xffF2F2F7),
      brightness: Brightness.light,
      textTheme: CupertinoTextThemeData(),
    ),
    scaffoldBackgroundColor: const Color(0xffF2F2F7),
  );
}
