import 'package:flutter/cupertino.dart';
import 'package:habitrise/gen/assets.gen.dart';
import 'package:habitrise/pages/onboarding/pages/views/goal_view.dart';
import 'package:habitrise/pages/onboarding/widgets/onboarding_message.dart';
import 'package:lottie/lottie.dart';

import '/core/core.dart';
import '../../widgets/onboarding_button.dart';

const int _duration = 3;

class OnboardingFinalPage extends StatefulWidget {
  const OnboardingFinalPage({super.key});

  @override
  State<OnboardingFinalPage> createState() => _OnboardingFinalPageState();
}

class _OnboardingFinalPageState extends State<OnboardingFinalPage> with SingleTickerProviderStateMixin {
  bool isLoading = false;

  @override
  void initState() {
    setState(() => isLoading = true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: _duration));

      setState(() => isLoading = false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LoadingToSuccessWidget(isLoading: isLoading),
                  SizedBox(height: 10),
                  Center(
                    child: OnboardingTitle(
                      data: isLoading ? "Please wait, we are creating the best template for  you!" : "Your habits created",
                      // style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (!isLoading)
                    OnboardingMessage(data: "Now you can start using the HabitRise"
                            // style: TextStyle(fontWeight: FontWeight.bold),
                            // textAlign: TextAlign.center,
                            )
                        .animate()
                        .fadeIn(),
                ],
              ),
            ),
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
                    onPressed: isLoading
                        ? null
                        : () {
                            navigator.navigateAndClear(path: KRoute.homeTabScaffoldPage);
                          },
                    buttonText: "Start Using HabitRise",
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

class LoadingToSuccessWidget extends StatelessWidget {
  final bool isLoading;
  final Duration animationDuration;

  const LoadingToSuccessWidget({
    super.key,
    required this.isLoading,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Lottie.asset(
            Assets.lottie.rocketAnimation, // Update with your Lottie asset path
            key: const ValueKey('loading'),
            height: 150,

            fit: BoxFit.cover,
            alignment: Alignment.center,
          )
        : SizedBox(
            height: 150,
            width: 150,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Icon(
                CupertinoIcons.check_mark_circled,
                key: const ValueKey('success'),
                color: context.primary,
              ),
            ),
          ).animate().fadeIn();
  }
}
