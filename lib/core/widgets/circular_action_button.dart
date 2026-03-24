import '../../features/auth/widgets/user_avatar_widget.dart';
import '../core.dart';

class CircularActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? imageUrl;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double? elevation;
  final double iconSize;
  final bool showAnimation;
  final Duration? animationDuration;

  const CircularActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.imageUrl,
    this.iconColor,
    this.backgroundColor,
    this.size = 34.0,
    this.elevation,
    this.iconSize = 20.0,
    this.showAnimation = false,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? context.theme.primaryContrastingColor.withValues(alpha: .8);

    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    final activeBackgroundColor = isDark ? CupertinoColors.tertiarySystemGroupedBackground.darkColor : CupertinoColors.white;

    final effectiveBackgroundColor = backgroundColor ?? activeBackgroundColor.withValues(alpha: 1);
    Widget button = CustomButton(
      borderRadius: BorderRadius.circular(999),
      onPressed: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: effectiveBackgroundColor,
          boxShadow: [
            if (elevation != null)
              BoxShadow(
                color: context.cupertinoTheme.primaryContrastingColor.withValues(alpha: 0.125),
                blurRadius: 5,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: imageUrl != null
            ? UserAvatarWidget(photoUrl: imageUrl, radius: size / 2)
            : Icon(
                icon,
                size: iconSize,
                color: effectiveIconColor,
              ),
      ),
    );

    if (showAnimation) {
      return button.animate().fadeIn(
            duration: animationDuration ?? const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
          );
    }

    return button;
  }
}
