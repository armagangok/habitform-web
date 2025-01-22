import 'package:habitrise/features/paywall/in_app_purchase/iap.dart';

import '/core/core.dart';
import 'paywall_widget.dart';

class MembershipInfoWidget extends StatelessWidget {
  const MembershipInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoScaffold(
      transitionBackgroundColor: Colors.transparent,
      body: CupertinoPageScaffold(
        navigationBar: SheetHeader(
          title: "My Premium Membership",
          closeButtonPosition: CloseButtonPosition.left,
        ),
        child: BlocBuilder<PaywallBloc, PaywallState>(
          builder: (context, state) {
            if (state is PaywallLoaded) {
              final customerInfo = state.customerInfo;

              final String? latestPurchaseDate = customerInfo?.entitlements.all["Premium"]?.latestPurchaseDate;
              final String? originalPurchaseDate = customerInfo?.entitlements.all["Premium"]?.originalPurchaseDate;
              final String? productPlanIdentifier = customerInfo?.entitlements.all["Premium"]?.productIdentifier;
              final String? expirationDate = customerInfo?.entitlements.all["Premium"]?.expirationDate;
              final bool? isActive = customerInfo?.entitlements.all["Premium"]?.isActive;
              final String? originalAppUserId = customerInfo?.originalAppUserId;

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
                              infoText: "Membersip State",
                              text: isActive == null
                                  ? null
                                  : isActive
                                      ? "Active"
                                      : "Inactive",
                            ),
                            _infoItemWidget(infoText: "Membership Plan", text: productPlanIdentifier),
                            _infoItemWidget(infoText: "Customer ID", text: originalAppUserId),
                            _infoItemWidget(infoText: "Expiration Date", text: expirationDate),
                            _infoItemWidget(infoText: "First Purchase Date", text: originalPurchaseDate),
                            _infoItemWidget(infoText: "Last Purchase Date", text: latestPurchaseDate),
                            _infoItemWidget(
                              infoText: "Change Subscription Plan",
                              text: "Change your plan as you wish",
                              onTap: () {
                                CupertinoScaffold.showCupertinoModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  barrierColor: Colors.transparent,
                                  expand: true,
                                  enableDrag: false,
                                  context: contextFromBuilder,
                                  builder: (_) => PaywallWidget(),
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
            } else {
              return SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _infoItemWidget({required String infoText, required String? text, Function()? onTap}) {
    if (text != null) {
      return Builder(builder: (context) {
        return CustomButton(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Card(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        infoText,
                        textAlign: TextAlign.left,
                        style: context.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        text,
                        textAlign: TextAlign.left,
                        style: context.bodyMedium?.copyWith(),
                      ),
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
