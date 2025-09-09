import 'package:flutter/cupertino.dart';

class MyListTile extends StatefulWidget {
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? additionalInfo;

  const MyListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.additionalInfo,
  });

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: widget.leading,
      additionalInfo: widget.additionalInfo,
      title: widget.title != null
          ? Text(
              widget.title!,
              maxLines: 999,
            )
          : SizedBox.shrink(),
      subtitle: widget.subtitle != null ? Text(widget.subtitle!, maxLines: 999) : null,
      trailing: widget.trailing,
      onTap: widget.onTap,
    );
  }
}
