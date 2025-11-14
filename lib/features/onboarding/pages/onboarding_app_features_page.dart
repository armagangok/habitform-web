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
  late final AnimationController _habitProbabilityController;
  late final AnimationController _introTransitionController;
  late final AnimationController _titleController;
  late final AnimationController _descriptionController;
  late final AnimationController _buttonController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  late final Animation<double> _pulseAnimation;

  late final Animation<double> _introTransitionAnimation;
  late final Animation<double> _titleAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _descriptionAnimation;
  late final Animation<Offset> _descriptionSlideAnimation;
  late final Animation<double> _buttonAnimation;

  int _currentFeature = 0;
  bool _isTransitioning = false;

  bool _showIntro = true;

  List<AppFeature> get _appFeatures => [
        AppFeature(
          title: "Habit Probability",
          description: "See exactly how likely you are to succeed with each habit. Get personalized insights that help you stay motivated and build lasting habits.",
          icon: CupertinoIcons.chart_bar_square,
          color: context.cupertinoTheme.primaryColor,
        ),
        AppFeature(
          title: "Home Widget",
          description: "Track your habits without opening the app. Complete your daily goals directly from your phone home screen in seconds.",
          icon: CupertinoIcons.square_grid_2x2_fill,
          color: context.cupertinoTheme.primaryColor,
        ),
        AppFeature(
          title: "Goal Setting",
          description: "Science‑based planning that adapts to difficulty: easier habits form faster, harder ones take longer—keeping goals realistic.",
          icon: CupertinoIcons.checkmark_circle_fill,
          color: context.cupertinoTheme.primaryColor,
        ),
        AppFeature(
          title: "Customizable",
          description: "Make HabitForm truly yours. Choose colors, themes, and layouts that match your personality and keep you engaged.",
          icon: CupertinoIcons.paintbrush_fill,
          color: context.cupertinoTheme.primaryColor,
        ),
        AppFeature(
          title: "Data Management",
          description: "Export your habits data to CSV files for backup or transfer to another device.",
          icon: CupertinoIcons.doc_text_fill,
          color: context.cupertinoTheme.primaryColor,
        ),
        AppFeature(
          title: "Share Habits",
          description: "Celebrate your wins with friends and family. Share beautiful progress visuals that inspire others and keep you accountable.",
          icon: CupertinoIcons.share,
          color: context.cupertinoTheme.primaryColor,
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
    // Removed automatic transition - now controlled by continue button
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

    _habitProbabilityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _introTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _descriptionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic));

    _descriptionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _descriptionController, curve: Curves.easeOutCubic),
    );

    _descriptionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _descriptionController, curve: Curves.easeOutCubic));

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );
  }

  void _startInitialAnimation() async {
    // Start with logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _habitProbabilityController.forward();

    // Start title animation after logo
    await Future.delayed(const Duration(milliseconds: 500));
    _titleController.forward();

    // Start description animation after title
    await Future.delayed(const Duration(milliseconds: 600));
    _descriptionController.forward();

    // Show continue button after 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _habitProbabilityController.dispose();
    _introTransitionController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _buttonController.dispose();
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

  // Transition from the intro hero to the features carousel
  Future<void> _showFeatures() async {
    if (!_showIntro) return;
    await _introTransitionController.forward();
    if (!mounted) return;
    setState(() {
      _showIntro = false;
    });
    _fadeController.forward();
    _slideController.forward();
    _progressController.forward();
  }

  void _completeOnboarding() {
    // Proceed to the next step (rating) after features are done
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      if (mounted) {
        navigator.navigateAndClear(path: KRoute.onboardingRating);
      }
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
                            animation: Listenable.merge([_fadeAnimation, _slideAnimation, _scaleAnimation, _pulseAnimation]),
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: Transform.scale(
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
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: context.height(0.06)),
                          // Title with sequential animation
                          AnimatedBuilder(
                            animation: Listenable.merge([_titleAnimation, _titleSlideAnimation]),
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _titleAnimation,
                                child: SlideTransition(
                                  position: _titleSlideAnimation,
                                  child: FittedBox(
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
                                ),
                              );
                            },
                          ),
                          SizedBox(height: context.height(0.03)),
                          // Description with sequential animation
                          AnimatedBuilder(
                            animation: Listenable.merge([_descriptionAnimation, _descriptionSlideAnimation]),
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _descriptionAnimation,
                                child: SlideTransition(
                                  position: _descriptionSlideAnimation,
                                  child: Padding(
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
                                ),
                              );
                            },
                          ),
                          SizedBox(height: context.height(0.06)),
                          // Continue button with animation
                          AnimatedBuilder(
                            animation: _buttonAnimation,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _buttonAnimation,
                                child: ScaleTransition(
                                  scale: _buttonAnimation,
                                  child: CupertinoButton(
                                    onPressed: _showFeatures,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: context.width(0.08),
                                        vertical: context.height(0.02),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(context.width(0.08)),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            theme.colorScheme.primary,
                                            theme.colorScheme.primary.withValues(alpha: 0.8),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                            blurRadius: 15,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            LocaleKeys.onboarding_continue_button.tr(),
                                            style: context.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(width: context.width(0.02)),
                                          Icon(
                                            CupertinoIcons.arrow_right_circle_fill,
                                            color: Colors.white,
                                            size: context.width(0.05),
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
                  SizedBox(height: context.height(0.03)),
                  Text(
                    currentFeature.title,
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.height(0.04)),
                  // Icon with animated background
                  _buildAnimatedImage(context, currentFeature),
                  SizedBox(height: context.height(0.03)),

                  // Title

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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedImage(BuildContext context, AppFeature feature) {
    final String? screenshotPath = _screenshotForFeature(feature);
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.05 + (_pulseAnimation.value - 0.8) * 0.2,
          child: SizedBox(
            height: context.height(0.45),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.width(0.04)),
              child: screenshotPath != null
                  ? Image.asset(
                      screenshotPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _fallbackIcon(context, feature);
                      },
                    )
                  : _fallbackIcon(context, feature),
            ),
          ),
        );
      },
    );
  }

  String? _screenshotForFeature(AppFeature feature) {
    final title = feature.title.toLowerCase();
    if (title.contains('habit probability')) {
      return 'assets/screenshots/habit_probability.png';
    }
    if (title.contains('home widget')) {
      return 'assets/screenshots/home_widget.png';
    }
    if (title.contains('goal')) {
      return 'assets/screenshots/difficulty_goal.png';
    }
    if (title.contains('custom')) {
      return 'assets/screenshots/customize.png';
    }
    if (title.contains('data management') || title.contains('export') || title.contains('import')) {
      return 'assets/screenshots/export_import.png';
    }
    if (title.contains('share')) {
      return 'assets/screenshots/share.png';
    }
    // No screenshots available for other features
    return null;
  }

  Widget _fallbackIcon(BuildContext context, AppFeature feature) {
    return Container(
      color: feature.color.withValues(alpha: 0.06),
      child: Center(
        child: Icon(
          feature.icon,
          size: context.width(0.14),
          color: feature.color,
        ),
      ),
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
}

class AppFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const AppFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
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

// Removed old circular painter; screenshots now represent features
