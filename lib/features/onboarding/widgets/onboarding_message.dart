import 'package:flutter/material.dart';
import 'package:habitrise/core/extension/easy_context.dart';

class OnboardingMessage extends StatelessWidget {
  final String data;
  const OnboardingMessage({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: context.bodyLarge.copyWith(
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
