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
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(8),
      onPressed: onPressed,
      child: child ??
          Text(
            title ?? "",
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w500,
              
            ),
          ),
    );
  }
}
