import 'package:flutter/material.dart';

class KSpacing {
  // Common padding values
  static EdgeInsets get smallPadding => const EdgeInsets.all(8.0); // Small padding
  static EdgeInsets get mediumPadding => const EdgeInsets.all(16.0); // Medium padding
  static EdgeInsets get largePadding => const EdgeInsets.all(24.0); // Large padding
  static EdgeInsets get extraLargePadding => const EdgeInsets.all(32.0); // Extra large padding

  // Common margin values
  static EdgeInsets get smallMargin => const EdgeInsets.all(8.0); // Small margin
  static EdgeInsets get mediumMargin => const EdgeInsets.all(16.0); // Medium margin
  static EdgeInsets get largeMargin => const EdgeInsets.all(24.0); // Large margin
  static EdgeInsets get extraLargeMargin => const EdgeInsets.all(32.0); // Extra large margin

  // Custom padding and margin functions
  static EdgeInsets symmetricPadding({double horizontal = 0.0, double vertical = 0.0}) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  static EdgeInsets only({double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0}) {
    return EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);
  }

  // Specific padding for Scaffold
  static EdgeInsets get scaffoldPadding => const EdgeInsets.all(16.0); // Padding for Scaffold

  // Specific padding for Scaffold
  static double get betweenListItems => 30.0; // Padding for Scaffold
}
