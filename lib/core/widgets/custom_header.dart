import '../core.dart';

class CustomHeader extends StatelessWidget {
  final String? text;
  final Widget? child;

  const CustomHeader({
    super.key,
    this.text,
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
              if (text != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      text!.toUpperCase(),
                      style: context.bodySmall?.copyWith(
                        color: context.bodySmall?.color?.withAlpha(200),
                        fontWeight: FontWeight.w600,
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
