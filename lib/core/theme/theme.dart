import '../core.dart';

final class Themes {
  static final darkTheme = ThemeData.dark().copyWith(
    primaryColor: Color(0xffFFAE00),
    scaffoldBackgroundColor: Colors.black,
    // platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.dark(
      primary: Color(0xffFFAE00),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xff3D3C41),
    ),
    appBarTheme: AppBarTheme(
      foregroundColor: Color(0xffFFAE00),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: CupertinoColors.white.withValues(alpha: .7)),
    cupertinoOverrideTheme: CupertinoThemeData(
      applyThemeToAll: true,
      primaryColor: Color(0xffFFAE00),
      scaffoldBackgroundColor: Colors.black,
      brightness: Brightness.dark,
      barBackgroundColor: Colors.transparent.withAlpha(0),
      textTheme: CupertinoTextThemeData(
        primaryColor: Color(0xffFFAE00),
      ),
    ),
  );

  static final lightTheme = ThemeData.light().copyWith(
    primaryColor: Colors.orange.shade700,
    // platform: TargetPlatform.iOS,
    colorScheme: ColorScheme.dark(
      primary: Colors.orange.shade700,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xffC6C6C8),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color.fromARGB(255, 231, 231, 231),
    ),
    appBarTheme: AppBarTheme(
      foregroundColor: Colors.orange.shade700,
      backgroundColor: Colors.transparent,
    ),
    iconTheme: IconThemeData(color: CupertinoColors.black.withValues(alpha: .5)),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      applyThemeToAll: true,
      barBackgroundColor: Color(0xffF2F2F7).withAlpha(0),
      scaffoldBackgroundColor: Color(0xffF2F2F7),
      brightness: Brightness.light,
      primaryColor: Colors.orange.shade700,
      textTheme: CupertinoTextThemeData(
        primaryColor: Colors.orange.shade700,
      ),
    ),
    scaffoldBackgroundColor: const Color(0xffF2F2F7),
  );
}
