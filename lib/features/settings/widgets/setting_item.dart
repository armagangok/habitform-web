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
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: EdgeInsets.all(padding ?? 2.5),
        child: Icon(
          iconData,
          color: Colors.white.withValues(alpha: .9),
        ),
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  final String title;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CupertinoListTile(
        leading: leading,
        title: Text(title),
        onTap: onTap,
        trailing: trailing ?? CupertinoListTileChevron(),
      ),
    );
  }
}
