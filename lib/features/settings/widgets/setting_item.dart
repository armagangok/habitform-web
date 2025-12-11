import '/core/core.dart';

class SettingLeadingWidget extends StatelessWidget {
  const SettingLeadingWidget({
    super.key,
    required this.iconData,
    required this.cardColor,
    this.padding,
  });

  final IconData iconData;
  final Color cardColor;
  final double? padding;

  @override
  Widget build(BuildContext context) {
    return CupertinoCard(
      color: cardColor,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: EdgeInsets.all(padding ?? 2),
        child: Icon(
          iconData,
          color: Colors.white.withValues(alpha: .9),
        ),
      ),
    );
  }
}
