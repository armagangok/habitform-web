import '../core.dart';

class CircularActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final bool showAnimation;
  final Duration? animationDuration;

  const CircularActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size = 34.0,
    this.iconSize = 20.0,
    this.showAnimation = false,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? context.theme.selectionHandleColor.withValues(alpha: .8);
    final effectiveBackgroundColor = backgroundColor ?? context.theme.selectionHandleColor.withValues(alpha: .2);

    Widget button = CustomButton(
      onPressed: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CustomBlurWidget(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: effectiveBackgroundColor,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: effectiveIconColor,
            ),
          ),
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
