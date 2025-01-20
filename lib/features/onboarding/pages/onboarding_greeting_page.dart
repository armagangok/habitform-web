import '/core/core.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_title.dart';

class OnboardingGreetingPage extends StatelessWidget {
  const OnboardingGreetingPage({super.key});

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
                height: context.height(.5),
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                  ),
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Assets.illustrations.onboardingGreeting.image(
                    scale: 1.25,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Spacer(),
              Column(
                children: [
                  Text(
                    LocaleKeys.onboarding_welcome_message.tr(),
                    style: context.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate(delay: Duration(milliseconds: 300)).fadeIn(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0) + EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    GreetingText().animate(delay: Duration(milliseconds: 1500)).fadeIn(duration: Duration(milliseconds: 1000)),
                    SizedBox(height: 10),
                    Text(
                      LocaleKeys.onboarding_weRecommendYouToUseHabitRise.tr(),
                      style: context.titleMedium,
                      textAlign: TextAlign.center,
                    ).animate(delay: Duration(milliseconds: 3500)).fadeIn(duration: Duration(milliseconds: 1000)),
                  ],
                ),
              ),
              Spacer(flex: 5),
            ],
          ),
          SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0) + EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OnboardingButton(
                    onPressed: () {
                      navigator.navigateAndClear(path: KRoute.home);
                    },
                    buttonText: LocaleKeys.onboarding_get_started.tr(),
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 5500),
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
