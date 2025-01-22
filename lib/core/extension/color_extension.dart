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

  Color adaptiveShade(BuildContext context, {int lightShade = 400, int darkShade = 600}) {
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
