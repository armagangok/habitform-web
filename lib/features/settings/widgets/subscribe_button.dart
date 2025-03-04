import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/theme/providers/theme_provider.dart';
import '../../purchase/page/paywall_page.dart';
import '../../purchase/providers/purchase_provider.dart';

class SubscribeButton extends ConsumerWidget {
  const SubscribeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paywallState = ref.watch(purchaseProvider);

    return paywallState.when(
      data: (state) {
        final isProductsFetching = state.isPurchasing;
        if (isProductsFetching) {
          return CircularProgressIndicator();
        } else {
          return CustomButton(
            onPressed: () async {
              showCupertinoModalBottomSheet(
                backgroundColor: Colors.transparent,
                barrierColor: Colors.transparent,
                expand: true,
                enableDrag: false,
                context: context,
                builder: (_) => PaywallPage(),
              );
            },
            child: Card(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final themeMode = ref.watch(themeProvider);
                          return themeMode == ThemeMode.dark
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
      loading: () => Center(child: CupertinoActivityIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
