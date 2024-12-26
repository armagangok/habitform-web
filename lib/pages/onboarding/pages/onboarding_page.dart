import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitrise/pages/onboarding/bloc/onboarding_bloc.dart';
import 'package:habitrise/pages/onboarding/pages/views/goal_view.dart';
import 'package:habitrise/pages/onboarding/pages/views/name_view.dart';

import '../../../core/extension/easy_context.dart';
import '../widgets/onboarding_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SizedBox(
        height: context.dynamicHeight,
        width: context.dynamicWidth,
        child: CupertinoPageScaffold(
          child: Stack(
            children: [
              PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  NameView(),
                  GoalView(),
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
                      child: BlocBuilder(
                        bloc: context.read<OnboardingBloc>(),
                        builder: (context, state) {
                          print(state);
                          return OnboardingButton(
                            onPressed: (state is NameValid || state is GoalValid)
                                ? () {
                                    _pageController.nextPage(duration: 500.ms, curve: Curves.easeIn);
                                    context.read<OnboardingBloc>().add(OnboardingInitialEvent());

                                    // context.read<OnboardingBloc>().add();
                                    // navigator.navigateAndClear(path: KRoute.homePage);
                                  }
                                : null,
                            buttonText: "Next",
                          ).animate().fadeIn(
                                delay: Duration(milliseconds: 900),
                              );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
