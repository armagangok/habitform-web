import '../../../core/core.dart';
import '../../../core/theme/bloc/theme_bloc.dart';

class SubscribeButton extends StatelessWidget {
  const SubscribeButton({super.key});

  @override
  Widget build(BuildContext context) {
    // final isSubscriptionActive = false;

    return CustomButton(
      onTap: () async {
        // if (isSubscriptionActive) {
        //   CupertinoScaffold.showCupertinoModalBottomSheet(
        //     backgroundColor: Colors.transparent,
        //     barrierColor: Colors.transparent,
        //     expand: true,
        //     enableDrag: false,
        //     context: contextFromConsumer,
        //     builder: (context) => MembershipInfoWidget(),
        //   );
        // } else {
        //   if (ref.read(purchaseProvider).offerings != null) {
        //     CupertinoScaffold.showCupertinoModalBottomSheet(
        //       backgroundColor: Colors.transparent,
        //       barrierColor: Colors.transparent,
        //       expand: true,
        //       enableDrag: false,
        //       context: contextFromConsumer,
        //       builder: (_) => PaywallWidget(),
        //     );
        //   } else {
        //     AppFlushbar.shared.warningFlushbar(LocaleKeys.pleaseMakeSureThat.tr());
        //   }
        // }
      },
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return state.themeMode == ThemeMode.dark
                        ? Assets.app.habitriseDarkTransparent.image(
                            width: 40,
                            height: 40,
                          )
                        : Assets.app.habitriseLightTransparent.image(
                            width: 40,
                            height: 40,
                          );
                  },
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            LocaleKeys.subscription_subscribe_to.tr(),
                            style: context.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            textHeightBehavior: TextHeightBehavior(),
                          ),
                          RichText(
                            maxLines: 1,
                            text: TextSpan(
                              text: ' Habit',
                              style: context.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.75,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Rise ',
                                  style: context.titleMedium?.copyWith(
                                    color: context.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.75,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Pro",
                            style: context.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textHeightBehavior: TextHeightBehavior(),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            LocaleKeys.subscription_tap_advantages.tr(),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
