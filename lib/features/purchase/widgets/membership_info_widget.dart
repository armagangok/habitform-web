import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../constants/constants.dart';
import '../page/paywall_page.dart';
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

    return CupertinoScaffold(
      transitionBackgroundColor: Colors.transparent,
      body: CupertinoPageScaffold(
        navigationBar: SheetHeader(
          title: LocaleKeys.membership_info_title.tr(),
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
            final String? billingIssueDetectedAt = entitlements?.all[entitlementID]?.billingIssueDetectedAt;
            final bool? isActive = entitlements?.all[entitlementID]?.isActive;
            final String? originalAppUserId = state.customerInfo?.originalAppUserId;

            return ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Builder(
                    builder: (contextFromBuilder) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoItemWidget(
                            infoText: LocaleKeys.membership_info_state.tr(),
                            text: isActive == null
                                ? null
                                : isActive
                                    ? LocaleKeys.membership_info_active.tr()
                                    : LocaleKeys.membership_info_inactive.tr(),
                          ),
                          _infoItemWidget(infoText: LocaleKeys.membership_info_plan.tr(), text: productPlanIdentifier),
                          _infoItemWidget(
                            infoText: LocaleKeys.membership_info_customer_id.tr(),
                            text: originalAppUserId,
                            onTap: () => onCopyCustomerId(),
                            trailing: CupertinoListTileChevron(),
                          ),
                          _infoItemWidget(infoText: LocaleKeys.membership_info_billing_issue_detected_at.tr(), text: billingIssueDetectedAt),
                          _infoItemWidget(infoText: LocaleKeys.membership_info_expiration_date.tr(), text: expirationDate),
                          _infoItemWidget(infoText: LocaleKeys.membership_info_first_purchase_date.tr(), text: originalPurchaseDate),
                          _infoItemWidget(infoText: LocaleKeys.membership_info_last_purchase_date.tr(), text: latestPurchaseDate),
                          _infoItemWidget(
                            infoText: LocaleKeys.membership_info_change_plan.tr(),
                            text: LocaleKeys.membership_info_change_plan_desc.tr(),
                            trailing: CupertinoListTileChevron(),
                            onTap: () {
                              CupertinoScaffold.showCupertinoModalBottomSheet(
                                backgroundColor: Colors.transparent,
                                barrierColor: Colors.transparent,
                                expand: true,
                                enableDrag: false,
                                context: contextFromBuilder,
                                builder: (_) => PaywallPage(),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
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

  Widget _infoItemWidget({required String infoText, required String? text, Function()? onTap, Widget? trailing}) {
    if (text != null) {
      return Builder(builder: (context) {
        return CustomButton(
          onPressed: onTap,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Card(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              infoText,
                              textAlign: TextAlign.left,
                              style: context.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.titleMedium?.color?.withValues(alpha: 0.9),
                              ),
                            ),
                            Text(
                              text,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.bodyMedium?.copyWith(
                                color: context.bodyMedium?.color?.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 10),
                        trailing,
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });
    } else {
      return SizedBox.shrink();
    }
  }
}
