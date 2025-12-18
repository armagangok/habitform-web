import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// Material 3 responsive breakpoints
/// Based on Material Design 3 guidelines for adaptive layouts
class ResponsiveBreakpoints {
  // Small screens (phones) - < 600dp
  static const double small = 600;

  // Medium screens (tablets portrait) - 600-840dp
  static const double medium = 840;

  // Large screens (tablets landscape) - 840-1200dp
  static const double large = 1200;

  // Extra large screens (desktop) - > 1200dp
  // No upper limit defined
}

/// Device type classification based on screen width
enum DeviceType {
  /// Small phones (< 600dp width)
  phone,

  /// Tablets in portrait or small foldables (600-840dp width)
  tablet,

  /// Tablets in landscape or large foldables (840-1200dp width)
  tabletLandscape,

  /// Desktop or very large screens (> 1200dp width)
  desktop,
}

/// Responsive layout helper
class ResponsiveHelper {
  /// Get device type based on screen width
  static DeviceType getDeviceType(double width) {
    if (width < ResponsiveBreakpoints.small) {
      return DeviceType.phone;
    } else if (width < ResponsiveBreakpoints.medium) {
      return DeviceType.tablet;
    } else if (width < ResponsiveBreakpoints.large) {
      return DeviceType.tabletLandscape;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if device is a phone
  static bool isPhone(double width) => width < ResponsiveBreakpoints.small;

  /// Check if device is a tablet (portrait)
  static bool isTablet(double width) => width >= ResponsiveBreakpoints.small && width < ResponsiveBreakpoints.medium;

  /// Check if device is a tablet (landscape) or large foldable
  static bool isTabletLandscape(double width) => width >= ResponsiveBreakpoints.medium && width < ResponsiveBreakpoints.large;

  /// Check if device is desktop or very large screen
  static bool isDesktop(double width) => width >= ResponsiveBreakpoints.large;

  /// Get maximum content width for better readability on large screens
  static double getMaxContentWidth(double screenWidth) {
    final deviceType = getDeviceType(screenWidth);
    switch (deviceType) {
      case DeviceType.phone:
        return screenWidth;
      case DeviceType.tablet:
        return 700; // Optimal reading width for tablets
      case DeviceType.tabletLandscape:
        return 900; // Optimal reading width for landscape tablets
      case DeviceType.desktop:
        return 1200; // Max content width for desktop
    }
  }

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(
    double screenWidth, {
    double phoneHorizontal = 0.06,
    double tabletHorizontal = 0.08,
    double tabletLandscapeHorizontal = 0.12,
    double desktopHorizontal = 0.15,
  }) {
    final deviceType = getDeviceType(screenWidth);
    double horizontalRatio;
    switch (deviceType) {
      case DeviceType.phone:
        horizontalRatio = phoneHorizontal;
        break;
      case DeviceType.tablet:
        horizontalRatio = tabletHorizontal;
        break;
      case DeviceType.tabletLandscape:
        horizontalRatio = tabletLandscapeHorizontal;
        break;
      case DeviceType.desktop:
        horizontalRatio = desktopHorizontal;
        break;
    }
    return EdgeInsets.symmetric(horizontal: screenWidth * horizontalRatio);
  }

  /// Get responsive column count for grid layouts
  static int getColumnCount(
    double screenWidth, {
    int phoneColumns = 1,
    int tabletColumns = 2,
    int tabletLandscapeColumns = 3,
    int desktopColumns = 4,
  }) {
    final deviceType = getDeviceType(screenWidth);
    switch (deviceType) {
      case DeviceType.phone:
        return phoneColumns;
      case DeviceType.tablet:
        return tabletColumns;
      case DeviceType.tabletLandscape:
        return tabletLandscapeColumns;
      case DeviceType.desktop:
        return desktopColumns;
    }
  }
}

/// Extension on BuildContext for responsive utilities
extension ResponsiveContext on BuildContext {
  /// Get device type for current context
  DeviceType get deviceType {
    final width = MediaQuery.of(this).size.width;
    return ResponsiveHelper.getDeviceType(width);
  }

  /// Check if current device is a phone
  bool get isPhone => ResponsiveHelper.isPhone(MediaQuery.of(this).size.width);

  /// Check if current device is a tablet (portrait)
  bool get isTabletPortrait => ResponsiveHelper.isTablet(MediaQuery.of(this).size.width);

  /// Check if current device is a tablet (landscape) or large foldable
  bool get isTabletLandscape => ResponsiveHelper.isTabletLandscape(MediaQuery.of(this).size.width);

  /// Check if current device is desktop or very large screen
  bool get isDesktop => ResponsiveHelper.isDesktop(MediaQuery.of(this).size.width);

  /// Get maximum content width for better readability
  double get maxContentWidth {
    final width = MediaQuery.of(this).size.width;
    return ResponsiveHelper.getMaxContentWidth(width);
  }

  /// Get responsive padding
  EdgeInsets get responsivePadding {
    final width = MediaQuery.of(this).size.width;
    return ResponsiveHelper.getResponsivePadding(width);
  }

  /// Check if device has a foldable hinge (display features)
  bool get hasFoldableHinge {
    final displayFeatures = MediaQuery.of(this).displayFeatures;
    return displayFeatures.any((feature) => feature.type == DisplayFeatureType.fold || feature.type == DisplayFeatureType.hinge);
  }

  /// Get foldable hinge bounds if available
  List<Rect> get foldableHingeBounds {
    final displayFeatures = MediaQuery.of(this).displayFeatures;
    return displayFeatures.where((feature) => feature.type == DisplayFeatureType.fold || feature.type == DisplayFeatureType.hinge).map((feature) => feature.bounds).toList();
  }
}
