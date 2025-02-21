import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/core/core.dart' hide LocaleKeys;
import '/core/helpers/url_laucher/url_launcher.dart';
import '/core/widgets/blur_widget.dart';
import '/core/widgets/flushbar_widget.dart';
import '/core/widgets/setting_leading.dart';
import '../../translation/constants/locale_keys.g.dart';
import '../bloc/paywall_bloc.dart';
import '../in_app_purchase/constants.dart';
import '../in_app_purchase/revenue_cat_helper.dart';
import 'product_widget.dart';

class PaywallWidget extends StatefulWidget {
  const PaywallWidget({super.key});

  @override
  State<PaywallWidget> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends State<PaywallWidget> with SingleTickerProviderStateMixin {
  int selectedIndex = 2;
  Package? selectedPackage;

  final List<FeatureModel> featureList = [
    FeatureModel(
      LocaleKeys.subscription_unlimitiedHabits.tr(),
      CupertinoIcons.square_grid_3x2,
      LocaleKeys.subscription_unlimitiedHabitsDescription.tr(),
      Colors.blue,
    ),
    FeatureModel(
      LocaleKeys.subscription_unlimitiedCustomization.tr(),
      CupertinoIcons.create_solid,
      LocaleKeys.subscription_unlimitiedCustomizationDescription.tr(),
      Colors.red,
    ),
    FeatureModel(
      LocaleKeys.subscription_alwaysUpToDate.tr(),
      CupertinoIcons.refresh_thick,
      LocaleKeys.subscription_alwaysUpToDateDescription.tr(),
      Colors.cyan,
    ),
    FeatureModel(
      LocaleKeys.subscription_upcomingFeatures.tr(),
      CupertinoIcons.timelapse,
      LocaleKeys.subscription_upcomingFeaturesDescription.tr(),
      Colors.green,
    ),
    FeatureModel(
      LocaleKeys.subscription_noBoringAds.tr(),
      Icons.do_not_disturb_alt,
      LocaleKeys.subscription_noBoringAdsDescription.tr(),
      Colors.orange,
    ),
    FeatureModel(
      LocaleKeys.subscription_supportAnIndieDev.tr(),
      CupertinoIcons.heart_fill,
      LocaleKeys.subscription_supportAnIndieDevDescription.tr(),
      Colors.pinkAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: BlocConsumer<PaywallBloc, PaywallState>(
        listener: (context, state) {
          if (state is PaywallError) {
            AppFlushbar.shared.warningFlushbar(state.message);
          }

          if (state is PaywallResult) {
            if (state.errorMessage != null) {
              AppFlushbar.shared.warningFlushbar(state.errorMessage!);
            } else if (state.isPurchaseCompleted) {
              Navigator.of(context).pop();
              AppFlushbar.shared.successFlushbar(RevenueCatHelper.purchaseSuccessMessage);
            }
          }
        },
        builder: (context, state) {
          if (state is PaywallInitializing) {
            return Center(child: CupertinoActivityIndicator());
          }

          if (state is PaywallResult) {
            selectedPackage ??= state.offerings?.current?.lifetime;

            return CupertinoPageScaffold(
              navigationBar: _navBar(context),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ListView(
                        children: [
                          SizedBox(height: 20),
                          _productSection(state),
                          SizedBox(height: 40),
                          Text(
                            LocaleKeys.subscription_whatYouWillUnlock.tr(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 10),
                          ListView.separated(
                            physics: ClampingScrollPhysics(),
                            itemCount: featureList.length,
                            shrinkWrap: true,
                            separatorBuilder: (_, __) => SizedBox(height: 15),
                            itemBuilder: (context, index) {
                              final feature = featureList[index];

                              return CupertinoListTile(
                                padding: EdgeInsets.zero,
                                leadingSize: 40,
                                leading: SettingLeadingWidget(
                                  cardColor: feature.color.withAlpha(110),
                                  padding: 7,
                                  iconData: feature.widget,
                                ),
                                title: Text(feature.name),
                                subtitle: Text(
                                  feature.description,
                                  maxLines: 3,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 160),
                        ],
                      ),
                    ),
                  ),
                  _continueButton(state),
                ],
              ),
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }

  ObstructingPreferredSizeWidget _navBar(BuildContext context) {
    return SheetHeader(
      middle: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Habit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              children: [
                TextSpan(
                  text: 'Rise  ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.deepOrangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextSpan(
                  text: 'Pro',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      closeButtonPosition: CloseButtonPosition.left,
    );
  }

  Widget _continueButton(PaywallState paywallState) {
    if (paywallState is PaywallResult) {
      final purchaseLoading = paywallState.isPurchasing;
      final isSubscriptionActive = paywallState.isSubscriptionActive;

      return Align(
        alignment: Alignment.bottomCenter,
        child: CustomBlurWidget(
          blurValue: 20,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: purchaseLoading
                        ? null
                        : () async {
                            HapticFeedback.heavyImpact();
                            if (isSubscriptionActive && selectedPackage?.identifier == paywallState.customerInfo?.entitlements.active[entitlementID]?.productIdentifier) {
                              AppFlushbar.shared.warningFlushbar(RevenueCatHelper.alreadyPurchasedMessage);
                              return;
                            }
                            if (selectedPackage != null) {
                              context.read<PaywallBloc>().add(PurchaseProductEvent(
                                    selectedPackage: selectedPackage!,
                                    isFromOnboarding: false,
                                  ));
                            }
                          },
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: Colors.deepOrangeAccent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: purchaseLoading
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      LocaleKeys.subscription_loading.tr(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "🔓",
                                      style: context.cupertinoTextStyle.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    CupertinoActivityIndicator(radius: 12),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      LocaleKeys.subscription_continue.tr(),
                                      style: context.cupertinoTextStyle.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      " 🚀",
                                      style: context.cupertinoTextStyle.copyWith(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  child: SizedBox(
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              onTap: UrlLauncherHelper.openPrivacyPolicy,
                              child: Text(
                                LocaleKeys.settings_privacy.tr(),
                                textAlign: TextAlign.center,
                                style: context.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: VerticalDivider(),
                            ),
                            _restoreButton,
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: VerticalDivider(),
                            ),
                            CustomButton(
                              onTap: UrlLauncherHelper.openTermsOfUse,
                              child: Text(
                                LocaleKeys.settings_terms.tr(),
                                textAlign: TextAlign.center,
                                style: context.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }

  Widget get _restoreButton {
    return BlocBuilder<PaywallBloc, PaywallState>(
      builder: (context, state) {
        if (state is PaywallResult) {
          final isRestoring = state.isRestoring;

          return CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: isRestoring
                ? null
                : () {
                    context.read<PaywallBloc>().add(RestorePurchasesEvent());
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.subscription_restore.tr(),
                  style: context.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isRestoring) SizedBox(width: 4),
                if (isRestoring) CupertinoActivityIndicator()
              ],
            ),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  Widget _productSection(PaywallResult state) {
    final availablePackages = state.offerings?.current?.availablePackages;

    if (availablePackages == null) return SizedBox.shrink();

    String? monthlyCalculated;

    monthlyCalculated = ((availablePackages[1].storeProduct.price / 12).toStringAsFixed(2)).toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.separated(
          separatorBuilder: (context, index) => SizedBox(height: 12),
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: availablePackages.length,
          itemBuilder: (context, index) {
            String? stringDiscount;
            if (availablePackages.isNotNullAndNotEmpty) {
              final annualMonthlyPrice = availablePackages.first.storeProduct.price * 12;
              final annualPrice = availablePackages[1].storeProduct.price;
              final discountPercent = (((annualMonthlyPrice - annualPrice) / annualMonthlyPrice) * 100).toStringAsFixed(0);

              stringDiscount = "-$discountPercent%";
            }

            final currentPackage = availablePackages[index];

            return CustomButton(
              onTap: () {
                HapticFeedback.heavyImpact();

                setState(() {
                  selectedIndex = index;
                  selectedPackage = availablePackages[selectedIndex];
                });
              },
              child: ProductWidget(
                package: currentPackage,
                isSelected: selectedIndex == index,
                monthlyCalculated: index == 1 ? monthlyCalculated : null,
                discount: index == 1 ? stringDiscount : null,
                isAnnual: index == 1,
              ),
            );
          },
        ),
      ],
    );
  }
}

class FeatureModel {
  final IconData widget;
  final String name;
  final String description;
  final Color color;

  FeatureModel(this.name, this.widget, this.description, this.color);
}
