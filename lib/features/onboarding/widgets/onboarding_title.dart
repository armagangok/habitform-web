import 'package:flutter/cupertino.dart';
import 'package:habitrise/core/extension/easy_context.dart';

class OnboardingTitle extends StatelessWidget {
  final String data;
  const OnboardingTitle({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: context.displayLarge.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class GreetingText extends StatelessWidget {
  const GreetingText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 18,
          color: CupertinoColors.black,
        ),
        children: [
          TextSpan(text: "Before everything, we want to know about you. Because, we want you to experience the"),
          TextSpan(text: " HabitRise ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: "better!"),
        ],
      ),
    );
  }
}
