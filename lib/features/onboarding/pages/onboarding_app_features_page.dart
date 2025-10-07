import 'dart:math';
import 'dart:ui' as ui;

import '../../../core/core.dart';

/// Onboarding - App Features page
///
/// This page showcases how HabitForm will help users build habits,
/// including sub-habits functionality and habit formation rate visualization.
class OnboardingAppFeaturesPage extends StatefulWidget {
  const OnboardingAppFeaturesPage({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  State<OnboardingAppFeaturesPage> createState() => _OnboardingAppFeaturesPageState();
}

class _OnboardingAppFeaturesPageState extends State<OnboardingAppFeaturesPage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _scaleController;
  late final AnimationController _progressController;
  late final AnimationController _pulseController;
  late final AnimationController _habitFormationController;
  late final AnimationController _introTransitionController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  late final Animation<double> _pulseAnimation;

  late final Animation<double> _introTransitionAnimation;

  int _currentFeature = 0;
  bool _isTransitioning = false;

  bool _showIntro = true;

  List<AppFeature> get _appFeatures => [
        AppFeature(
          title: "Habit Probability",
          description: "See exactly how likely you are to succeed with each habit. Get personalized insights that help you stay motivated and build lasting habits.",
          icon: CupertinoIcons.chart_bar_square,
          color: const Color(0xFF9B59B6),
          subFeatures: [
            "Know Your Success Rate",
            "Stay Motivated Daily",
            "Build Confidence",
          ],
        ),
        AppFeature(
          title: "Home Widget",
          description: "Track your habits without opening the app. Complete your daily goals directly from your phone home screen in seconds.",
          icon: CupertinoIcons.square_grid_2x2_fill,
          color: const Color(0xFF2ECC71),
          subFeatures: [
            "Instant Access",
            "Save Time Daily",
            "Never Forget Again",
          ],
        ),
        AppFeature(
          title: "Goal Setting",
          description: "Break down big dreams into achievable daily actions. Set meaningful goals that actually work and keep you moving forward.",
          icon: CupertinoIcons.checkmark_circle_fill,
          color: const Color(0xFF0C6CF2),
          subFeatures: [
            "Clear Daily Actions",
            "Achieve Big Dreams",
            "Stay Focused",
          ],
        ),
        AppFeature(
          title: "Customizable",
          description: "Make HabitForm truly yours. Choose colors, themes, and layouts that match your personality and keep you engaged.",
          icon: CupertinoIcons.paintbrush_fill,
          color: const Color(0xFFE67E22),
          subFeatures: [
            "Personal Themes",
            "Your Style",
            "Better Experience",
          ],
        ),
        AppFeature(
          title: "Habit Archive",
          description: "Keep your progress history safe and organized. View past achievements and restart habits whenever you're ready.",
          icon: CupertinoIcons.archivebox_fill,
          color: const Color(0xFF34495E),
          subFeatures: [
            "Never Lose Progress",
            "Track Your Journey",
            "Restart Anytime",
          ],
        ),
        AppFeature(
          title: "Share Habits",
          description: "Celebrate your wins with friends and family. Share beautiful progress visuals that inspire others and keep you accountable.",
          icon: CupertinoIcons.share,
          color: Colors.deepOrangeAccent,
          subFeatures: [
            "Inspire Others",
            "Stay Accountable",
            "Celebrate Wins",
          ],
        ),
      ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialAnimation();
    _startIntroTimer();
  }

  void _startIntroTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _introTransitionController.forward().then((_) {
          if (mounted) {
            setState(() {
              _showIntro = false;
            });
          }
        });
      }
    });
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _habitFormationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _introTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _introTransitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introTransitionController, curve: Curves.easeOutCubic),
    );
  }

  void _startInitialAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _progressController.forward();
    _habitFormationController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _habitFormationController.dispose();
    _introTransitionController.dispose();
    super.dispose();
  }

  void _nextFeature() async {
    if (_isTransitioning || _currentFeature >= _appFeatures.length - 1) return;

    setState(() {
      _isTransitioning = true;
    });

    // Animate out current content
    await _fadeController.reverse();
    await _slideController.reverse();

    // Move to next feature
    setState(() {
      _currentFeature++;
    });

    // Reset and animate in new content
    _fadeController.reset();
    _slideController.reset();
    _progressController.reset();

    await Future.delayed(const Duration(milliseconds: 100));

    _fadeController.forward();
    _slideController.forward();
    _progressController.forward();

    setState(() {
      _isTransitioning = false;
    });
  }

  void _previousFeature() async {
    if (_isTransitioning || _currentFeature <= 0) return;

    setState(() {
      _isTransitioning = true;
    });

    // Animate out current content
    await _fadeController.reverse();
    await _slideController.reverse();

    // Move to previous feature
    setState(() {
      _currentFeature--;
    });

    // Reset and animate in new content
    _fadeController.reset();
    _slideController.reset();
    _progressController.reset();

    await Future.delayed(const Duration(milliseconds: 100));

    _fadeController.forward();
    _slideController.forward();
    _progressController.forward();

    setState(() {
      _isTransitioning = false;
    });
  }

  void _completeOnboarding() {
    // Navigate to rating page instead of completing onboarding
    if (mounted) {
      Navigator.of(context).pushNamed('/onboardingRating');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_showIntro) {
      return _buildIntroScreen(context, theme);
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Floating particles animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    progress: _fadeController.value,
                    color: _appFeatures[_currentFeature].color,
                  ),
                );
              },
            ),
          ),
          // Top blur overlay to prevent glow bleeding under header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: context.height(0.13),
            child: IgnorePointer(
              child: ClipRRect(
                // Subtle rounding so it blends with design
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.width(0.04)),
                  bottomRight: Radius.circular(context.width(0.04)),
                ),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.18),
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: context.symmetricPadding(horizontal: 0.06),
              child: Column(
                children: [
                  // Header with progress
                  SizedBox(height: context.height(0.0125)),
                  _buildHeader(context, theme),
                  SizedBox(height: context.height(0.03)),
                  // Main content area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: context.height(0.02)),
                      child: Column(
                        children: [
                          _buildMainContent(context, theme),
                        ],
                      ),
                    ),
                  ),
                  // Navigation buttons
                  _buildNavigationButtons(context, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroScreen(BuildContext context, ThemeData theme) {
    final String logoAsset = Assets.app.appLogoDark.path;
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withValues(alpha: 0.1),
                  theme.colorScheme.surface,
                ],
              ),
            ),
          ),
          // Floating particles
          Positioned.fill(
            child: CustomPaint(
              painter: _IntroParticlePainter(),
            ),
          ),
          // Main content
          AnimatedBuilder(
            animation: _introTransitionAnimation,
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Opacity(
                  opacity: 1.0 - _introTransitionAnimation.value,
                  child: Transform.scale(
                    scale: 1.0 - (_introTransitionAnimation.value * 0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated logo with enhanced effects
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  padding: EdgeInsets.all(context.width(0.04)),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        theme.colorScheme.primary.withValues(alpha: 0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      logoAsset,
                                      height: context.width(0.2),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: context.height(0.06)),
                          // Title with enhanced styling
                          FittedBox(
                            child: Text(
                              LocaleKeys.onboarding_app_features_title.tr(),
                              style: context.headlineLarge.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: context.height(0.03)),
                          // Subtitle with better formatting
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: context.width(0.1)),
                            child: Text(
                              LocaleKeys.onboarding_app_features_subtitle.tr(),
                              style: context.bodyLarge.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                height: 1.5,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: context.height(0.04)),
                          // Loading indicator
                          AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return Container(
                                width: context.width(0.6),
                                height: context.height(0.004),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(context.height(0.002)),
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progressController.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(context.height(0.002)),
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.primary.withValues(alpha: 0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Page indicators (moved from bottom)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_appFeatures.length, (index) {
            final isActive = index == _currentFeature;
            final isPast = index < _currentFeature;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: context.width(0.01)),
              width: isActive ? context.width(0.06) : context.width(0.012),
              height: context.height(0.006),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.height(0.003)),
                color: isActive || isPast ? _appFeatures[_currentFeature].color : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: _appFeatures[_currentFeature].color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme) {
    final currentFeature = _appFeatures[_currentFeature];

    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _slideAnimation, _scaleAnimation]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  // Icon with animated background
                  _buildAnimatedIcon(context, currentFeature),
                  SizedBox(height: context.height(0.03)),

                  // Title
                  Text(
                    currentFeature.title,
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.height(0.02)),

                  // Description
                  Padding(
                    padding: context.symmetricPadding(horizontal: 0.02),
                    child: Text(
                      currentFeature.description,
                      style: context.bodyLarge.copyWith(
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.height(0.03)),

                  // Sub-features with enhanced design
                  _buildEnhancedSubFeatures(context, currentFeature, theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedSubFeatures(BuildContext context, AppFeature feature, ThemeData theme) {
    return Column(
      children: feature.subFeatures.asMap().entries.map((entry) {
        final index = entry.key;
        final subFeature = entry.value;

        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _fadeAnimation,
                curve: Interval(
                  index * 0.1,
                  (index * 0.1) + 0.8,
                  curve: Curves.easeOutCubic,
                ),
              )),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _fadeAnimation,
                  curve: Interval(
                    index * 0.1,
                    (index * 0.1) + 0.8,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(bottom: context.height(0.015)),
                  padding: context.symmetricPadding(horizontal: 0.04, vertical: 0.015),
                  decoration: BoxDecoration(
                    color: feature.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(context.width(0.06)),
                    border: Border.all(
                      color: feature.color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: feature.color.withValues(alpha: 0.1),
                        blurRadius: 4,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: context.width(0.012),
                        height: context.width(0.012),
                        decoration: BoxDecoration(
                          color: feature.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: context.width(0.03)),
                      Expanded(
                        child: Text(
                          subFeature,
                          style: context.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
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
      }).toList(),
    );
  }

  Widget _buildAnimatedIcon(BuildContext context, AppFeature feature) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _pulseController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow effect
            Transform.scale(
              scale: _pulseAnimation.value * 1.3,
              child: Container(
                width: context.width(0.35),
                height: context.width(0.35),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      feature.color.withValues(alpha: 0.1),
                      feature.color.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Main preview container
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: context.width(0.28),
                height: context.width(0.28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.width(0.08)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      feature.color.withValues(alpha: 0.15),
                      feature.color.withValues(alpha: 0.08),
                      feature.color.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: feature.color.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: feature.color.withValues(alpha: 0.4),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: feature.color.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.width(0.08)),
                  child: _buildFeaturePreview(context, feature),
                ),
              ),
            ),
            // Inner highlight
            Transform.scale(
              scale: _pulseAnimation.value * 0.8,
              child: Container(
                width: context.width(0.18),
                height: context.width(0.18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.width(0.06)),
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturePreview(BuildContext context, AppFeature feature) {
    // Determine which preview to show based on feature title
    if (feature.title.contains("Habit Probability")) {
      return _buildFormationRatePreview(context, feature);
    } else if (feature.title.contains("Home Widget")) {
      return _buildHomeWidgetPreview(context, feature);
    } else if (feature.title.contains("Goal Setting")) {
      return _buildGoalSettingPreview(context, feature);
    } else if (feature.title.contains("Customizable")) {
      return _buildCustomizablePreview(context, feature);
    } else if (feature.title.contains("Habit Archive")) {
      return _buildArchivePreview(context, feature);
    } else if (feature.title.contains("Share")) {
      return _buildSharePreview(context, feature);
    }

    // Fallback to icon if no specific preview
    return Center(
      child: Icon(
        feature.icon,
        size: context.width(0.12),
        color: feature.color,
      ),
    );
  }

  Widget _buildFormationRatePreview(BuildContext context, AppFeature feature) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(context.width(0.02)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular progress
              SizedBox(
                width: context.width(0.12),
                height: context.width(0.12),
                child: Stack(
                  children: [
                    // Background circle
                    Container(
                      width: context.width(0.12),
                      height: context.width(0.12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: feature.color.withValues(alpha: 0.2),
                      ),
                    ),
                    // Progress arc
                    CustomPaint(
                      size: Size(context.width(0.12), context.width(0.12)),
                      painter: _CircularProgressPainter(
                        progress: 0.8 + (sin(_pulseAnimation.value * 2 * pi) * 0.1),
                        color: feature.color,
                      ),
                    ),
                    // Center percentage
                    Center(
                      child: Text(
                        '${(84 + (sin(_pulseAnimation.value * 2 * pi) * 5)).round()}',
                        style: TextStyle(
                          color: feature.color,
                          fontWeight: FontWeight.w800,
                          fontSize: context.width(0.025),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.height(0.006)),

              // Mini chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  final height = 0.008 + (sin((index + _pulseAnimation.value * 3) * 1.2) * 0.004);
                  return Container(
                    width: context.width(0.012),
                    height: context.height(height),
                    decoration: BoxDecoration(
                      color: feature.color.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(context.width(0.006)),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeWidgetPreview(BuildContext context, AppFeature feature) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(context.width(0.015)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Widget preview card
              SizedBox(
                width: context.width(0.26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.height(0.008)),

                    // Habit items
                    _buildWidgetHabitItem(context, feature, '💧', 'Drink Water', 0.82),
                    SizedBox(height: context.height(0.004)),
                    _buildWidgetHabitItem(context, feature, '🏃', 'Running', 0.63),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWidgetHabitItem(BuildContext context, AppFeature feature, String emoji, String name, double progress) {
    return Container(
      margin: EdgeInsets.only(bottom: context.height(0.003)),
      padding: EdgeInsets.symmetric(horizontal: context.width(0.01), vertical: context.height(0.004)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(context.width(0.02)),
        border: Border.all(
          color: feature.color.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji badge
          Container(
            width: context.width(0.036),
            height: context.width(0.036),
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: TextStyle(fontSize: context.width(0.022)),
            ),
          ),
          SizedBox(width: context.width(0.012)),

          // Title and progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: context.width(0.017),
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.height(0.003)),
                Container(
                  height: context.height(0.004),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.height(0.002)),
                    color: feature.color.withValues(alpha: 0.18),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.height(0.002)),
                        gradient: LinearGradient(
                          colors: [
                            feature.color,
                            feature.color.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharePreview(BuildContext context, AppFeature feature) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(context.width(0.02)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Share card preview
              Container(
                width: context.width(0.18),
                height: context.width(0.12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(context.width(0.015)),
                  border: Border.all(
                    color: feature.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🏆',
                      style: TextStyle(fontSize: context.width(0.03)),
                    ),
                    SizedBox(height: context.height(0.002)),
                    Text(
                      '7 Day Streak!',
                      style: TextStyle(
                        fontSize: context.width(0.018),
                        fontWeight: FontWeight.w700,
                        color: feature.color,
                      ),
                    ),
                    SizedBox(height: context.height(0.001)),
                    Text(
                      'Exercise',
                      style: TextStyle(
                        fontSize: context.width(0.015),
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.height(0.006)),

              // Share icon
              Container(
                width: context.width(0.04),
                height: context.width(0.04),
                decoration: BoxDecoration(
                  color: feature.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.share,
                  color: Colors.white,
                  size: context.width(0.02),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Navigation buttons (indicators moved to header)
        Row(
          children: [
            // Previous button
            if (_currentFeature > 0)
              Expanded(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fadeAnimation.value * 0.05 + 0.95,
                      child: CupertinoButton(
                        onPressed: _isTransitioning ? null : _previousFeature,
                        child: Container(
                          height: context.height(0.055),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(context.width(0.08)),
                            border: Border.all(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            color: theme.colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.chevron_left,
                                  size: context.width(0.05),
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                SizedBox(width: context.width(0.02)),
                                Text(
                                  LocaleKeys.onboarding_app_features_previous.tr(),
                                  style: context.bodyMedium.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_currentFeature > 0) SizedBox(width: context.width(0.03)),

            // Next/Complete button
            Expanded(
              flex: _currentFeature > 0 ? 1 : 2,
              child: AnimatedBuilder(
                animation: Listenable.merge([_fadeAnimation, _pulseController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _fadeAnimation.value * 0.05 + 0.95,
                    child: CupertinoButton(
                      onPressed: _isTransitioning ? null : (_currentFeature < _appFeatures.length - 1 ? _nextFeature : _completeOnboarding),
                      child: Container(
                        height: context.height(0.055),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(context.width(0.08)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _appFeatures[_currentFeature].color,
                              _appFeatures[_currentFeature].color.withValues(alpha: 0.8),
                              _appFeatures[_currentFeature].color.withValues(alpha: 0.9),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _appFeatures[_currentFeature].color.withValues(alpha: 0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: _appFeatures[_currentFeature].color.withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                child: Text(
                                  _currentFeature < _appFeatures.length - 1 ? LocaleKeys.onboarding_app_features_next.tr() : LocaleKeys.onboarding_app_features_start.tr(),
                                  style: context.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: context.width(0.02)),
                              Icon(
                                _currentFeature < _appFeatures.length - 1 ? CupertinoIcons.chevron_right : CupertinoIcons.rocket_fill,
                                size: context.width(0.05),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalSettingPreview(BuildContext context, AppFeature feature) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: context.width(0.3),
          height: context.width(0.3),
          decoration: BoxDecoration(
            color: feature.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.width(0.04)),
            border: Border.all(
              color: feature.color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: context.width(0.08),
                color: feature.color,
              ),
              SizedBox(height: context.height(0.01)),
              Text(
                "Goal\nSetting",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.width(0.035),
                  fontWeight: FontWeight.w600,
                  color: feature.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomizablePreview(BuildContext context, AppFeature feature) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: context.width(0.3),
          height: context.width(0.3),
          decoration: BoxDecoration(
            color: feature.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.width(0.04)),
            border: Border.all(
              color: feature.color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.paintbrush_fill,
                size: context.width(0.08),
                color: feature.color,
              ),
              SizedBox(height: context.height(0.01)),
              Text(
                "Customizable\nThemes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.width(0.035),
                  fontWeight: FontWeight.w600,
                  color: feature.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArchivePreview(BuildContext context, AppFeature feature) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: context.width(0.3),
          height: context.width(0.3),
          decoration: BoxDecoration(
            color: feature.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.width(0.04)),
            border: Border.all(
              color: feature.color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.archivebox_fill,
                size: context.width(0.08),
                color: feature.color,
              ),
              SizedBox(height: context.height(0.01)),
              Text(
                "Habit\nArchive",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.width(0.035),
                  fontWeight: FontWeight.w600,
                  color: feature.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> subFeatures;

  const AppFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.subFeatures,
  });
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1 * progress)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent animation

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height - (random.nextDouble() * size.height * 0.3 * progress);
      final radius = (random.nextDouble() * 3 + 1) * progress;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _IntroParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final random = Random(123); // Different seed for intro

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 4 + 1;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4) / 2;

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress, // Progress in radians
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
