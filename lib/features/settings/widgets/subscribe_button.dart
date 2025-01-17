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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Subscribe to ",
                          style: context.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textHeightBehavior: TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                        ),
                        RichText(
                          textHeightBehavior: TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          text: TextSpan(
                            text: 'Habit',
                            style: context.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'Rise ',
                                style: context.titleMedium?.copyWith(
                                  color: context.primary,
                                  fontWeight: FontWeight.bold,
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
                          textHeightBehavior: TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                        )
                      ],
                    ),
                    Text(
                      "Tap to see all advantages",
                      textAlign: TextAlign.start,
                      textHeightBehavior: TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
