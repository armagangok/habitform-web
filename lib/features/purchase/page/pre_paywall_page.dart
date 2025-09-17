import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart' hide LocaleKeys;
import '../../translation/constants/locale_keys.g.dart';
import '../providers/purchase_provider.dart';
import 'paywall_page.dart';

class PrePaywallPage extends ConsumerStatefulWidget {
  const PrePaywallPage({this.isFromOnboarding = false, this.isFromSettings = false, super.key});

  final bool isFromOnboarding;
  final bool isFromSettings;

  @override
  ConsumerState<PrePaywallPage> createState() => _PrePaywallPageState();
}

class _PrePaywallPageState extends ConsumerState<PrePaywallPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _heroController;
  late AnimationController _testimonialsController;
  late AnimationController _featuresController;
  late AnimationController _pricingController;
  late AnimationController _floatingController;

  // Animations
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _testimonialsFadeAnimation;
  late Animation<Offset> _testimonialsSlideAnimation;
  late Animation<double> _featuresFadeAnimation;
  late Animation<Offset> _featuresSlideAnimation;

  late Animation<double> _floatingAnimation;

  // Scroll controller
  late ScrollController _scrollController;

  final List<TestimonialModel> testimonials = [
    TestimonialModel(
      "Sarah M.",
      "⭐⭐⭐⭐⭐",
      "HabitRise Pro completely transformed my daily routine. I've built 5 new habits in just 2 months!",
      "HabitRise Pro User",
    ),
    TestimonialModel(
      "Mike C.",
      "⭐⭐⭐⭐⭐",
      "The statistics and insights are incredible. I can see exactly how I'm progressing every day.",
      "HabitRise Pro User",
    ),
    TestimonialModel(
      "Emma J.",
      "⭐⭐⭐⭐⭐",
      "Finally, an app that actually helps me stick to my goals. The reminders are perfectly timed.",
      "HabitRise Pro User",
    ),
  ];

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

    _heroFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _heroSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _heroScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    // Testimonials animations
    _testimonialsController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _testimonialsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _testimonialsController,
      curve: Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _testimonialsSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _testimonialsController,
      curve: Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

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

    // Pricing animations
    _pricingController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Floating elements animation
    _floatingController = AnimationController(
      duration: Duration(seconds: 6),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        _heroController.forward();
        Future.delayed(Duration(milliseconds: 200), () {
          if (mounted) _testimonialsController.forward();
        });
        Future.delayed(Duration(milliseconds: 400), () {
          if (mounted) _featuresController.forward();
        });
        Future.delayed(Duration(milliseconds: 600), () {
          if (mounted) _pricingController.forward();
        });
        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted) _floatingController.repeat(reverse: true);
        });
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _testimonialsController.dispose();
    _featuresController.dispose();
    _pricingController.dispose();
    _floatingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSocialProofSection() {
    return AnimatedBuilder(
      animation: _featuresController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _featuresFadeAnimation,
          child: SlideTransition(
            position: _featuresSlideAnimation,
            child: CupertinoListSection.insetGrouped(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '50K+',
                              style: context.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.primary,
                              ),
                            ),
                            Text(
                              'Active Users',
                              style: context.bodySmall.copyWith(
                                color: context.bodySmall.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '4.9★',
                              style: context.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.primary,
                              ),
                            ),
                            Text(
                              'App Store Rating',
                              style: context.bodySmall.copyWith(
                                color: context.bodySmall.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '98%',
                              style: context.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.primary,
                              ),
                            ),
                            Text(
                              'Success Rate',
                              style: context.bodySmall.copyWith(
                                color: context.bodySmall.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // Prevent dismissal by back button or swipe
      child: Material(
        color: Colors.transparent,
        child: purchaseState.when(
          data: (state) {
            return CupertinoPageScaffold(
              navigationBar: _navBar(context),
              child: Stack(
                children: [
                  // Professional background
                  _buildProfessionalBackground(isDarkMode),

                  // Floating elements
                  _buildFloatingElements(),

                  // Main content
                  SizedBox(
                    width: double.infinity,
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        SizedBox(height: 10),

                        // Hero section
                        _buildHeroSection(),

                        _buildSocialProofSection(),

                        // Testimonials section
                        _buildTestimonialsSection(),

                        // Features section
                        _buildFeaturesSection(),

                        SizedBox(height: 40),

                        SizedBox(height: 120), // Space for fixed button
                      ],
                    ),
                  ),

                  // Fixed continue button
                  _buildFixedContinueButton(),
                ],
              ),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, _) => _buildErrorState(),
        ),
      ),
    );
  }

  Widget _buildProfessionalBackground(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Color(0xFF0A0A0A),
                      Color(0xFF1A1A1A),
                      Color(0xFF0A0A0A),
                    ]
                  : [
                      Color(0xFFFAFAFA),
                      Color(0xFFF5F5F5),
                      Color(0xFFFAFAFA),
                    ],
            ),
          ),
          child: CustomPaint(
            painter: _ProfessionalBackgroundPainter(
              animation: _floatingAnimation,
              isDarkMode: isDarkMode,
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
            // Subtle floating elements
            Positioned(
              top: 100 + sin(_floatingAnimation.value * 2 * math.pi) * 15,
              right: 30 + cos(_floatingAnimation.value * 2 * math.pi) * 10,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              top: 200 + cos(_floatingAnimation.value * 2 * math.pi) * 20,
              left: 20 + sin(_floatingAnimation.value * 2 * math.pi) * 15,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(alpha: 0.04),
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
              child: CupertinoListSection.insetGrouped(
                children: [
                  // App icon and title
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          FittedBox(
                            child: Text(
                              'We become\nwhat we repeatedly do.',
                              style: context.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 21,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestimonialsSection() {
    return AnimatedBuilder(
      animation: _testimonialsController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _testimonialsFadeAnimation,
          child: SlideTransition(
            position: _testimonialsSlideAnimation,
            child: CupertinoListSection.insetGrouped(
              header: Text('What Our Users Are Saying'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    physics: ClampingScrollPhysics(),
                    itemCount: testimonials.length,
                    shrinkWrap: true,
                    separatorBuilder: (_, __) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final testimonial = testimonials[index];

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 500),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, (1 - value) * 20),
                            child: Opacity(
                              opacity: value,
                              child: _buildTestimonialCard(testimonial),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTestimonialCard(TestimonialModel testimonial) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: context.primaryContrastingColor.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                testimonial.stars,
                style: TextStyle(fontSize: 16),
              ),
              Spacer(),
              Text(
                testimonial.userType,
                style: context.bodySmall.copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            testimonial.comment,
            style: context.bodyMedium.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Text(
            testimonial.userName,
            style: context.bodySmall.copyWith(
              color: context.bodySmall.color?.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
            child: CupertinoListSection.insetGrouped(
              header: Text('What You Get'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
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

  Widget _buildFixedContinueButton() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.0),
                Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
                Theme.of(context).scaffoldBackgroundColor,
              ],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.primary,
                      context.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
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
                  onPressed: () {
                    HapticFeedback.heavyImpact();

                    showCupertinoSheet(
                      enableDrag: false,
                      context: context,
                      builder: (context) => PaywallPage(
                        isFromOnboarding: widget.isFromOnboarding,
                        isFromSettings: widget.isFromSettings,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          CupertinoIcons.arrow_right_circle_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
}

class TestimonialModel {
  final String userName;
  final String stars;
  final String comment;
  final String userType;

  TestimonialModel(this.userName, this.stars, this.comment, this.userType);
}

class FeatureModel {
  final IconData widget;
  final String name;
  final String description;
  final Color color;

  FeatureModel(this.name, this.widget, this.description, this.color);
}

class _ProfessionalBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;

  _ProfessionalBackgroundPainter({
    required this.animation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.02)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);

    // Draw subtle geometric shapes
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.3;

    // Main circle
    final mainRadius = 60 + sin(animation.value * 2 * math.pi) * 10;
    canvas.drawCircle(
      Offset(centerX, centerY),
      mainRadius,
      paint,
    );

    // Secondary circles
    final secondaryRadius = 30 + cos(animation.value * 2 * math.pi + math.pi) * 8;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.6),
      secondaryRadius,
      paint,
    );

    final tertiaryRadius = 25 + sin(animation.value * 2 * math.pi + math.pi / 2) * 6;
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      tertiaryRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _ProfessionalBackgroundPainter || oldDelegate.animation != animation || oldDelegate.isDarkMode != isDarkMode;
  }
}
