import 'dart:math';

import '../../../core/core.dart';

/// Onboarding - App Features page
///
/// This page showcases how HabitRise will help users build habits,
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
  late final Animation<double> _progressAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _habitFormationAnimation;
  late final Animation<double> _introTransitionAnimation;

  int _currentFeature = 0;
  bool _isTransitioning = false;
  double _habitFormationRate = 0.0;
  bool _showIntro = true;

  final List<AppFeature> _appFeatures = [
    AppFeature(
      title: 'Smart Habit Tracking',
      description: 'Track your habits with intelligent reminders and progress visualization. See your streaks grow and celebrate every milestone.',
      icon: CupertinoIcons.chart_bar_alt_fill,
      color: const Color(0xFF1DB954),
      subFeatures: ['Daily Reminders', 'Progress Charts', 'Streak Tracking'],
    ),
    AppFeature(
      title: 'Sub-Habits System',
      description: 'Break down complex habits into smaller, manageable sub-habits. Build your main habit step by step with micro-actions.',
      icon: CupertinoIcons.layers_fill,
      color: const Color(0xFF0C6CF2),
      subFeatures: ['Micro-Actions', 'Habit Breakdown', 'Nested Tracking'],
    ),
    AppFeature(
      title: 'Habit Formation Rate',
      description: 'Track your habit formation progress with intelligent insights. See how close you are to making your habits stick permanently.',
      icon: CupertinoIcons.chart_bar_square,
      color: const Color(0xFF9B59B6),
      subFeatures: ['Success Prediction', 'Formation Tracking', 'Progress Analytics'],
    ),
    AppFeature(
      title: 'Share Habits',
      description: 'Share your habit progress with beautiful, customizable images. Choose from different designs to showcase your achievements.',
      icon: CupertinoIcons.share,
      color: Colors.deepOrangeAccent,
      subFeatures: ['Custom Designs', 'Progress Sharing', 'Achievement Images'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialAnimation();
    _simulateHabitFormationRate();
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

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _habitFormationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _habitFormationController, curve: Curves.easeOutCubic),
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

  void _simulateHabitFormationRate() async {
    // Simulate habit formation rate calculation
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _habitFormationRate = 0.73; // 73% habit formation rate
      });
    }
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
      backgroundColor: theme.colorScheme.surface,
      child: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    _appFeatures[_currentFeature].color.withValues(alpha: 0.08),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
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
                          // Habit Formation Rate Widget (only for feature 2)
                          if (_currentFeature == 2) ...[
                            SizedBox(height: context.height(0.03)),
                            _buildHabitFormationRate(context, theme),
                          ],
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
    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.surface,
      child: AnimatedBuilder(
        animation: _introTransitionAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - _introTransitionAnimation.value,
            child: Transform.scale(
              scale: 1.0 - (_introTransitionAnimation.value * 0.1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: context.width(0.25),
                            height: context.width(0.25),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF1DB954).withValues(alpha: 0.2),
                                  const Color(0xFF1DB954).withValues(alpha: 0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1DB954).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.heart_fill,
                                size: context.width(0.12),
                                color: const Color(0xFF1DB954),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: context.height(0.06)),
                    // Title
                    FittedBox(
                      child: Text(
                        'HabitRise Helps You ...',
                        style: context.headlineLarge.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: context.height(0.02)),
                    // Subtitle
                    Text(
                      'Build lasting habits with smart tracking and personalized insights',
                      style: context.bodyLarge.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Progress indicator
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: context.height(0.006),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.height(0.003)),
                color: Colors.transparent,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value * ((_currentFeature + 1) / _appFeatures.length),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.height(0.003)),
                    gradient: LinearGradient(
                      colors: [
                        _appFeatures[_currentFeature].color,
                        _appFeatures[_currentFeature].color.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: context.height(0.02)),
        // Step counter
        Text(
          '${_currentFeature + 1} of ${_appFeatures.length}',
          style: context.bodyMedium.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
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
                  SizedBox(height: context.height(0.04)),
                  // Title
                  Text(
                    currentFeature.title,
                    style: context.headlineMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
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
                        height: 1.5,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.height(0.03)),
                  // Sub-features
                  _buildSubFeatures(context, currentFeature, theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubFeatures(BuildContext context, AppFeature feature, ThemeData theme) {
    return Wrap(
      spacing: context.width(0.02),
      runSpacing: context.height(0.01),
      alignment: WrapAlignment.center,
      children: feature.subFeatures.map((subFeature) {
        return Container(
          padding: context.symmetricPadding(horizontal: 0.03, vertical: 0.01),
          decoration: BoxDecoration(
            color: feature.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.width(0.08)),
            border: Border.all(
              color: feature.color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            subFeature,
            style: context.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnimatedIcon(BuildContext context, AppFeature feature) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: context.width(0.25),
            height: context.width(0.25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  feature.color.withValues(alpha: 0.2),
                  feature.color.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: feature.color.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                feature.icon,
                size: context.width(0.12),
                color: feature.color,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHabitFormationRate(BuildContext context, ThemeData theme) {
    final habitColor = const Color(0xFF9B59B6);

    return AnimatedBuilder(
      animation: _habitFormationAnimation,
      builder: (context, child) {
        final animatedScore = _habitFormationAnimation.value * _habitFormationRate * 100;
        return Container(
          padding: context.padding(0.04),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                habitColor.withValues(alpha: 0.1),
                habitColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(context.width(0.06)),
            border: Border.all(
              color: habitColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Formation Score',
                style: context.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: context.height(0.01)),
              Text(
                '${animatedScore.round()}',
                style: context.displaySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: habitColor,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Previous button
        if (_currentFeature > 0)
          Expanded(
            child: CupertinoButton(
              onPressed: _isTransitioning ? null : _previousFeature,
              child: Container(
                height: context.height(0.055),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.width(0.08)),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
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
                        'Previous',
                        style: context.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_currentFeature > 0) SizedBox(width: context.width(0.0025)),
        // Next/Complete button
        Expanded(
          flex: _currentFeature > 0 ? 1 : 2,
          child: CupertinoButton(
            onPressed: _isTransitioning ? null : (_currentFeature < _appFeatures.length - 1 ? _nextFeature : _completeOnboarding),
            child: Container(
              height: context.height(0.055),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.width(0.08)),
                gradient: LinearGradient(
                  colors: [
                    _appFeatures[_currentFeature].color,
                    _appFeatures[_currentFeature].color.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _appFeatures[_currentFeature].color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
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
                        _currentFeature < _appFeatures.length - 1 ? 'Next' : 'Start',
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
