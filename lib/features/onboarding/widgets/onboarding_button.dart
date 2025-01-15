import '../../../core/core.dart';

class OnboardingButton extends StatefulWidget {
  const OnboardingButton({
    super.key,
    this.onPressed,
    required this.buttonText,
  });

  final dynamic Function()? onPressed;
  final String buttonText;

  @override
  State<OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<OnboardingButton> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(
      borderRadius: BorderRadius.circular(90),
      sizeStyle: CupertinoButtonSize.large,
      onPressed: widget.onPressed,
      child: Text(
        widget.buttonText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
