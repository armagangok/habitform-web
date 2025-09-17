import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/core/core.dart' hide LocaleKeys;
import '/core/helpers/url_laucher/url_launcher.dart';
import '../../translation/constants/locale_keys.g.dart';
import '../models/paywall_state.dart';
import '../providers/purchase_provider.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({this.isFromOnboarding = false, this.isFromSettings = false, super.key});

  final bool isFromOnboarding;
  final bool isFromSettings;

  @override
  ConsumerState<PaywallPage> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends ConsumerState<PaywallPage> with TickerProviderStateMixin {
  int selectedIndex = 1; // Default to annual plan
  Package? selectedPackage;

  // Animation controllers
  late AnimationController _heroController;
  late AnimationController _featuresController;
  late AnimationController _productsController;
  late AnimationController _buttonController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  late Animation<double> _featuresFadeAnimation;
  late Animation<Offset> _featuresSlideAnimation;
  late Animation<double> _productsFadeAnimation;
  late Animation<Offset> _productsSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  late Animation<double> _pulseAnimation;

  // Scroll controller
  late ScrollController _scrollController;

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
      Colors.blueAccent,
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
      Colors.deepOrangeAccent,
    ),
    FeatureModel(
      LocaleKeys.subscription_supportAnIndieDev.tr(),
      CupertinoIcons.heart_fill,
      LocaleKeys.subscription_supportAnIndieDevDescription.tr(),
      Colors.pinkAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController = ScrollController();
  }

  void _initializeAnimations() {
    // Hero animations
    _heroController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Features animations
    _featuresController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _featuresFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _featuresController,
      curve: Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _featuresSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _featuresController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Products animations
    _productsController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _productsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _productsController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _productsSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _productsController,
      curve: Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    // Button animations
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _buttonFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _buttonSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Floating elements animation
    _floatingController = AnimationController(
      duration: Duration(seconds: 6),
      vsync: this,
    );

    // Pulse animation for CTA
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _heroController.forward();
        Future.delayed(Duration(milliseconds: 150), () {
          if (mounted) _featuresController.forward();
        });
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) _productsController.forward();
        });
        Future.delayed(Duration(milliseconds: 450), () {
          if (mounted) _buttonController.forward();
        });
        Future.delayed(Duration(milliseconds: 600), () {
          if (mounted) {
            _floatingController.repeat(reverse: true);
            _pulseController.repeat(reverse: true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _featuresController.dispose();
    _productsController.dispose();
    _buttonController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: purchaseState.when(
        data: (state) {
          // Initialize selected package to align with selectedIndex and available packages
          final availablePackages = state.offerings?.current?.availablePackages;
          if (selectedPackage == null && availablePackages != null && availablePackages.isNotEmpty) {
            int defaultIndex = 0;
            // Prefer an annual/yearly package if present
            for (int i = 0; i < availablePackages.length; i++) {
              final identifier = availablePackages[i].storeProduct.identifier.toLowerCase();
              if (identifier.contains('year') || identifier.contains('annual') || identifier.contains('yearly')) {
                defaultIndex = i;
                break;
              }
            }
            // If widget's default is annual (index 1) and it exists, use it, else fall back to detected index
            if (selectedIndex >= 0 && selectedIndex < availablePackages.length) {
              defaultIndex = selectedIndex;
            }
            selectedIndex = defaultIndex.clamp(0, availablePackages.length - 1);
            selectedPackage = availablePackages[selectedIndex];
          }

          return CupertinoPageScaffold(
            backgroundColor: isDarkMode ? Color(0xFF0A0A0A) : Color(0xFFFAFAFA),
            navigationBar: _navBar(context),
            child: Stack(
              children: [
                // Main content
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        // Product section
                        _buildProductSection(state),

                        SizedBox(height: 20),

                        // Features section
                        _buildFeaturesSection(),

                        SizedBox(height: 120), // Space for fixed button
                      ],
                    ),
                  ),
                ),

                // Fixed CTA button
                _buildFixedCTAButton(state),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, _) => _buildErrorState(),
      ),
    );
  }

  Widget _buildProductSection(PaywallState state) {
    return AnimatedBuilder(
      animation: _productsController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _productsFadeAnimation,
          child: SlideTransition(
            position: _productsSlideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    'We become\nwhat we repeatedly do.',
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Choose Your Plan',
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.headlineMedium.color?.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 10),
                _productSection(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection() {
    return AnimatedBuilder(
      animation: _featuresController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _featuresFadeAnimation,
          child: SlideTransition(
            position: _featuresSlideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What You Get',
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.headlineMedium.color?.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 16),
                ListView.separated(
                  physics: ClampingScrollPhysics(),
                  itemCount: featureList.length,
                  shrinkWrap: true,
                  separatorBuilder: (_, __) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final feature = featureList[index];

                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 500),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - value) * 20),
                          child: Opacity(
                            opacity: value,
                            child: _buildFeatureItem(feature, index),
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(FeatureModel feature, int index) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: feature.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: feature.color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.widget,
              color: feature.color,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.name,
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  feature.description,
                  style: context.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.checkmark_circle_fill,
            color: feature.color,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildFixedCTAButton(PaywallState state) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedBuilder(
          animation: _buttonController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _buttonFadeAnimation,
              child: SlideTransition(
                position: _buttonSlideAnimation,
                child: CustomBlurWidget(
                  blurValue: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: context.theme.primaryContrastingColor,
                          width: 0.5,
                        ),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.scaffoldBackgroundColor.withValues(alpha: 0.1),
                          context.scaffoldBackgroundColor.withValues(alpha: 0.2),
                          context.scaffoldBackgroundColor.withValues(alpha: 0.3),
                        ],
                        stops: [
                          0.0,
                          0.3,
                          1.0,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMainCTAButton(state),
                            SizedBox(height: 16),
                            _buildSecondaryButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainCTAButton(PaywallState state) {
    final purchaseLoading = state.isPurchasing;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              padding: EdgeInsets.zero,
              onPressed: purchaseLoading || selectedPackage == null
                  ? null
                  : () async {
                      HapticFeedback.heavyImpact();
                      if (selectedPackage != null) {
                        ref.read(purchaseProvider.notifier).purchasePackage(
                              selectedPackage!,
                              widget.isFromOnboarding,
                              isFromSettings: widget.isFromSettings,
                            );
                      }
                    },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: purchaseLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoActivityIndicator(radius: 12),
                          SizedBox(width: 12),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getCTAButtonText(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondaryButtons() {
    return Column(
      children: [
        if (widget.isFromOnboarding) ...[
          CustomButton(
            onPressed: () {
              navigator.navigateAndClear(path: KRoute.homePage);
            },
            child: Text(
              'Continue with limited features',
              style: context.bodySmall.copyWith(
                color: context.bodySmall.color?.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 12)
        ],
        Row(
          spacing: 14,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: _restoreButton),
            Expanded(
              child: CupertinoButton(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                onPressed: UrlLauncherHelper.openPrivacyPolicy,
                child: Text(
                  'Privacy',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: CupertinoButton(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                onPressed: UrlLauncherHelper.openTermsOfUse,
                child: Text(
                  'Terms',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 20),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: context.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  CupertinoNavigationBar _navBar(BuildContext context) {
    return CupertinoNavigationBar(
      automaticallyImplyLeading: false,
      leading: widget.isFromOnboarding
          ? null
          : CircularActionButton(
              onPressed: () {
                navigator.pop();
              },
              icon: CupertinoIcons.xmark,
            ),
      middle: Text(
        'HabitRise Pro',
        style: context.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
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

  String _getCTAButtonText() {
    if (selectedPackage == null) return 'Continue';

    // Check if the package has an introductory offer (free trial)
    final hasIntroductoryOffer = selectedPackage!.storeProduct.introductoryPrice != null;

    if (hasIntroductoryOffer) {
      return 'Try for Free';
    }

    // No introductory offer available
    return 'Continue';
  }

  String? _getTrialDaysText(Package package) {
    final introductoryPrice = package.storeProduct.introductoryPrice;
    if (introductoryPrice == null) return null;

    // Parse ISO 8601 duration format (e.g., "P3D" = 3 days, "P1W" = 1 week)
    final period = introductoryPrice.period;
    final days = _parseISODurationToDays(period);

    if (days == null || days <= 0) return null;

    return '$days-day free trial included';
  }

  int? _parseISODurationToDays(String isoDuration) {
    // Parse ISO 8601 duration format
    // Examples: "P3D" = 3 days, "P1W" = 7 days, "P1M" = 30 days, "P1Y" = 365 days

    if (!isoDuration.startsWith('P')) return null;

    final duration = isoDuration.substring(1); // Remove 'P' prefix

    // Check for days
    if (duration.endsWith('D')) {
      final daysStr = duration.substring(0, duration.length - 1);
      return int.tryParse(daysStr);
    }

    // Check for weeks
    if (duration.endsWith('W')) {
      final weeksStr = duration.substring(0, duration.length - 1);
      final weeks = int.tryParse(weeksStr);
      return weeks != null ? weeks * 7 : null;
    }

    // Check for months
    if (duration.endsWith('M')) {
      final monthsStr = duration.substring(0, duration.length - 1);
      final months = int.tryParse(monthsStr);
      return months != null ? months * 30 : null; // Approximate
    }

    // Check for years
    if (duration.endsWith('Y')) {
      final yearsStr = duration.substring(0, duration.length - 1);
      final years = int.tryParse(yearsStr);
      return years != null ? years * 365 : null; // Approximate
    }

    return null;
  }

  Widget get _restoreButton {
    final purchaseState = ref.watch(purchaseProvider);

    return purchaseState.when(
      data: (state) {
        final isRestoring = state.isRestoring;

        return CupertinoButton(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          onPressed: isRestoring
              ? null
              : () {
                  ref.read(purchaseProvider.notifier).restorePurchases(widget.isFromOnboarding, isFromSettings: widget.isFromSettings);
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Restore',
                style: context.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRestoring) SizedBox(width: 4),
              if (isRestoring) CupertinoActivityIndicator(radius: 8)
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

    return Column(
      children: availablePackages.asMap().entries.map((entry) {
        final index = entry.key;
        final package = entry.value;
        final isSelected = selectedIndex == index;
        final isPopular = index == 1 && availablePackages.length > 1;

        // Calculate discount
        String? discount;
        if (availablePackages.length > 1 && index == 1) {
          final monthlyPrice = availablePackages.first.storeProduct.price * 12;
          final annualPrice = availablePackages[1].storeProduct.price;
          final discountPercent = (((monthlyPrice - annualPrice) / monthlyPrice) * 100).toStringAsFixed(0);
          discount = "-$discountPercent%";
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: CustomButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              setState(() {
                selectedIndex = index;
                selectedPackage = package;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: context.selectionHandleColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? context.primary : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Selection indicator
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? context.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? context.primary : Theme.of(context).dividerColor,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                CupertinoIcons.checkmark,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      SizedBox(width: 16),

                      // Package info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  package.storeProduct.title.getTitleName.toUpperCase(),
                                  style: context.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? context.primary : null,
                                  ),
                                ),
                                if (isPopular) ...[
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: context.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'POPULAR!',
                                      style: context.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4),

                            if (package.storeProduct.description.isNotEmpty) ...[
                              Text(
                                package.storeProduct.description,
                                style: context.bodySmall.copyWith(
                                  color: context.bodySmall.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                            // Trial information
                            if (_getTrialDaysText(package) != null) ...[
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    CupertinoIcons.gift_fill,
                                    color: context.primary,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    _getTrialDaysText(package)!,
                                    style: context.bodySmall.copyWith(
                                      color: context.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Price and discount
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            package.storeProduct.priceString,
                            style: context.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? context.primary : null,
                            ),
                          ),
                          if (discount != null) ...[
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.tag_solid,
                                  color: CupertinoColors.systemGreen,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGreen,
                                    borderRadius: BorderRadius.circular(90),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        discount,
                                        style: context.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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

extension _EasyTitleName on String {
  String get getTitleName {
    // Remove everything inside parentheses (including nested parentheses)
    String cleanedText = replaceAll(RegExp('\\(.*?\\)'), '');

    // Remove any remaining double quotes and trim whitespace
    cleanedText = cleanedText.replaceAll(')', '').trim();
    cleanedText = cleanedText.replaceAll(' ', '').trim();

    return cleanedText;
  }
}
