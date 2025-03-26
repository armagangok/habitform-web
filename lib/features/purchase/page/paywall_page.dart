import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/purchase/widgets/product_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/core/core.dart' hide LocaleKeys;
import '/core/helpers/url_laucher/url_launcher.dart';
import '../../translation/constants/locale_keys.g.dart';
import '../models/paywall_state.dart';
import '../providers/purchase_provider.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({this.isFromOnboarding = false, super.key});

  final bool isFromOnboarding;

  @override
  ConsumerState<PaywallPage> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends ConsumerState<PaywallPage> with SingleTickerProviderStateMixin {
  int selectedIndex = 2;
  Package? selectedPackage;

  final List<FeatureModel> featureList = [
    FeatureModel(
      LocaleKeys.subscription_unlimitiedHabits.tr(),
      CupertinoIcons.square_grid_3x2_fill,
      LocaleKeys.subscription_unlimitiedHabitsDescription.tr(),
      Colors.blue,
    ),
    FeatureModel(
      LocaleKeys.subscription_statisticsTitle.tr(),
      FontAwesomeIcons.chartLine,
      LocaleKeys.subscription_statisticsDescription.tr(),
      Colors.deepOrangeAccent,
    ),
    FeatureModel(
      LocaleKeys.subscription_archiveSupportTitle.tr(),
      FontAwesomeIcons.boxArchive,
      LocaleKeys.subscription_archiveSupportDescription.tr(),
      Colors.deepPurpleAccent,
    ),
    FeatureModel(
      LocaleKeys.subscription_habitReminderTitle.tr(),
      FontAwesomeIcons.solidBell,
      LocaleKeys.subscription_habitReminderDescription.tr(),
      CupertinoColors.systemGreen,
    ),
    FeatureModel(
      LocaleKeys.subscription_unlimitiedCustomization.tr(),
      FontAwesomeIcons.solidPenToSquare,
      LocaleKeys.subscription_unlimitiedCustomizationDescription.tr(),
      Colors.redAccent,
    ),
    FeatureModel(
      LocaleKeys.subscription_alwaysUpToDate.tr(),
      FontAwesomeIcons.rotateRight,
      LocaleKeys.subscription_alwaysUpToDateDescription.tr(),
      Colors.cyan,
    ),
    FeatureModel(
      LocaleKeys.subscription_upcomingFeatures.tr(),
      CupertinoIcons.timelapse,
      LocaleKeys.subscription_upcomingFeaturesDescription.tr(),
      Colors.blueAccent,
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
    final purchaseState = ref.watch(purchaseProvider);

    return Material(
      child: purchaseState.when(
        data: (state) {
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

                            return Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 12,
                                ),
                                child: Row(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      color: feature.color,
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Icon(
                                          feature.widget,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            feature.name,
                                            style: context.titleMedium,
                                          ),
                                          Text(
                                            feature.description,
                                            style: context.bodySmall,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
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
        },
        loading: () => Center(child: CupertinoActivityIndicator()),
        error: (error, _) => Center(
          child: Text(LocaleKeys.errors_something_went_wrong.tr()),
        ),
      ),
    );
  }

  CupertinoNavigationBar _navBar(BuildContext context) {
    return CupertinoNavigationBar(
      automaticallyImplyLeading: false,
      leading: widget.isFromOnboarding
          ? null
          : Align(
              widthFactor: 1,
              child: SizedBox(
                height: 28,
                width: 28,
                child: CupertinoButton(
                  color: context.iconTheme.color?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(90),
                  padding: EdgeInsets.zero,
                  onPressed: navigator.pop,
                  child: FittedBox(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(360),
                      ),
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: context.iconTheme.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
      border: Border(
        bottom: BorderSide(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      transitionBetweenRoutes: false,
    );
  }

  Widget _continueButton(PaywallState state) {
    final purchaseLoading = state.isPurchasing;
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
                  onPressed: purchaseLoading || selectedPackage == null
                      ? null
                      : () async {
                          HapticFeedback.heavyImpact();
                          if (selectedPackage != null) {
                            ref.read(purchaseProvider.notifier).purchasePackage(
                                  selectedPackage!,
                                  widget.isFromOnboarding,
                                );
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
              if (widget.isFromOnboarding) ...[
                SizedBox(height: 5),
                CustomButton(
                  onPressed: () {
                    navigator.navigateAndClear(path: KRoute.homePage);
                  },
                  child: Text(
                    LocaleKeys.subscription_continueWithLimitedPlan.tr(),
                    style: context.bodySmall?.copyWith(
                      color: context.bodySmall?.color?.withValues(alpha: .7),
                    ),
                  ),
                ),
              ],
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
                            onPressed: UrlLauncherHelper.openPrivacyPolicy,
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
                            onPressed: UrlLauncherHelper.openTermsOfUse,
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
  }

  Widget get _restoreButton {
    final purchaseState = ref.watch(purchaseProvider);

    return purchaseState.when(
      data: (state) {
        final isRestoring = state.isRestoring;

        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isRestoring
              ? null
              : () {
                  ref.read(purchaseProvider.notifier).restorePurchases(widget.isFromOnboarding);
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
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }

  Widget _productSection(PaywallState state) {
    final availablePackages = state.offerings?.current?.availablePackages;

    if (availablePackages == null || availablePackages.isEmpty) {
      return SizedBox.shrink();
    }

    // String? monthlyCalculated;

    // // Ensure we have at least 2 packages before calculating
    // if (availablePackages.length > 1) {
    //   monthlyCalculated = ((availablePackages[1].storeProduct.price / 12).toStringAsFixed(2)).toString();
    // }

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

            // Calculate discount only if we have at least 2 packages
            if (availablePackages.length > 1) {
              final annualMonthlyPrice = availablePackages.first.storeProduct.price * 12;
              final annualPrice = availablePackages[1].storeProduct.price;
              final discountPercent = (((annualMonthlyPrice - annualPrice) / annualMonthlyPrice) * 100).toStringAsFixed(0);

              stringDiscount = "-$discountPercent%";
            }

            final currentPackage = availablePackages[index];

            return CustomButton(
              onPressed: () {
                HapticFeedback.mediumImpact();

                setState(() {
                  selectedIndex = index;
                  selectedPackage = availablePackages[selectedIndex];
                });
              },
              child: index == 1 && availablePackages.length > 1
                  ? ProductWidget(
                      package: currentPackage,
                      isSelected: selectedIndex == index,
                      discount: stringDiscount,
                      isPopular: true,
                    )
                  : ProductWidget(
                      package: currentPackage,
                      isSelected: selectedIndex == index,
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
