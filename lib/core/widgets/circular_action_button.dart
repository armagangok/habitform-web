import '../core.dart';

class CircularActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? imageUrl;
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
    this.imageUrl,
    this.iconColor,
    this.backgroundColor,
    this.size = 34.0,
    this.iconSize = 20.0,
    this.showAnimation = false,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? context.theme.primaryContrastingColor.withValues(alpha: .8);
    final effectiveBackgroundColor = backgroundColor ?? context.theme.selectionHandleColor;

    Widget button = CustomButton(
      borderRadius: BorderRadius.circular(999),
      onPressed: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: effectiveBackgroundColor,
          border: Border.all(
            color: context.cupertinoTheme.primaryContrastingColor.withValues(alpha: 0.125),
            width: .7,
          ),
          boxShadow: [
            BoxShadow(
              color: context.cupertinoTheme.primaryContrastingColor.withValues(alpha: 0.125),
              blurRadius: 5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    icon,
                    size: iconSize,
                    color: effectiveIconColor,
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CupertinoActivityIndicator(
                        radius: iconSize / 2,
                      ),
                    );
                  },
                ),
              )
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
