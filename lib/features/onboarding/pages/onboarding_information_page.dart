import 'dart:math';

import '../../../core/core.dart';

/// Onboarding - Information page
///
/// This page provides users with research-backed information about habit formation
/// using principles from Atomic Habits and other proven strategies.
class OnboardingInformationPage extends StatefulWidget {
  const OnboardingInformationPage({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  State<OnboardingInformationPage> createState() => _OnboardingInformationPageState();
}

class _OnboardingInformationPageState extends State<OnboardingInformationPage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _scaleController;
  late final AnimationController _progressController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _progressAnimation;

  int _currentStep = 0;
  bool _isTransitioning = false;

  List<HabitTip> get _habitTips => [
        HabitTip(
          title: LocaleKeys.onboarding_information_tips_start_small_title.tr(),
          description: LocaleKeys.onboarding_information_tips_start_small_description.tr(),
          icon: CupertinoIcons.circle_fill,
          color: const Color(0xFF1DB954),
        ),
        HabitTip(
          title: LocaleKeys.onboarding_information_tips_make_obvious_title.tr(),
          description: LocaleKeys.onboarding_information_tips_make_obvious_description.tr(),
          icon: CupertinoIcons.eye_fill,
          color: const Color(0xFF0C6CF2),
        ),
        HabitTip(
          title: LocaleKeys.onboarding_information_tips_stack_habits_title.tr(),
          description: LocaleKeys.onboarding_information_tips_stack_habits_description.tr(),
          icon: CupertinoIcons.layers_fill,
          color: const Color(0xFF9B59B6),
        ),
        HabitTip(
          title: LocaleKeys.onboarding_information_tips_make_satisfying_title.tr(),
          description: LocaleKeys.onboarding_information_tips_make_satisfying_description.tr(),
          icon: CupertinoIcons.heart_fill,
          color: const Color(0xFFE91E63),
        ),
        HabitTip(
          title: LocaleKeys.onboarding_information_tips_track_progress_title.tr(),
          description: LocaleKeys.onboarding_information_tips_track_progress_description.tr(),
          icon: CupertinoIcons.chart_bar_fill,
          color: const Color(0xFFFFC107),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialAnimation();
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
  }

  void _startInitialAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_isTransitioning || _currentStep >= _habitTips.length - 1) return;

    setState(() {
      _isTransitioning = true;
    });

    // Animate out current content
    await _fadeController.reverse();
    await _slideController.reverse();

    // Move to next step
    setState(() {
      _currentStep++;
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

  void _previousStep() async {
    if (_isTransitioning || _currentStep <= 0) return;

    setState(() {
      _isTransitioning = true;
    });

    // Animate out current content
    await _fadeController.reverse();
    await _slideController.reverse();

    // Move to previous step
    setState(() {
      _currentStep--;
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
    // Navigate to app features page
    if (mounted) {
      Navigator.of(context).pushNamed('/onboardingAppFeatures');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    color: _habitTips[_currentStep].color,
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
                  _buildHeader(context, theme),
                  SizedBox(height: context.height(0.04)),
                  // Main content area
                  Expanded(
                    child: _buildMainContent(context, theme),
                  ),
                  // Navigation buttons
                  _buildNavigationButtons(context, theme),
                  SizedBox(height: context.height(0.03)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        SizedBox(height: context.height(0.02)),
        // Progress indicator
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: context.height(0.006),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.height(0.003)),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value * ((_currentStep + 1) / _habitTips.length),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.height(0.003)),
                    gradient: LinearGradient(
                      colors: [
                        _habitTips[_currentStep].color,
                        _habitTips[_currentStep].color.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: context.height(0.02)),
        // Title
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme) {
    final currentTip = _habitTips[_currentStep];

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with animated background
                  _buildAnimatedIcon(context, currentTip),

                  SizedBox(height: context.height(0.04)),
                  // Title
                  FittedBox(
                    child: Text(
                      currentTip.title,
                      style: context.headlineLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 27,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: context.height(0.02)),
                  // Description
                  Padding(
                    padding: context.symmetricPadding(horizontal: 0.02),
                    child: Text(
                      currentTip.description,
                      style: context.bodyLarge.copyWith(
                        height: 1.5,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
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

  Widget _buildAnimatedIcon(BuildContext context, HabitTip tip) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (context, child) {
        return Container(
          width: context.width(0.25),
          height: context.width(0.25),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                tip.color.withValues(alpha: 0.2),
                tip.color.withValues(alpha: 0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: tip.color.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              tip.icon,
              size: context.width(0.12),
              color: tip.color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Previous button
        if (_currentStep > 0)
          Expanded(
            child: CupertinoButton(
              onPressed: _isTransitioning ? null : _previousStep,
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
                        LocaleKeys.onboarding_information_previous.tr(),
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
        if (_currentStep > 0) SizedBox(width: context.width(0.03)),
        // Next/Complete button
        Expanded(
          flex: _currentStep > 0 ? 1 : 2,
          child: CupertinoButton(
            onPressed: _isTransitioning ? null : (_currentStep < _habitTips.length - 1 ? _nextStep : _completeOnboarding),
            child: Container(
              height: context.height(0.055),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.width(0.08)),
                gradient: LinearGradient(
                  colors: [
                    _habitTips[_currentStep].color,
                    _habitTips[_currentStep].color.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _habitTips[_currentStep].color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep < _habitTips.length - 1 ? LocaleKeys.onboarding_information_next.tr() : LocaleKeys.onboarding_information_get_started.tr(),
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

class HabitTip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const HabitTip({
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
