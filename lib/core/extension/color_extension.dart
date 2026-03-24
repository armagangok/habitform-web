import '../core.dart';

extension EasyLuminance on Color {
  Color get colorRegardingToBrightness {
    // Calculate the luminance (0.0 to 1.0) of the selected color
    final luminance = computeLuminance();

    // Set a threshold to determine if the color is bright
    const brightnessThreshold = 0.5;

    // If luminance is higher than threshold, use a darker icon color; otherwise, use a lighter icon color
    return luminance > brightnessThreshold ? Colors.black : Colors.white;
  }

  Color adaptiveShade(
    BuildContext context, {
    int lightShade = 400,
    int darkShade = 600,
  }) {
    final brightness = Theme.of(context).brightness;

    // Eğer renk bir MaterialColor ise, shade değerini temaya göre ayarla
    if (this is MaterialColor) {
      final materialColor = this as MaterialColor;
      return brightness == Brightness.dark
          ? materialColor[darkShade] ?? this // Koyu tema için daha koyu shade
          : materialColor[lightShade] ?? this; // Aydınlık tema için daha açık shade
    }

    // Eğer renk MaterialColor değilse, temaya göre basitçe karart veya aydınlat
    return brightness == Brightness.dark
        ? lighten(0.1) // Koyu tema için rengi karart
        : darken(0.1); // Aydınlık tema için rengi aydınlat
  }

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

/// Seçilen rengin tonunu koruyarak 9 opak varyasyon (opacity her zaman 1).
/// [0] en açık, [8] en koyu.

bool _isDarkTheme(BuildContext context) => CupertinoTheme.of(context).brightness == Brightness.dark;

extension ColorShades on Color {
  static const int _count = 9;
  static const double _lightnessMax = 0.92;
  static const double _lightnessMin = 0.12;

  Color get _opaqueRgb => withAlpha(255);

  /// 9 adet tam opak ton; girdi şeffaf olsa bile çıktı alpha = 1.
  List<Color> get shades {
    final hsl = HSLColor.fromColor(_opaqueRgb);
    final hue = hsl.hue;
    final saturation = hsl.saturation.clamp(0.0, 1.0);

    return List<Color>.generate(_count, (i) {
      final t = i / (_count - 1);
      final lightness = _lightnessMax - (_lightnessMax - _lightnessMin) * t;
      return HSLColor.fromAHSL(1.0, hue, saturation, lightness.clamp(0.0, 1.0)).toColor();
    });
  }

  /// [index] 0–8; tek bir ton döner (opacity 1).
  Color shade(int index) {
    assert(index >= 0 && index < _count, 'index must be 0..${_count - 1}');
    return shades[index];
  }

  /// Beyaz veya koyu gri daire zemini üzerinde tamamlanmamış (+) dolgusu.
  /// Tema [context] üzerinden okunur; çağıranın `isDark` geçmesi gerekmez.
  Color getOptimizedShade(BuildContext context) {
    return shade(_isDarkTheme(context) ? 7 : 1);
  }

  /// Scaffold / sayfa zemini üzerindeki isim etiketi arka planı.
  Color shadeForHabitNameChip(BuildContext context) {
    return shade(_isDarkTheme(context) ? 7 : 1);
  }
}
