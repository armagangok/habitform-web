import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habitrise/core/extension/easy_context.dart';

import '../../../core/navigation/navigation.dart';
import '../../../gen/assets.gen.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_title.dart';

class OnboardingGreeting extends StatelessWidget {
  const OnboardingGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: context.height(.45),
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                  ),
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Assets.illustrations.greetingImage.image(
                    scale: 1.25,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Text(
                    "Welcome to HabitRise,",
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: DefaultTextStyle(
                            style: TextStyle(),
                            child: AnimatedTextKit(
                              repeatForever: true,
                              animatedTexts: [
                                RotateAnimatedText(
                                  "Minimalist.",
                                  duration: Duration(seconds: 2),
                                  textStyle: context.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                                ),
                                RotateAnimatedText(
                                  "Easy to Use.",
                                  duration: Duration(seconds: 2),
                                  textStyle: context.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                                ),
                                RotateAnimatedText(
                                  "Sicence-Based.",
                                  duration: Duration(seconds: 2),
                                  textStyle: context.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(
                      delay: Duration(milliseconds: 300),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0) + EdgeInsets.only(top: 10),
                child: GreetingText(),
              ),
              Spacer(flex: 4),
            ],
          ),
          SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OnboardingButton(
                    onPressed: () {
                      navigator.navigateAndClear(path: KRoute.onboardingPage);
                    },
                    buttonText: "🚀 Let's Start 🚀",
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 1200),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
