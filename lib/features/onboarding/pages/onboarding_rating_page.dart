import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/helpers/in_app_review/in_app_review.dart';
import '../providers/onboarding_provider.dart';

/// Onboarding - Rating page
///
/// This page asks users to rate the app after they've seen all the features.
/// It provides an engaging way to collect user feedback and improve app store ratings.
class OnboardingRatingPage extends ConsumerStatefulWidget {
  const OnboardingRatingPage({super.key});

  @override
  ConsumerState<OnboardingRatingPage> createState() => _OnboardingRatingPageState();
}

class _OnboardingRatingPageState extends ConsumerState<OnboardingRatingPage> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _scaleController;
  late final AnimationController _pulseController;
  late final AnimationController _sparkleController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _sparkleAnimation;

  bool _isTransitioning = false;

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

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

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
  }

  void _startInitialAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _rateApp() async {
    if (_isTransitioning) return;

    setState(() {
      _isTransitioning = true;
    });

    try {
      // Try to open the in-app review dialog
      final success = await InAppReviewHelper.shared.requestReviewDirectly();

      if (success) {
        // In-app review was shown successfully
        _showRatingSuccess();
      } else {
        // In-app review is not available, show fallback message
        _showRatingFallback();
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error requesting review: $e');
      _showRatingFallback();
    } finally {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    }
  }

  void _showRatingSuccess() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(LocaleKeys.onboarding_rating_thank_you.tr()),
        content: Text(LocaleKeys.onboarding_rating_feedback_message.tr()),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              _completeOnboarding();
            },
            child: Text(LocaleKeys.onboarding_rating_continue.tr()),
          ),
        ],
      ),
    );
  }

  void _showRatingFallback() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(LocaleKeys.onboarding_rating_rate_title.tr()),
        content: Text(LocaleKeys.onboarding_rating_rate_message.tr()),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              _completeOnboarding();
            },
            child: Text(LocaleKeys.onboarding_rating_continue.tr()),
          ),
        ],
      ),
    );
  }

  void _skipRating() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Complete the onboarding flow using the provider
    final onboardingNotifier = ref.read(onboardingProvider.notifier);
    onboardingNotifier.completeOnboarding(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoPageScaffold(
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
                    theme.colorScheme.primary.withValues(alpha: 0.08),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          // Floating sparkles animation
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _SparklePainter(
                    progress: _sparkleAnimation.value,
                    color: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          // Main content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: context.symmetricPadding(horizontal: 0.06),
              child: Column(
                children: [
                  // Header with Skip button

                  SizedBox(height: context.height(0.08)),
                  // Main content area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: context.height(0.02)),
                      child: Column(
                        children: [
                          _buildMainContent(context, theme),
                          SizedBox(height: context.height(0.08)),
                          _buildActionButtons(context, theme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ThemeData theme) {
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
                  // Animated icon
                  _buildAnimatedIcon(context),
                  SizedBox(height: context.height(0.06)),
                  // Title
                  Text(
                    LocaleKeys.onboarding_rating_title.tr(),
                    style: context.headlineLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.height(0.03)),
                  // Description
                  Padding(
                    padding: context.symmetricPadding(horizontal: 0.02),
                    child: Text(
                      LocaleKeys.onboarding_rating_description.tr(),
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

  Widget _buildAnimatedIcon(BuildContext context) {
    final theme = Theme.of(context);
    final String logoAsset = Assets.app.appLogoDark.path;

    return AnimatedBuilder(
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
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  logoAsset,
                  width: context.width(0.12),
                  height: context.width(0.12),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Rate App button
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: context.height(0.02)),
          child: CupertinoButton(
            onPressed: _isTransitioning ? null : _rateApp,
            child: Container(
              height: context.height(0.055),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.width(0.08)),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: _isTransitioning
                    ? SizedBox(
                        width: context.width(0.05),
                        height: context.width(0.05),
                        child: const CupertinoActivityIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            size: context.width(0.05),
                            color: Colors.white,
                          ),
                          SizedBox(width: context.width(0.02)),
                          Text(
                            LocaleKeys.onboarding_rating_rate_button.tr(),
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
        // Maybe Later button
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            onPressed: _isTransitioning ? null : _skipRating,
            child: SizedBox(
              height: context.height(0.025),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.onboarding_rating_maybe_later.tr(),
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
      ],
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SparklePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1 * progress)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent animation

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (random.nextDouble() * 2 + 1) * progress;
      final opacity = (random.nextDouble() * 0.5 + 0.3) * progress;

      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
