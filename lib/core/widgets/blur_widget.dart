import 'dart:ui';

import 'package:flutter/cupertino.dart';

class CustomBlurWidget extends StatelessWidget {
  final Widget child;
  final double blurValue;

  const CustomBlurWidget({
    super.key,
    required this.child,
    this.blurValue = 10,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
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
