import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onTap,
    required this.child,
    this.onLongPressed,
  });

  final Function()? onTap;
  final Function()? onLongPressed;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPressed,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        alignment: Alignment.center,
        onPressed: () async {
          await HapticFeedback.mediumImpact();
          onTap?.call();
        },
        child: child,
      ),
    );
  }
}
