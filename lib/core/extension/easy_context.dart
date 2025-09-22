import 'package:flutter/cupertino.dart';

extension EasyContext on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  void hideKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isTablet => MediaQuery.of(this).size.width > 600;

  bool get isTabletOrLandscape => isTablet || isLandscape;

  Object? get arguments => ModalRoute.of(this)?.settings.arguments;

  void unfocus() => FocusScope.of(this).unfocus();
}

extension EasySize on BuildContext {
  double get dynamicHeight => mediaQuery.size.height;
  double get dynamicWidth => mediaQuery.size.width;

  double height(double value) => dynamicHeight * value;
  double width(double value) => dynamicWidth * value;

  double get lowWidth => dynamicWidth * 0.015;
  double get normalWidth => dynamicWidth * 0.025;
  double get mediumWidth => dynamicWidth * 0.035;
  double get bigWidth => dynamicWidth * 0.05;

  double get lowHeight => dynamicHeight * 0.015;
  double get normalHeight => dynamicHeight * 0.025;
  double get mediumHeight => dynamicHeight * 0.035;
  double get bigHeight => dynamicHeight * 0.05;
}

// A tiny proxy to provide Material-like naming while using Cupertino values
class CupertinoColorsProxy {
  CupertinoColorsProxy(this._theme);
  final CupertinoThemeData _theme;

  Color get primary => _theme.primaryColor;
  Color get surface => _theme.scaffoldBackgroundColor;
}

extension EasyTheme on BuildContext {
  CupertinoThemeData get theme => CupertinoTheme.of(this);
  Color get primary => theme.primaryColor;
  Color get primaryContrastingColor => theme.primaryContrastingColor;
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;
  Color get barBackgroundColor => theme.barBackgroundColor;
  CupertinoColorsProxy get colors => CupertinoColorsProxy(theme);

  // Adds selection handler color for consistent access
  Color get selectionHandleColor => theme.selectionHandleColor;

  // Hint/placeholder color aligned with Cupertino guidelines
  Color get hintColor => CupertinoColors.placeholderText.resolveFrom(this);

  IconThemeData get iconTheme => IconThemeData(color: theme.primaryColor);
}

extension EasyPadding on BuildContext {
  EdgeInsets get lowPadding => EdgeInsets.all(lowWidth);
  EdgeInsets get normalPadding => EdgeInsets.all(normalWidth);
  EdgeInsets get mediumPadding => EdgeInsets.all(mediumWidth);
  EdgeInsets get bigPadding => EdgeInsets.all(bigWidth);
  EdgeInsets padding(double ratio) => EdgeInsets.all(ratio * dynamicWidth);

  EdgeInsets get outerScaffoldPadding => EdgeInsets.all(dynamicWidth * 0.06);

  EdgeInsets symmetricPadding({
    double horizontal = 0.0,
    double vertical = 0.0,
  }) =>
      EdgeInsets.symmetric(
        horizontal: width(1.0) * horizontal,
        vertical: height(1.0) * vertical,
      );

  EdgeInsets only({
    double right = 0.0,
    double left = 0.0,
    double top = 0.0,
    double bottom = 0.0,
  }) =>
      EdgeInsets.only(
        left: left * dynamicWidth,
        right: right * dynamicWidth,
        bottom: bottom * dynamicHeight,
        top: top * dynamicHeight,
      );
}

extension EasyText on BuildContext {
  // Map common names to Cupertino text theme approximations
  TextStyle get cupertinoTextStyle => CupertinoTheme.of(this).textTheme.textStyle;
  CupertinoTextThemeData get cupertinoTextTheme => CupertinoTheme.of(this).textTheme;
  CupertinoThemeData get cupertinoTheme => CupertinoTheme.of(this);

  TextStyle get titleSmall => cupertinoTextTheme.textStyle.copyWith(fontSize: 13, fontWeight: FontWeight.w600);
  TextStyle get titleMedium => cupertinoTextTheme.textStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
  TextStyle get titleLarge => cupertinoTextTheme.navTitleTextStyle;

  TextStyle get labelSmall => cupertinoTextTheme.textStyle.copyWith(fontSize: 11);
  TextStyle get labelMedium => cupertinoTextTheme.textStyle.copyWith(fontSize: 13);
  TextStyle get labelLarge => cupertinoTextTheme.textStyle.copyWith(fontSize: 15);

  TextStyle get bodyLarge => cupertinoTextTheme.textStyle.copyWith(fontSize: 17);
  TextStyle get bodyMedium => cupertinoTextTheme.textStyle.copyWith(fontSize: 15);
  TextStyle get bodySmall => cupertinoTextTheme.textStyle.copyWith(fontSize: 13);

  TextStyle get headlineLarge => cupertinoTextTheme.navLargeTitleTextStyle;
  TextStyle get headlineMedium => cupertinoTextTheme.textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w600);
  TextStyle get headlineSmall => cupertinoTextTheme.textStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w600);

  TextStyle get displayLarge => cupertinoTextTheme.textStyle.copyWith(fontSize: 34, fontWeight: FontWeight.bold);
  TextStyle get displayMedium => cupertinoTextTheme.textStyle.copyWith(fontSize: 28, fontWeight: FontWeight.bold);
  TextStyle get displaySmall => cupertinoTextTheme.textStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold);

  String? get fontFamily => cupertinoTextTheme.textStyle.fontFamily;
}
