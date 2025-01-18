import '../core.dart';

class BodySmall extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? opacity;

  const BodySmall({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: context.bodySmall?.copyWith(
        color: color ?? context.bodySmall?.color?.withOpacity(opacity ?? 1),
      ),
    );
  }
}
