import '../core.dart';

class CustomSection extends StatelessWidget {
  final String? text;
  final Widget? child;
  final Widget? footer;
  final Widget? header;

  const CustomSection({
    super.key,
    this.text,
    this.child,
    this.footer,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return CupertinoListSection.insetGrouped(
        header: header ?? (text != null ? Text(text ?? "") : null),
        footer: footer,
        children: [
          if (child != null) child!,
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
