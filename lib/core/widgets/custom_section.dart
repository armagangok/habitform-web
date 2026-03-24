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
    final isDark = context.theme.brightness == Brightness.dark;
    if (child != null) {
      return CupertinoListSection.insetGrouped(
        decoration: BoxDecoration(
          color: isDark ? CupertinoColors.tertiarySystemGroupedBackground.darkColor : CupertinoColors.white,
        ),
        header: header ?? (text != null ? Text(text ?? "") : null),
        footer: footer,
        children: [
          if (child != null) child!,
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
