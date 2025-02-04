import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingLeadingWidget extends StatelessWidget {
  final Color cardColor;
  final double padding;
  final IconData iconData;

  const SettingLeadingWidget({
    super.key,
    required this.cardColor,
    required this.padding,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: cardColor,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Icon(
          iconData,
          color: CupertinoColors.white.withAlpha(200),
        ),
      ),
    );
  }
}
