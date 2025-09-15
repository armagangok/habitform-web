import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../constants/constants.dart';
import '../providers/purchase_provider.dart';

class MembershipInfoWidget extends ConsumerWidget {
  final VoidCallback onCopyCustomerId;

  const MembershipInfoWidget({
    super.key,
    required this.onCopyCustomerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paywallState = ref.watch(purchaseProvider);

    return CupertinoPopupSurface(
      child: CupertinoPageScaffold(
        navigationBar: SheetHeader(
          closeButtonPosition: CloseButtonPosition.left,
        ),
        child: paywallState.when(
          data: (state) {
            final customerInfo = state.customerInfo;
            final entitlements = customerInfo?.entitlements;

            final String? latestPurchaseDate = entitlements?.all[entitlementID]?.latestPurchaseDate;
            final String? originalPurchaseDate = entitlements?.all[entitlementID]?.originalPurchaseDate;
            final String? productPlanIdentifier = entitlements?.all[entitlementID]?.productIdentifier;
            final String? expirationDate = entitlements?.all[entitlementID]?.expirationDate;

            final bool? isActive = entitlements?.all[entitlementID]?.isActive;
            final String? originalAppUserId = state.customerInfo?.originalAppUserId;

            return ListView(
              children: [
                Builder(
                  builder: (contextFromBuilder) {
                    return CupertinoListSection.insetGrouped(
                      header: Text(LocaleKeys.membership_info_title.tr()),
                      children: [
                        if (isActive != null)
                          _infoItemWidget(
                            infoText: LocaleKeys.membership_info_state.tr(),
                            text: isActive ? LocaleKeys.membership_info_active.tr() : LocaleKeys.membership_info_inactive.tr(),
                          ),
                        if (productPlanIdentifier != null) _infoItemWidget(infoText: LocaleKeys.membership_info_plan.tr(), text: productPlanIdentifier),
                        if (originalAppUserId != null)
                          _infoItemWidget(
                            infoText: LocaleKeys.membership_info_customer_id.tr(),
                            text: originalAppUserId,
                            onTap: () => onCopyCustomerId(),
                            trailing: CupertinoListTileChevron(),
                          ),
                        if (expirationDate != null) _infoItemWidget(infoText: LocaleKeys.membership_info_expiration_date.tr(), text: expirationDate),
                        if (originalPurchaseDate != null) _infoItemWidget(infoText: LocaleKeys.membership_info_first_purchase_date.tr(), text: originalPurchaseDate),
                        if (latestPurchaseDate != null) _infoItemWidget(infoText: LocaleKeys.membership_info_last_purchase_date.tr(), text: latestPurchaseDate),
                        _infoItemWidget(
                          infoText: LocaleKeys.membership_info_change_plan.tr(),
                          text: LocaleKeys.membership_info_change_plan_desc.tr(),
                          trailing: CupertinoListTileChevron(),
                          onTap: () {
                            navigator.navigateAndClear(
                              path: KRoute.prePaywall,
                              data: {'isFromOnboarding': false, 'isFromSettings': true},
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
          loading: () => Center(child: CupertinoActivityIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }

  Widget _infoItemWidget({
    required String infoText,
    required String? text,
    Function()? onTap,
    Widget? trailing,
  }) {
    if (text != null) {
      return Builder(builder: (context) {
        return CupertinoListTile(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          onTap: onTap,
          title: Text(infoText, maxLines: 999),
          subtitle: Text(text, maxLines: 999),
          trailing: trailing,
        );
      });
    } else {
      return Center();
    }
  }
}
