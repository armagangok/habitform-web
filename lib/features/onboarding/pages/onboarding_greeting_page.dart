import '/core/core.dart';
import '../../../models/app_defaults/app_defaults.dart';
import '../../../services/app_default.dart';
import '../../paywall/bloc/paywall_bloc.dart';
import '../../paywall/widgets/onboarding_paywall_widget.dart';
import '../widgets/onboarding_button.dart';

class OnboardingGreetingPage extends StatefulWidget {
  const OnboardingGreetingPage({super.key});

  @override
  State<OnboardingGreetingPage> createState() => _OnboardingGreetingPageState();
}

class _OnboardingGreetingPageState extends State<OnboardingGreetingPage> {
  @override
  void initState() {
    context.read<PaywallBloc>().add(InitializePaywallEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Assets.images.aristoteles
                          .image(
                            height: context.height(0.4),
                            fit: BoxFit.cover,
                          )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 800.ms),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 30,
                            width: double.infinity,
                            color: Colors.black.withOpacity(.5),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Ἀριστοτέλης(Aristotle)  384 BC - 322 BC",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).animate(delay: 1000.ms).fadeIn(duration: 600.ms),
                    ],
                  ),
                ),
                Spacer(),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        LocaleKeys.onboarding_aristotleHabitQuote.tr(),
                        style: context.titleLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ).animate(delay: 1500.ms).fadeIn(duration: 800.ms),
                    ),
                  ],
                ),
                Spacer(flex: 3),
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
                      onPressed: () async {
                        final isSubscriptionActive = context.read<PaywallBloc>().state is PaywallResult && (context.read<PaywallBloc>().state as PaywallResult).isSubscriptionActive;

                        try {
                          final appDefaults = await AppDefaultsService().gettAppDefault();

                          if (appDefaults != null) {
                            final updatedDefaults = AppDefaults(isAppOpenedFirstTime: false);
                            await AppDefaultsService().saveAppDefaults(updatedDefaults);
                          }
                        } catch (e, s) {
                          LogHelper.shared.debugPrint(e.toString());
                          LogHelper.shared.debugPrint(s.toString());
                        }

                        if (isSubscriptionActive) {
                          navigator.navigateAndClear(path: KRoute.home);
                          return;
                        }

                        showCupertinoModalBottomSheet(
                          context: context,
                          enableDrag: false,
                          expand: true,
                          barrierColor: Colors.black,
                          builder: (context) => OnboardingPaywallWidget(),
                        );
                      },
                      buttonText: "${LocaleKeys.onboarding_get_started.tr()} 🚀",
                    ).animate().fadeIn(delay: 2200.ms, duration: 600.ms),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
