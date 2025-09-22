import 'dart:ui';

import 'package:flutter/cupertino.dart';

class CustomBlurWidget extends StatelessWidget {
  final Widget child;
  final double blurValue;
  final BorderRadius? borderRadius;

  const CustomBlurWidget({
    super.key,
    required this.child,
    this.blurValue = 10,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          tileMode: TileMode.mirror,
          sigmaX: blurValue,
          sigmaY: blurValue,
        ),
        child: child,
      ),
    );
  }
}
