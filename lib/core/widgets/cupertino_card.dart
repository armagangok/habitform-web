import 'package:habitform/core/core.dart';

/// A Cupertino-style card widget that replaces Material CupertinoCard
/// Uses iOS design language with rounded corners and subtle shadows
class CupertinoCard extends StatelessWidget {
  /// Creates a Cupertino-style card
  const CupertinoCard({
    super.key,
    this.child,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderWidth,
    this.elevation = 0,
    this.shadowColor,
    this.borderColor,
    this.onTap,
    this.shape,
  });

  /// The widget below this widget in the tree
  final Widget? child;

  /// The card's background color
  /// If null, uses theme-appropriate color
  final Color? color;

  final Color? borderColor;

  final double? borderWidth;

  /// The padding inside the card
  final EdgeInsetsGeometry? padding;

  /// The margin around the card
  final EdgeInsetsGeometry? margin;

  /// The border radius of the card
  final BorderRadius? borderRadius;

  /// The elevation of the card (iOS-style shadow)
  final double elevation;

  /// The color of the shadow
  final Color? shadowColor;

  /// Callback for tap events
  final VoidCallback? onTap;

  /// The shape of the card
  final BoxShape? shape;

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    // Use theme-appropriate decoration
    final decoration = _buildDecoration(context, isDark);

    Widget card = Container(
      margin: margin,
      decoration: decoration.copyWith(shape: shape),
      child: child != null
          ? Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            )
          : null,
    );

    // If onTap is provided, wrap with GestureDetector
    if (onTap != null) {
      card = CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _buildDecoration(BuildContext context, bool isDark) {
    final themeColor = color ?? (isDark ? CupertinoColors.tertiarySystemFill : CupertinoColors.tertiarySystemBackground);

    final radius = borderRadius ?? BorderRadius.circular(12);

    List<BoxShadow>? shadows;
    if (elevation > 0) {
      shadows = [
        BoxShadow(
          color: (shadowColor ?? CupertinoColors.systemGrey).withValues(alpha: 0.1),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation),
        ),
      ];
    }

    return BoxDecoration(
      color: themeColor,
      borderRadius: radius,
      boxShadow: shadows,
      // iOS-style subtle border
      border: Border.all(
        color: borderColor ?? (isDark ? CupertinoColors.systemGrey6.withValues(alpha: 0.1) : CupertinoColors.systemGrey5.withValues(alpha: 0.3)),
        width: borderWidth ?? 0.5,
      ),
    );
  }
}
