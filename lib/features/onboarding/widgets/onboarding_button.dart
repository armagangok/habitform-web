import '/core/core.dart';

class OnboardingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const OnboardingButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: onPressed,
      child: Card(
        color: Colors.blueAccent,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              buttonText,
              style: context.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
