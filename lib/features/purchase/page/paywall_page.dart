import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/purchase/widgets/product_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/core/core.dart' hide LocaleKeys;
import '/core/helpers/url_laucher/url_launcher.dart';
import '../../translation/constants/locale_keys.g.dart';
import '../models/paywall_state.dart';
import '../providers/purchase_provider.dart';

class PaywallPage extends ConsumerStatefulWidget {
  final bool isFromOnboarding;

  const PaywallPage({
    super.key,
    this.isFromOnboarding = false,
  });

  @override
  ConsumerState<PaywallPage> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends ConsumerState<PaywallPage> with SingleTickerProviderStateMixin {
  Package? selectedPackage;

  final List<FeatureModel> featureList = [
    FeatureModel(
      LocaleKeys.subscription_archiveSupportTitle.tr(),
      FontAwesomeIcons.boxArchive,
      LocaleKeys.subscription_archiveSupportDescription.tr(),
    ),
    FeatureModel(
      LocaleKeys.subscription_habitReminderTitle.tr(),
      FontAwesomeIcons.solidBell,
      LocaleKeys.subscription_habitReminderDescription.tr(),
    ),
    FeatureModel(
      LocaleKeys.subscription_unlimitiedHabits.tr(),
      CupertinoIcons.square_grid_3x2_fill,
      LocaleKeys.subscription_unlimitiedHabitsDescription.tr(),
    ),
    FeatureModel(
      LocaleKeys.subscription_unlimitiedCustomization.tr(),
      FontAwesomeIcons.solidPenToSquare,
      LocaleKeys.subscription_unlimitiedCustomizationDescription.tr(),
    ),
    FeatureModel(
      LocaleKeys.subscription_alwaysUpToDate.tr(),
      FontAwesomeIcons.rotateRight,
      LocaleKeys.subscription_alwaysUpToDateDescription.tr(),
    ),
    FeatureModel(
      LocaleKeys.subscription_upcomingFeatures.tr(),
      FontAwesomeIcons.clock,
      LocaleKeys.subscription_upcomingFeaturesDescription.tr(),
    ),
    FeatureModel(
      LocaleKeys.subscription_noBoringAds.tr(),
      FontAwesomeIcons.solidBellSlash,
      LocaleKeys.subscription_noBoringAdsDescription.tr(),
    ),
    FeatureModel(
      LocaleKeys.subscription_supportAnIndieDev.tr(),
      CupertinoIcons.heart_fill,
      LocaleKeys.subscription_supportAnIndieDevDescription.tr(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final paywallState = ref.watch(purchaseProvider);

    return Material(
      color: Colors.transparent,
      child: paywallState.when(
        data: (state) {
          // Sadece aylık paketi seç
          selectedPackage = state.offerings?.current?.monthly;

          return CupertinoPageScaffold(
            navigationBar: _navBar(context),
            child: Stack(
              children: [
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ListView(
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            LocaleKeys.subscription_whatYouWillUnlock.tr(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 20),
                          ListView.separated(
                            physics: const ClampingScrollPhysics(),
                            itemCount: featureList.length,
                            shrinkWrap: true,
                            separatorBuilder: (_, __) => const SizedBox(height: 25),
                            itemBuilder: (context, index) {
                              final FeatureModel feature = featureList[index];

                              return CupertinoListTile(
                                padding: EdgeInsets.zero,
                                leadingSize: 44,
                                leading: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Icon(
                                      feature.widget,
                                      size: 20,
                                      color: context.primary.withValues(alpha: .85),
                                    ),
                                  ),
                                ),
                                title: Text(feature.name),
                                subtitle: Text(
                                  feature.description,
                                  maxLines: 3,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 250),
                        ],
                      ),
                    ),
                  ),
                ),
                _monthlyButton(state),
              ],
            ),
          );
        },
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Abonelik bilgileri yüklenirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.\nHata: $error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  ObstructingPreferredSizeWidget _navBar(BuildContext context) {
    return SheetHeader(
      leading: widget.isFromOnboarding ? SizedBox() : null,
      trailing: widget.isFromOnboarding ? SizedBox() : null,
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

  Widget _monthlyButton(PaywallState state) {
    final monthlyPackage = state.offerings?.current?.monthly;

    if (monthlyPackage == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: CustomBlurWidget(
        blurValue: 20,
        child: ColoredBox(
          color: Colors.white.withValues(alpha: .025),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      ProductWidget(
                        package: monthlyPackage,
                        discount: "-50%",
                        onTap: () {
                          final notifier = ref.read(purchaseProvider.notifier);
                          notifier.purchasePackage(
                            monthlyPackage,
                            isFromOnboarding: widget.isFromOnboarding,
                          );
                        },
                      ),
                      if (widget.isFromOnboarding)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: CustomButton(
                            onPressed: () {
                              navigator.navigateAndClear(path: KRoute.homePage);
                            },
                            child: Text(
                              LocaleKeys.subscription_continueWithLimitedPlan.tr(),
                              style: context.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  child: SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                              child: const VerticalDivider(),
                            ),
                            _restoreButton,
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: const VerticalDivider(),
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
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _restoreButton {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(purchaseProvider);

        return state.when(
          data: (state) {
            final isRestoring = state.isRestoring;

            return CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: isRestoring
                  ? null
                  : () {
                      final notifier = ref.read(purchaseProvider.notifier);
                      notifier.restorePurchases(
                        isFromOnboarding: widget.isFromOnboarding,
                      );
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
                  if (isRestoring) const SizedBox(width: 4),
                  if (isRestoring) const CupertinoActivityIndicator()
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }
}

class FeatureModel {
  final IconData widget;
  final String name;
  final String description;

  FeatureModel(this.name, this.widget, this.description);
}
