import '../core.dart';

class CustomSection extends StatelessWidget {
  final String? text;
  final Widget? child;

  const CustomSection({
    super.key,
    this.text,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return CupertinoListSection.insetGrouped(
        header: text != null ? Text(text ?? "") : null,
        children: [
          if (child != null) child!,
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
