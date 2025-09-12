import 'dart:math' as math;
import 'dart:math';

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

class _PaywallWidgetState extends ConsumerState<PaywallPage> with TickerProviderStateMixin {
  int selectedIndex = 2;
  Package? selectedPackage;

  // Animation controllers
  late AnimationController _heroController;
  late AnimationController _featuresController;
  late AnimationController _productsController;
  late AnimationController _buttonController;
  late AnimationController _floatingController;
  late AnimationController _parallaxController;

  // Animations
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _featuresFadeAnimation;
  late Animation<Offset> _featuresSlideAnimation;
  late Animation<double> _productsFadeAnimation;
  late Animation<Offset> _productsSlideAnimation;
  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _parallaxAnimation;

  // Scroll controller for parallax
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
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    // Hero animations
    _heroController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _heroSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _heroScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    // Features animations
    _featuresController = AnimationController(
      duration: Duration(milliseconds: 1000),
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
      begin: Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _featuresController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Products animations
    _productsController = AnimationController(
      duration: Duration(milliseconds: 800),
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
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _productsController,
      curve: Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ));

    // Button animations
    _buttonController = AnimationController(
      duration: Duration(milliseconds: 600),
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
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Floating elements animation
    _floatingController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Parallax animation
    _parallaxController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _heroController.forward();
        Future.delayed(Duration(milliseconds: 200), () {
          if (mounted) _featuresController.forward();
        });
        Future.delayed(Duration(milliseconds: 400), () {
          if (mounted) _productsController.forward();
        });
        Future.delayed(Duration(milliseconds: 600), () {
          if (mounted) _buttonController.forward();
        });
        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted) _floatingController.repeat(reverse: true);
        });
        // Animation initialization complete
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final progress = (offset / maxScroll).clamp(0.0, 1.0);
      _parallaxController.value = progress;
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _featuresController.dispose();
    _productsController.dispose();
    _buttonController.dispose();
    _floatingController.dispose();
    _parallaxController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
                // Animated background
                _buildAnimatedBackground(),

                // Floating elements
                _buildFloatingElements(),

                // Main content
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        SizedBox(height: 20),

                        // Hero section with animated title
                        _buildHeroSection(),

                        SizedBox(height: 30),

                        // Product section with animations
                        _buildAnimatedProductSection(state),

                        SizedBox(height: 40),

                        // Features section with staggered animations
                        _buildAnimatedFeaturesSection(),

                        SizedBox(height: 160),
                      ],
                    ),
                  ),
                ),

                // Animated continue button
                _buildAnimatedContinueButton(state),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, _) => _buildErrorState(),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _parallaxAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.primary.withValues(alpha: 0.05),
                context.primary.withValues(alpha: 0.1),
                context.primary.withValues(alpha: 0.05),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _BackgroundPainter(
              animation: _parallaxAnimation,
              floatingAnimation: _floatingAnimation,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating circles
            Positioned(
              top: 100 + sin(_floatingAnimation.value * 2 * math.pi) * 20,
              right: 30 + cos(_floatingAnimation.value * 2 * math.pi) * 15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              top: 200 + cos(_floatingAnimation.value * 2 * math.pi) * 25,
              left: 20 + sin(_floatingAnimation.value * 2 * math.pi) * 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              top: 300 + sin(_floatingAnimation.value * 2 * math.pi + math.pi) * 15,
              right: 50 + cos(_floatingAnimation.value * 2 * math.pi + math.pi) * 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _heroFadeAnimation,
          child: SlideTransition(
            position: _heroSlideAnimation,
            child: ScaleTransition(
              scale: _heroScaleAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.primary.withValues(alpha: 0.1),
                      context.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🚀',
                          style: TextStyle(fontSize: 32),
                        ),
                        SizedBox(width: 12),
                        RichText(
                          text: TextSpan(
                            text: 'Unlock ',
                            style: context.titleLarge.copyWith(fontWeight: FontWeight.w600, color: context.bodyLarge.color),
                            children: [
                              TextSpan(
                                text: 'HabitRise Pro',
                                style: context.titleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      LocaleKeys.subscription_whatYouWillUnlock.tr(),
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildAnimatedProductSection(PaywallState state) {
    return AnimatedBuilder(
      animation: _productsController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _productsFadeAnimation,
          child: SlideTransition(
            position: _productsSlideAnimation,
            child: _productSection(state),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedFeaturesSection() {
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

                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, (1 - value) * 30),
                          child: Opacity(
                            opacity: value,
                            child: _buildFeatureItem(feature, index),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(FeatureModel feature, int index) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: feature.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: feature.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedContinueButton(PaywallState state) {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _buttonFadeAnimation,
          child: SlideTransition(
            position: _buttonSlideAnimation,
            child: _continueButton(state),
          ),
        );
      },
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
            LocaleKeys.subscription_loading.tr(),
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
            LocaleKeys.errors_something_went_wrong.tr(),
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
          : Align(
              widthFactor: 1,
              child: SizedBox(
                height: 28,
                width: 28,
                child: CupertinoButton(
                  color: context.iconTheme.color?.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(90),
                  padding: EdgeInsets.zero,
                  onPressed: navigator.pop,
                  child: FittedBox(
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
                        color: Colors.blueAccent,
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
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: purchaseLoading || selectedPackage == null
                        ? LinearGradient(
                            colors: [
                              Colors.grey.withValues(alpha: 0.3),
                              Colors.grey.withValues(alpha: 0.2),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              context.primary,
                              context.primary.withValues(alpha: 0.8),
                            ],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: context.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
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
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
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
                                  SizedBox(width: 8),
                                  TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 1000),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.rotate(
                                        angle: value * 2 * math.pi,
                                        child: Text(
                                          "🔓",
                                          style: context.cupertinoTextStyle.copyWith(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                    onEnd: () {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                  SizedBox(width: 8),
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
                                  TweenAnimationBuilder<double>(
                                    duration: Duration(milliseconds: 2000),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, sin(value * 2 * math.pi) * 2),
                                        child: Text(
                                          " 🚀",
                                          style: context.cupertinoTextStyle.copyWith(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                    onEnd: () {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.isFromOnboarding) ...[
                SizedBox(height: 8),
                CustomButton(
                  onPressed: () {
                    navigator.navigateAndClear(path: KRoute.homePage);
                  },
                  child: Text(
                    LocaleKeys.subscription_continueWithLimitedPlan.tr(),
                    style: context.bodySmall.copyWith(
                      color: context.bodySmall.color?.withValues(alpha: .7),
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
                              style: context.bodySmall.copyWith(
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
                              style: context.bodySmall.copyWith(
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
                style: context.bodySmall.copyWith(
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

class _BackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Animation<double> floatingAnimation;

  _BackgroundPainter({
    required this.animation,
    required this.floatingAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw animated circles
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.3;

    // Main floating circle
    final mainCircleRadius = 80 + sin(floatingAnimation.value * 2 * math.pi) * 20;
    canvas.drawCircle(
      Offset(centerX + cos(floatingAnimation.value * 2 * math.pi) * 30, centerY),
      mainCircleRadius,
      Paint()
        ..color = Colors.blueAccent.withValues(alpha: 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Secondary circles
    final secondaryRadius = 40 + cos(floatingAnimation.value * 2 * math.pi + math.pi) * 15;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.6),
      secondaryRadius,
      Paint()
        ..color = Colors.deepPurpleAccent.withValues(alpha: 0.06)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15),
    );

    final tertiaryRadius = 30 + sin(floatingAnimation.value * 2 * math.pi + math.pi / 2) * 10;
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      tertiaryRadius,
      Paint()
        ..color = Colors.cyan.withValues(alpha: 0.05)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Draw animated lines
    final linePaint = Paint()
      ..color = Colors.blueAccent.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    for (int i = 0; i < 5; i++) {
      final x = (size.width / 4) * i;
      final y = size.height * 0.2 + sin(floatingAnimation.value * 2 * math.pi + i) * 20;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _BackgroundPainter || oldDelegate.animation != animation || oldDelegate.floatingAnimation != floatingAnimation;
  }
}
