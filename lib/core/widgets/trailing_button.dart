import '/core/core.dart';

class TrailingActionButton extends StatelessWidget {
  const TrailingActionButton({
    super.key,
    this.title,
    this.child,
    required this.onPressed,
  });

  final String? title;
  final Widget? child;

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton.tinted(
      padding: EdgeInsets.zero,
      minSize: 0,
      borderRadius: BorderRadius.circular(8),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: child ??
            Text(
              title ?? "",
              style: context.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.primary,
              ),
            ),
      ),
    );
  }
}
