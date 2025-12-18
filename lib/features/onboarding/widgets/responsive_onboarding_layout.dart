import 'package:flutter/cupertino.dart';

import '../../../core/core.dart';

/// Responsive layout wrapper for onboarding pages
/// Automatically switches between phone and tablet layouts
class ResponsiveOnboardingLayout extends StatelessWidget {
  const ResponsiveOnboardingLayout({
    super.key,
    required this.phoneLayout,
    required this.tabletLayout,
    this.maxContentWidth,
  });

  /// Layout for phones (< 600dp width)
  final Widget phoneLayout;

  /// Layout for tablets (>= 600dp width)
  final Widget tabletLayout;

  /// Optional maximum content width for large screens
  /// If null, uses ResponsiveHelper.getMaxContentWidth
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = ResponsiveHelper.isTablet(screenWidth) ||
        ResponsiveHelper.isTabletLandscape(screenWidth) ||
        ResponsiveHelper.isDesktop(screenWidth);

    // For tablets and larger screens, center content with max width
    if (isTablet) {
      final maxWidth = maxContentWidth ?? ResponsiveHelper.getMaxContentWidth(screenWidth);
      
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            minWidth: 0,
          ),
          child: tabletLayout,
        ),
      );
    }

    // For phones, use full width layout
    return phoneLayout;
  }
}

/// Responsive container that adapts padding and constraints based on device type
class ResponsiveOnboardingContainer extends StatelessWidget {
  const ResponsiveOnboardingContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxContentWidth,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = ResponsiveHelper.isTablet(screenWidth) ||
        ResponsiveHelper.isTabletLandscape(screenWidth) ||
        ResponsiveHelper.isDesktop(screenWidth);

    final effectivePadding = padding ??
        ResponsiveHelper.getResponsivePadding(
          screenWidth,
          phoneHorizontal: 0.06,
          tabletHorizontal: 0.08,
          tabletLandscapeHorizontal: 0.12,
          desktopHorizontal: 0.15,
        );

    Widget content = Padding(
      padding: effectivePadding,
      child: child,
    );

    // For tablets and larger, add max width constraint
    if (isTablet) {
      final maxWidth = maxContentWidth ?? ResponsiveHelper.getMaxContentWidth(screenWidth);
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    return content;
  }
}

