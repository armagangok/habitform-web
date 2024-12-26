import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/core.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_button.dart';
import 'views/goal_view.dart';
import 'views/name_view.dart';

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
                          debugPrint(state.toString());
                          return OnboardingButton(
                            onPressed: (state is NameValid || state is GoalValid)
                                ? () {
                                    if (state is NameValid) {
                                      _pageController.nextPage(duration: 500.ms, curve: Curves.easeIn);
                                      context.read<OnboardingBloc>().add(OnboardingInitialEvent());
                                    }

                                    if (state is GoalValid) {
                                      navigator.navigateAndClear(path: KRoute.onboardingFinalPage);
                                    }

                                    // context.read<OnboardingBloc>().add();
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
