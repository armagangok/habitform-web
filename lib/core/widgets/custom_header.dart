import '../core.dart';

class CustomHeader extends StatelessWidget {
  final String text;
  final Widget? child;

  const CustomHeader({
    super.key,
    required this.text,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2.5,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    text,
                    style: context.bodySmall?.copyWith(
                      color: context.bodySmall?.color?.withAlpha(170),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (child != null) child!,
            ],
          )
        : SizedBox.shrink();
  }
}
