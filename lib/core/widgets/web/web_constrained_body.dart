import 'package:flutter/cupertino.dart';

import '../../helpers/responsive_helper.dart';

/// Centers content and caps width for readable layouts in the browser.
class WebConstrainedBody extends StatelessWidget {
  const WebConstrainedBody({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cap = maxWidth ?? ResponsiveHelper.getMaxContentWidth(width);
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: Padding(
          padding: padding ?? ResponsiveHelper.getResponsivePadding(width),
          child: child,
        ),
      ),
    );
  }
}
