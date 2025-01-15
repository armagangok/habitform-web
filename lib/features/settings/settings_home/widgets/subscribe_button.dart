import '../../../../core/core.dart';

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
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      width: .5,
                      color: context.colors.inverseSurface.withValues(alpha: .2),
                    ),
                  ),
                  child: Assets.app.appLogo.image(
                    width: 48,
                    height: 48,
                  ),
                ),
                SizedBox(width: 12),
                Column(
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
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'Pomo',
                            style: context.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'Done ',
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
                        )
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tap to see all advantages",
                      textAlign: TextAlign.start,
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
