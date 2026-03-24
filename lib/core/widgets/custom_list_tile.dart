import 'package:flutter/cupertino.dart';

class CustomListTile extends StatefulWidget {
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? additionalInfo;

  final Widget? titleWidget;

  const CustomListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.additionalInfo,
    this.titleWidget,
  });

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      leading: widget.leading,
      additionalInfo: widget.additionalInfo,
      title: widget.titleWidget != null
          ? widget.titleWidget!
          : widget.title != null
              ? Text(
                  widget.title!,
                  maxLines: 999,
                )
              : const SizedBox.shrink(),
      subtitle: widget.subtitle != null ? Text(widget.subtitle!, maxLines: 999) : null,
      trailing: widget.trailing,
      onTap: widget.onTap,
    );
  }
}
