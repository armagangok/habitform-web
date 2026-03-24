import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/theme/providers/theme_provider.dart';
import '../../purchase/providers/purchase_provider.dart';

class SubscribeButton extends ConsumerWidget {
  const SubscribeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paywallState = ref.watch(purchaseProvider);
    final state = paywallState.valueOrNull;
    final isPurchasing = state?.isPurchasing ?? false;

    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onTap: () => ref.read(purchaseProvider.notifier).presentPaywall(
                isFromOnboarding: false,
                isFromSettings: true,
              ),
          leading: Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeProvider);
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (themeMode == ThemeMode.dark ? Assets.app.appLogoDark : Assets.app.appLogoDark).image(
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                maxLines: 1,
                text: TextSpan(
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: LocaleKeys.subscription_subscribe_to.tr(),
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' Habit',
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Form ',
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.primary,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoCard(
                color: context.primary,
                elevation: 0,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Text(
                  'PRO',
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text(
            LocaleKeys.subscription_tap_advantages.tr(),
            textAlign: TextAlign.start,
            style: context.bodySmall.copyWith(
              color: context.cupertinoTextTheme.textStyle.color?.withValues(alpha: 0.7),
            ),
          ),
          additionalInfo: isPurchasing
              ? CupertinoActivityIndicator(
                  color: context.primary,
                )
              : null,
          trailing: const CupertinoListTileChevron(),
        ),
      ],
    );
  }
}
