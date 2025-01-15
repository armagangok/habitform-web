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
}
