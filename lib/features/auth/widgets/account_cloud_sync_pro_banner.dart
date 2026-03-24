import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../../purchase/providers/purchase_provider.dart';

/// Shown at the top of My Account when the user is signed in but does not have an active Pro subscription.
/// Cloud habit sync requires Pro; account management does not.
class AccountCloudSyncProBanner extends ConsumerWidget {
  const AccountCloudSyncProBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paywallAsync = ref.watch(purchaseProvider);
    final isPro = paywallAsync.valueOrNull?.isSubscriptionActive ?? false;
    final isLoading = paywallAsync is AsyncLoading;

    if (isLoading || isPro) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: CupertinoCard(
        borderRadius: BorderRadius.circular(12),
        borderColor: context.primary.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CupertinoIcons.cloud_fill,
                    size: 28,
                    color: context.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(LocaleKeys.auth_cloud_sync_pro_title),
                          style: context.titleMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr(LocaleKeys.auth_cloud_sync_pro_message),
                          style: context.bodyMedium.copyWith(
                            color: CupertinoColors.secondaryLabel.resolveFrom(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(vertical: 12),
                borderRadius: BorderRadius.circular(10),
                onPressed: () {
                  ref.read(purchaseProvider.notifier).presentPaywall(
                        isFromOnboarding: false,
                        isFromSettings: true,
                      );
                },
                child: Text(
                  context.tr(LocaleKeys.auth_cloud_sync_pro_cta),
                  style: context.titleSmall.copyWith(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
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
