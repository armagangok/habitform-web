import '../../../core/core.dart';
import '../../../core/theme/bloc/theme_bloc.dart';
import '../../paywall/bloc/paywall_bloc.dart';
import '../../paywall/widgets/paywall_widget.dart';

class SubscribeButton extends StatelessWidget {
  const SubscribeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaywallBloc, PaywallState>(
      builder: (context, state) {
        final isProductsFetching = state is PaywallLoading;
        if (isProductsFetching) {
          return CircularProgressIndicator();
        } else {
          return CustomButton(
            onTap: () async {
              context.read<PaywallBloc>().add(InitializePaywallEvent());

              showCupertinoModalBottomSheet(
                backgroundColor: Colors.transparent,
                barrierColor: Colors.transparent,
                expand: true,
                enableDrag: false,
                context: context,
                builder: (_) => PaywallWidget(),
              );

              // if (isSubscriptionActive) {
              //   CupertinoScaffold.showCupertinoModalBottomSheet(
              //     backgroundColor: Colors.transparent,
              //     barrierColor: Colors.transparent,
              //     expand: true,
              //     enableDrag: false,
              //     context: context,
              //     builder: (context) => MembershipInfoWidget(),
              //   );
              // } else {
              //   if (ref.read(purchaseProvider).offerings != null) {

              //   } else {
              //     AppFlushbar.shared.warningFlushbar(LocaleKeys.errors_something_went_wrong.tr());
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
                                RichText(
                                  maxLines: 1,
                                  text: TextSpan(
                                    style: context.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: LocaleKeys.subscription_subscribe_to.tr(),
                                        style: context.titleMedium?.copyWith(
                                          color: context.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' Habit',
                                        style: context.titleMedium?.copyWith(
                                          color: context.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Rise ',
                                        style: context.titleMedium?.copyWith(
                                          color: Colors.deepOrangeAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Pro',
                                        style: context.titleMedium?.copyWith(
                                          color: context.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
      },
    );
  }
}
