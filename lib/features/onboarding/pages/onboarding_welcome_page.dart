import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';

import '../../../core/core.dart';
import '../../../models/completion_entry/completion_entry.dart';
import '../../../models/habit/habit_difficulty.dart';
import '../../../models/habit/habit_model.dart';
import '../../../services/analytics_service.dart';
import '../../home/components/habit_probability_dialog.dart';
import '../../home/views/widgets/habit_canvas/circular_habit_preview_widget.dart';
import '../enum/onboarding_step_enum.dart';

/// Onboarding - Welcome page
///
/// Layout
/// - Top: "Welcome to" text
/// - Center: App logo
/// - Below logo: App name text (HabitForm)
/// - Bottom: CTA button with a gently oscillating arrow icon
class OnboardingWelcomePage extends StatefulWidget {
  const OnboardingWelcomePage({super.key});

  @override
  State<OnboardingWelcomePage> createState() => _OnboardingWelcomePageState();
}

class _OnboardingWelcomePageState extends State<OnboardingWelcomePage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _arrowOffsetX;
  late final AnimationController _cardsController;
  late final Animation<double> _cardsAnim;
  late final AnimationController _centerCardController;
  late ConfettiController _confettiController;

  bool _showTagline = false;
  bool _isCenterCardCompleted = false;
  bool _showMotivationalMessage = false;
  bool _isButtonDisabled = false;
  bool _isTransitioning = false;
  bool _isCenterCardReady = false;
  bool _showFinalMessage = false;
  bool _showFinalCta = false;
  int _runningStreak = 12; // Initial streak value

  OnboardingStep _currentStep = OnboardingStep.initial;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Subtle left-right oscillation for the arrow inside the CTA
    _arrowOffsetX = Tween<double>(begin: -6, end: 6)
        .chain(
          CurveTween(curve: Curves.easeInOut),
        )
        .animate(_controller);

    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardsAnim = CurvedAnimation(parent: _cardsController, curve: Curves.easeInOutCubic);

    _centerCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    _cardsController.dispose();
    _centerCardController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = ResponsiveHelper.isTablet(screenWidth) || ResponsiveHelper.isTabletLandscape(screenWidth) || ResponsiveHelper.isDesktop(screenWidth);

    // Cache responsive values
    final logoHeight = isTablet ? 70.0 : 60.0;
    final taglineFontSize = isTablet ? 32.0 : 28.0;
    final justLikeThatFontSize = isTablet ? 24.0 : 20.0;
    final finalMessageFontSize = isTablet ? 32.0 : 28.0;
    final iconSize = isTablet ? 28.0 : 24.0;

    // Use transparent logo variants if available, falling back to regular app logos
    final String logoAsset = Assets.app.appLogoDark.path;

    return CupertinoPageScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // For tablets, center content with max width
          Widget content = Stack(
            children: [
              // A very soft radial vignette for depth/atmosphere

              // Habit demo cards layer
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;
                    return AnimatedBuilder(
                      animation: Listenable.merge([
                        _cardsAnim,
                        _centerCardController,
                      ]),
                      builder: (context, _) {
                        return Stack(
                          children: [
                            _buildCard(
                              context,
                              index: 0,
                              screenSize: size,
                              screenWidth: screenWidth,
                              isTablet: isTablet,
                              color: const Color(0xFF0E291E),
                              accent: const Color(0xFF1DB954),
                              emoji: '🏃',
                              title: LocaleKeys.onboarding_pages_welcome_habit_examples_running.tr(),
                              badgeValue: 12,
                              initial: _getInitialPosition(context, size, 0, screenWidth, isTablet),
                              initialRotation: -0.20,
                              isLeftSide: true,
                              tier: 1, // dock lower-left when stacked
                            ),
                            _buildCard(
                              context,
                              index: 1,
                              screenSize: size,
                              screenWidth: screenWidth,
                              isTablet: isTablet,
                              color: const Color(0xFF0C2B57),
                              accent: const Color(0xFF0C6CF2),
                              emoji: '📚',
                              title: LocaleKeys.onboarding_pages_welcome_habit_examples_read_book.tr(),
                              badgeValue: 21,
                              initial: _getInitialPosition(context, size, 1, screenWidth, isTablet),
                              initialRotation: 0.2,
                              isLeftSide: false,
                              tier: 0,
                            ),
                            _buildCard(
                              context,
                              index: 2,
                              screenSize: size,
                              screenWidth: screenWidth,
                              isTablet: isTablet,
                              color: const Color(0xFF0C2B57),
                              accent: const Color(0xFF0C6CF2),
                              emoji: '🍎',
                              title: LocaleKeys.onboarding_pages_welcome_habit_examples_read_book.tr(),
                              badgeValue: 21,
                              initial: _getInitialPosition(context, size, 2, screenWidth, isTablet),
                              initialRotation: -0.2,
                              isLeftSide: false,
                              tier: 0,
                            ),
                            _buildCard(
                              context,
                              index: 3,
                              screenSize: size,
                              screenWidth: screenWidth,
                              isTablet: isTablet,
                              color: const Color(0xFF0C2B57),
                              accent: const Color(0xFF0C6CF2),
                              emoji: '📝',
                              title: LocaleKeys.onboarding_pages_welcome_habit_examples_read_book.tr(),
                              badgeValue: 21,
                              initial: _getInitialPosition(context, size, 3, screenWidth, isTablet),
                              initialRotation: 0.2,
                              isLeftSide: false,
                              tier: 0,
                            ),
                            _buildCard(
                              context,
                              index: 4,
                              screenSize: size,
                              screenWidth: screenWidth,
                              isTablet: isTablet,
                              color: const Color(0xFF2A1547),
                              accent: const Color(0xFF9B59B6),
                              emoji: '🧘',
                              title: LocaleKeys.onboarding_pages_welcome_habit_examples_meditate.tr(),
                              badgeValue: 8,
                              initial: _getInitialPosition(context, size, 4, screenWidth, isTablet),
                              initialRotation: -0.2,
                              isLeftSide: true,
                              tier: 0, // dock upper-left when stacked
                            ),
                            _buildCard(
                              context,
                              index: 5,
                              screenSize: size,
                              screenWidth: screenWidth,
                              isTablet: isTablet,
                              color: const Color(0xFF0B2F35),
                              accent: const Color(0xFF2EC7E6),
                              emoji: '💧',
                              title: LocaleKeys.onboarding_pages_welcome_habit_examples_drink_water.tr(),
                              badgeValue: 30,
                              initial: _getInitialPosition(context, size, 5, screenWidth, isTablet),
                              initialRotation: 0.2,
                              isLeftSide: false,
                              tier: 1,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              // Confetti overlay (optimized) - ignore pointer events so it never blocks taps
              IgnorePointer(
                ignoring: true,
                child: Align(
                  alignment: const Alignment(0, -0.2), // upper center
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.025, // more particles per tick
                    numberOfParticles: 14, // richer burst
                    minBlastForce: 8, // initial speed min
                    maxBlastForce: 18, // initial speed max
                    gravity: 0.25, // fall speed
                    particleDrag: 0.08, // slow down slightly
                    shouldLoop: false,
                    colors: const [
                      Color(0xFFE91E63), // Pink
                      Color(0xFF2196F3), // Blue
                      Color(0xFF4CAF50), // Green
                      Color(0xFFFFC107), // Yellow
                      Color(0xFFFF5722), // Orange
                      Color(0xFF9C27B0), // Purple
                    ],
                    createParticlePath: _drawStar,
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Stack(
                  children: [
                    // Main content area - Fixed positioning to prevent layout shifts
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_cardsAnim, _centerCardController]),
                        builder: (context, _) {
                          final progress = _cardsAnim.value;
                          final centerProgress = _centerCardController.value;
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Welcome block fades out in place (non-interactive, ignore taps)
                              IgnorePointer(
                                ignoring: true,
                                child: Opacity(
                                  opacity: 1.0 - progress,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        LocaleKeys.onboarding_pages_welcome_welcome_to.tr(),
                                        style: context.headlineSmall.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.asset(
                                              logoAsset,
                                              height: logoHeight,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          SizedBox(height: context.height(0.006)), // Responsive spacing
                                          Text(
                                            LocaleKeys.onboarding_pages_welcome_app_name.tr(),
                                            style: context.displaySmall.copyWith(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tagline fades in, then fades out when center card appears
                              // Never show tagline if final message is shown, if we're in completed state, or if motivational message is showing
                              if (_currentStep == OnboardingStep.cardsStackedAtBottom)
                                IgnorePointer(
                                  ignoring: true,
                                  child: AnimatedOpacity(
                                    opacity: (((progress > 0.02 || _showTagline) && !(_currentStep == OnboardingStep.exerciseCardInCenter && centerProgress > 0.7)) ? (_currentStep == OnboardingStep.exerciseCardInCenter ? (centerProgress > 0.7 ? 0.0 : progress * (1.0 - centerProgress.clamp(0.0, 0.7))) : progress) : 0.0),
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutCubic,
                                    child: Padding(
                                      padding: context.symmetricPadding(horizontal: 0.025), // Responsive horizontal padding
                                      child: SizedBox(
                                        width: context.width(0.9),
                                        child: Text(
                                          LocaleKeys.onboarding_pages_welcome_build_dream_life.tr(),
                                          style: context.headlineLarge.copyWith(
                                            fontSize: taglineFontSize,
                                            height: 1.1,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Bottom CTA button - Fixed positioning at bottom
                    if (!(_currentStep == OnboardingStep.exerciseCardInCenter && !_showMotivationalMessage) && (_currentStep != OnboardingStep.completed || _showFinalCta))
                      Positioned(
                        bottom: context.height(0.022),
                        left: 0,
                        right: 0,
                        child: _BottomCtaButton(
                          arrowOffsetX: _arrowOffsetX,
                          onPressed: _isButtonDisabled ? null : _onCtaPressed,
                          // Show a motivating label once the aha-moment is complete
                          label: _currentStep == OnboardingStep.completed && _showFinalCta ? 'See my plan' : null,
                        ),
                      ),
                    // Center-step instruction (below the card area)
                    if (_currentStep == OnboardingStep.exerciseCardInCenter && !_isCenterCardCompleted)
                      Positioned(
                        top: context.dynamicHeight / 2 + context.height(0.035), // Position below the center card (card height/2 + 15 padding)
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          opacity: _isCenterCardReady ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 350),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.hand_point_right_fill,
                                size: iconSize,
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(height: context.height(0.01)), // Responsive spacing
                              Text(
                                LocaleKeys.onboarding_pages_welcome_try_tapping.tr(),
                                style: context.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // "Just like that!" text above the card
                    if (_showMotivationalMessage)
                      Positioned(
                        top: context.dynamicHeight / 2 - context.height(0.3), // Position well above the center card
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          opacity: _showMotivationalMessage ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          child: Text(
                            LocaleKeys.onboarding_pages_welcome_just_like_that.tr(),
                            style: context.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: justLikeThatFontSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    // Final message in center
                    if (_showFinalMessage)
                      Positioned.fill(
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: _showFinalMessage ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            child: Padding(
                              padding: context.symmetricPadding(horizontal: 0.025),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    LocaleKeys.onboarding_pages_welcome_change_life.tr(),
                                    style: context.headlineLarge.copyWith(
                                      fontSize: finalMessageFontSize,
                                      height: 1.1,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    LocaleKeys.onboarding_pages_welcome_one_habit_time.tr(),
                                    style: context.headlineLarge.copyWith(
                                      fontSize: finalMessageFontSize,
                                      height: 1.1,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Congratulations messages below the card
                    if (_showMotivationalMessage)
                      Positioned(
                        top: (screenHeight + context.width(0.2)) / 2, // Position below the center card (card bottom + padding)
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          opacity: _showMotivationalMessage ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                LocaleKeys.onboarding_pages_welcome_congratulations.tr(),
                                style: context.headlineSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1DB954),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: context.height(0.01)), // Responsive spacing
                              Text(
                                LocaleKeys.onboarding_pages_welcome_completed_first_habit.tr(),
                                style: context.titleMedium.copyWith(),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: context.height(0.005)), // Responsive spacing
                              Text(
                                LocaleKeys.onboarding_pages_welcome_journey_begins.tr(),
                                style: context.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );

          // For tablets, wrap with max width constraint and center
          if (isTablet) {
            final maxWidth = ResponsiveHelper.getMaxContentWidth(screenWidth);
            content = Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: content,
              ),
            );
          }

          return content;
        },
      ),
    );
  }

  void _onCtaPressed() async {
    // Hard lock to guarantee single-step progression and avoid mid-animation presses
    if (_isTransitioning || _cardsController.isAnimating || _centerCardController.isAnimating || _isButtonDisabled) return;
    setState(() {
      _isTransitioning = true;
      _isButtonDisabled = true;
    });

    LogHelper.shared.debugPrint('Debug: Button pressed, current step: ${_currentStep.name}');
    switch (_currentStep) {
      case OnboardingStep.initial:
        // Step 1: Move cards down and show tagline
        try {
          await _cardsController.forward();
          setState(() {
            _showTagline = true;
            _currentStep = OnboardingStep.cardsStackedAtBottom;
          });
        } finally {
          // Re-enable CTA after step completes
          setState(() {
            _isTransitioning = false;
            _isButtonDisabled = false;
          });
        }
        break;

      case OnboardingStep.cardsStackedAtBottom:
        // Step 2: Move Exercise card to center and fade out tagline
        LogHelper.shared.debugPrint('Debug: Starting center card animation');
        try {
          // Ensure center animation starts from 0 for a smooth transition
          _centerCardController.stop();
          _centerCardController.value = 0.0;
          setState(() {
            _currentStep = OnboardingStep.exerciseCardInCenter;
            _isCenterCardReady = true; // Enable card interaction immediately
          });
          await _centerCardController.forward();
          LogHelper.shared.debugPrint('Debug: Center card animation completed');
        } finally {
          setState(() {
            _isTransitioning = false;
            _isButtonDisabled = false;
          });
        }
        break;

      case OnboardingStep.exerciseCardInCenter:
        // Step 3: Handle completion or reset
        if (_isCenterCardCompleted && _showMotivationalMessage) {
          // Start reset flow: fade out messages, return card, show final message
          try {
            setState(() {
              _showMotivationalMessage = false; // Fade out motivational messages
              _showTagline = false; // Hide tagline to prevent reappearance
            });

            // Wait for fade out animation
            await Future.delayed(const Duration(milliseconds: 600));

            // Return center card to stacked position (don't reverse cards animation)
            await _centerCardController.reverse();

            // Show final message
            setState(() {
              _showTagline = false;
              _isCenterCardCompleted = false;
              _isCenterCardReady = false;
              _showFinalMessage = true;
              _currentStep = OnboardingStep.completed;
            });

            // Show CTA button after final message appears
            await Future.delayed(const Duration(milliseconds: 1000));
            if (mounted) {
              setState(() {
                _showFinalCta = true;
              });
            }
          } finally {
            setState(() {
              _isTransitioning = false;
              _isButtonDisabled = false;
            });
          }
        } else {
          // If card is not completed yet or message not shown, do nothing
          LogHelper.shared.debugPrint('Debug: Card not completed or message not shown yet, current step: ${_currentStep.name}');
          setState(() {
            _isTransitioning = false;
            _isButtonDisabled = false;
          });
        }
        break;

      case OnboardingStep.completed:
        // Final step - handle final CTA button press
        if (_showFinalCta) {
          AnalyticsService.logOnboardingStep('welcome_completed');
          // Navigate to goal selection page
          if (mounted) {
            Navigator.of(context).pushNamed('/onboardingGoal');
          }
        } else {
          // If CTA not ready yet, do nothing
          setState(() {
            _isTransitioning = false;
            _isButtonDisabled = false;
          });
        }
        break;
    }
  }

  // Cache star path to avoid recalculating on every frame
  Path? _cachedStarPath;
  Size? _cachedStarSize;

  static double _degToRad(double deg) => deg * (pi / 180.0);

  Path _drawStar(Size size) {
    // Reuse cached path if size hasn't changed
    if (_cachedStarPath != null && _cachedStarSize == size) {
      return _cachedStarPath!;
    }

    // draws a star

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = _degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = _degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step), halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep), halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();

    // Cache the path
    _cachedStarPath = path;
    _cachedStarSize = size;
    return path;
  }

  void _onCenterCardTap() async {
    if (_isCenterCardCompleted || !_isCenterCardReady) return;

    LogHelper.shared.debugPrint('Debug: Center card tapped!');
    setState(() {
      _isCenterCardCompleted = true;
    });
    _runningStreak++; // Increment streak

    // Start confetti animation
    _confettiController.play();

    // Create a mock habit for the achievement dialog with sample completion data
    final today = DateTime.now();
    final mockCompletions = <String, CompletionEntry>{
      // Son 12 gün boyunca %85 completion rate ile örnek veriler
      today.subtract(const Duration(days: 11)).toIso8601String(): CompletionEntry(
        id: '1',
        date: today.subtract(const Duration(days: 11)),
        count: 1,
        isCompleted: true,
      ),
      today.subtract(const Duration(days: 10)).toIso8601String(): CompletionEntry(
        id: '2',
        date: today.subtract(const Duration(days: 10)),
        count: 1,
        isCompleted: true,
      ),
      today.subtract(const Duration(days: 9)).toIso8601String(): CompletionEntry(
        id: '3',
        date: today.subtract(const Duration(days: 9)),
        count: 1,
        isCompleted: true,
      ),
      today.subtract(const Duration(days: 8)).toIso8601String(): CompletionEntry(
        id: '4',
        date: today.subtract(const Duration(days: 8)),
        count: 0,
        isCompleted: false,
      ), // Missed day
      today.subtract(const Duration(days: 7)).toIso8601String(): CompletionEntry(
        id: '5',
        date: today.subtract(const Duration(days: 7)),
        count: 1,
        isCompleted: true,
      ),
      today.subtract(const Duration(days: 6)).toIso8601String(): CompletionEntry(
        id: '6',
        date: today.subtract(const Duration(days: 6)),
        count: 1,
        isCompleted: true,
      ),
      today.subtract(const Duration(days: 5)).toIso8601String(): CompletionEntry(
        id: '7',
        date: today.subtract(const Duration(days: 5)),
        count: 1,
        isCompleted: true,
      ),
      today.subtract(const Duration(days: 4)).toIso8601String(): CompletionEntry(
        id: '8',
        date: today.subtract(const Duration(days: 4)),
        count: 1,
        isCompleted: true,
      ),
      today.subtract(const Duration(days: 3)).toIso8601String(): CompletionEntry(
        id: '9',
        date: today.subtract(const Duration(days: 3)),
        count: 0,
        isCompleted: false,
      ), // Missed day
      today.subtract(const Duration(days: 2)).toIso8601String(): CompletionEntry(
        id: '10',
        date: today.subtract(const Duration(days: 2)),
        count: 1,
        isCompleted: true,
      ),
      today.subtract(const Duration(days: 1)).toIso8601String(): CompletionEntry(
        id: '11',
        date: today.subtract(const Duration(days: 1)),
        count: 1,
        isCompleted: true,
      ),
      today.toIso8601String(): CompletionEntry(
        id: '12',
        date: today,
        count: 1,
        isCompleted: true,
      ), // Today's completion
    };

    final mockHabit = Habit(
      id: 'onboarding_running',
      habitName: LocaleKeys.onboarding_pages_welcome_habit_examples_running.tr(),
      emoji: '🏃',
      colorCode: 0xFF1DB954,
      completions: mockCompletions,
      difficulty: HabitDifficulty.moderate, // Moderate difficulty for realistic formation score
      dailyTarget: 1, // 1 run per day
    );

    // Show achievement dialog after a short delay
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => HabitProbabilityDialog(
          habit: mockHabit,
          pointsGained: 10,
          previousScore: _runningStreak - 1,
          newScore: _runningStreak,
          message: LocaleKeys.onboarding_achievement_first_habit_message.tr(),
        ),
      );

      // After dialog is closed, show congratulations message
      if (mounted) {
        setState(() {
          _showMotivationalMessage = true;
          _isButtonDisabled = false;
        });
      }
    }
  }

  // Get responsive initial position based on device type
  Offset _getInitialPosition(BuildContext context, Size screenSize, int index, double screenWidth, bool isTablet) {
    // Phone positions (same for both, but tablet will be centered)
    final phonePositions = {
      0: Offset(-context.width(0.125), context.height(0.1)), // Top-left
      1: Offset(screenSize.width - context.width(0.725) + context.width(0.15), context.height(0.1)), // Top-right
      2: Offset(-context.width(0.125), context.height(0.35)), // Middle-left
      3: Offset(screenSize.width - context.width(0.725) + context.width(0.15), context.height(0.35)), // Middle-right
      4: Offset(-context.width(0.15), screenSize.height - context.height(0.36)), // Bottom-left
      5: Offset(screenSize.width - context.width(0.725) + context.width(0.15), screenSize.height - context.height(0.36)), // Bottom-right
    };

    if (isTablet) {
      // Tablet: Use same positions as phone but center them within max content width
      final maxContentWidth = ResponsiveHelper.getMaxContentWidth(screenWidth);
      final phoneOffset = phonePositions[index] ?? Offset.zero;

      // Center the phone layout within the tablet's max content width
      // Phone layout is based on screenSize.width, we need to offset it
      final centerOffset = (screenSize.width - maxContentWidth) / 2;

      return Offset(phoneOffset.dx + centerOffset, phoneOffset.dy);
    } else {
      // Phone: original positions
      return phonePositions[index] ?? Offset.zero;
    }
  }

  // Responsive docked positions for each card
  Map<String, double> _getDockedPosition(int index, Size screenSize, BuildContext context, double screenWidth, bool isTablet) {
    final double cardWidth = context.width(0.65); // Same size for both phone and tablet

    // Phone docked positions (same layout for both)
    final phoneDockedPositions = {
      0: {
        'x': -context.width(0.1),
        'y': screenSize.height - context.height(0.265),
        'rotation': 0.5,
        'scale': 0.9,
      }, // Running card
      1: {
        'x': screenSize.width - cardWidth + context.width(0.1),
        'y': screenSize.height - context.height(0.25),
        'rotation': -0.35,
        'scale': 0.92,
      }, // Read Book 1
      2: {
        'x': -context.width(0.1),
        'y': screenSize.height - context.height(0.2),
        'rotation': 0.3,
        'scale': 0.88,
      }, // Read Book 2
      3: {
        'x': screenSize.width - cardWidth + context.width(0.15),
        'y': screenSize.height - context.height(0.18),
        'rotation': -0.25,
        'scale': 0.86,
      }, // Read Book 3
      4: {
        'x': -context.width(0.15),
        'y': screenSize.height - context.height(0.12),
        'rotation': 0.15,
        'scale': 0.88,
      }, // Meditate
      5: {
        'x': screenSize.width - cardWidth + context.width(0.15),
        'y': screenSize.height - context.height(0.12),
        'rotation': -0.15,
        'scale': 0.85,
      }, // Drink Water
    };

    final phonePos = phoneDockedPositions[index] ??
        {
          'x': 0.0,
          'y': 0.0,
          'rotation': 0.0,
          'scale': 1.0,
        };

    if (isTablet) {
      // Tablet: Use same positions as phone but center them within max content width
      final maxContentWidth = ResponsiveHelper.getMaxContentWidth(screenWidth);
      final centerOffset = (screenSize.width - maxContentWidth) / 2;

      return {
        'x': phonePos['x']! + centerOffset,
        'y': phonePos['y']!,
        'rotation': phonePos['rotation']!,
        'scale': phonePos['scale']!,
      };
    } else {
      // Phone: Original docked positions
      return phonePos;
    }
  }

  Widget _buildCard(
    BuildContext context, {
    required int index,
    required Size screenSize,
    required double screenWidth,
    required bool isTablet,
    required Color color,
    required Color accent,
    required String emoji,
    required String title,
    required int badgeValue,
    required Offset initial,
    required double initialRotation,
    required bool isLeftSide,
    required int tier,
  }) {
    final double value = _cardsAnim.value; // 0 → scattered, 1 → stacked bottom

    // Card size is the same for both phone and tablet (same as phone)
    final double cardWidth = context.width(0.65);
    final double cardHeight = cardWidth; // Square aspect ratio
    final Size cardSize = Size(cardWidth, cardHeight);

    // Get responsive docked position for this card
    final dockedPos = _getDockedPosition(index, screenSize, context, screenWidth, isTablet);

    if (isTablet) {
      // Tablet: Use same card size as phone, positions are already adjusted in _getInitialPosition and _getDockedPosition

      // Special case: only in Step 2, animate first card (Exercise) into center
      if (index == 0 && _currentStep == OnboardingStep.exerciseCardInCenter) {
        final double centerCardValue = _centerCardController.value;
        final double centerX = (screenSize.width - cardSize.width) / 2;
        final double centerY = (screenSize.height - cardSize.height) / 2;

        final double currentX = lerpDouble(initial.dx, dockedPos['x']!, value)!;
        final double currentY = lerpDouble(initial.dy, dockedPos['y']!, value)!;
        final double currentRotation = lerpDouble(initialRotation, dockedPos['rotation']!, value)!;
        final double currentScale = lerpDouble(1.0, dockedPos['scale']!, value)!;

        final double x = lerpDouble(currentX, centerX, centerCardValue)!;
        final double y = lerpDouble(currentY, centerY, centerCardValue)!;
        final double rotation = lerpDouble(currentRotation, 0.0, centerCardValue)!;
        final double scale = lerpDouble(currentScale, 1.0, centerCardValue)!;

        return Positioned(
          left: x,
          top: y,
          child: SizedBox(
            width: cardSize.width,
            height: cardSize.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onCenterCardTap,
                  ),
                ),
                Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: SizedBox(
                      width: cardSize.width,
                      height: cardSize.height,
                      child: Center(
                        child: CircularHabitPreviewWidget(
                          habit: Habit(
                            id: 'onboarding_$index',
                            habitName: title,
                            emoji: emoji,
                            colorCode: accent.toARGB32(),
                            difficulty: HabitDifficulty.moderate,
                            dailyTarget: 1,
                            completions: _isCenterCardCompleted
                                ? {
                                    DateTime.now().toIso8601String(): CompletionEntry(
                                      id: DateTime.now().toIso8601String(),
                                      date: DateTime.now(),
                                      count: 1,
                                      isCompleted: true,
                                    ),
                                  }
                                : {},
                          ),
                          showName: false,
                          isCompleted: _isCenterCardCompleted,
                          onTap: _onCenterCardTap,
                          showCompleteButton: true,
                          enableCompleteButton: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Regular card animation for tablets
      final double x = lerpDouble(initial.dx, dockedPos['x']!, value)!;
      final double y = lerpDouble(initial.dy, dockedPos['y']!, value)!;
      final double rotation = lerpDouble(initialRotation, dockedPos['rotation']!, value)!;
      final double scale = lerpDouble(1.0, dockedPos['scale']!, value)!;

      return Positioned(
        left: x,
        top: y,
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: cardSize.width,
              height: cardSize.height,
              child: Center(
                child: CircularHabitPreviewWidget(
                  habit: Habit(
                    id: 'onboarding_$index',
                    habitName: title,
                    emoji: emoji,
                    colorCode: accent.toARGB32(),
                    difficulty: HabitDifficulty.moderate,
                    dailyTarget: 1,
                    completions: {},
                  ),
                  showName: false,
                  isCompleted: false,
                  showCompleteButton: true,
                  enableCompleteButton: false,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Phone and Tablet: Same card size and layout logic
    // Special case: only in Step 2, animate first card (Exercise) into center x
    if (index == 0 && _currentStep == OnboardingStep.exerciseCardInCenter) {
      final double centerCardValue = _centerCardController.value;
      // True center using the actual card size (no extra scaling)
      final double centerX = (screenSize.width - cardSize.width) / 2;
      final double centerY = (screenSize.height - cardSize.height) / 2;

      // Get the card's current stacked position (where it ended up after the cards animation)
      final double currentX = lerpDouble(initial.dx, dockedPos['x']!, value)!;
      final double currentY = lerpDouble(initial.dy, dockedPos['y']!, value)!;
      final double currentRotation = lerpDouble(initialRotation, dockedPos['rotation']!, value)!;
      final double currentScale = lerpDouble(1.0, dockedPos['scale']!, value)!;

      // Now interpolate from the current stacked position to center
      final double x = lerpDouble(currentX, centerX, centerCardValue)!;
      final double y = lerpDouble(currentY, centerY, centerCardValue)!;
      final double rotation = lerpDouble(currentRotation, 0.0, centerCardValue)!;
      // Animate scale back to natural 1.0 and remove rotation by the end
      final double scale = lerpDouble(currentScale, 1.0, centerCardValue)!;

      // Debug logging - only log at key points to avoid spam
      if (centerCardValue == 0.0 || centerCardValue == 1.0 || (centerCardValue * 10).round() % 2 == 0) {
        LogHelper.shared.debugPrint('Debug: Exercise card - centerCardValue: ${centerCardValue.toStringAsFixed(2)}, x: ${x.toStringAsFixed(1)} (from $currentX to $centerX)');
      }

      return Positioned(
        left: x,
        top: y,
        child: SizedBox(
          width: cardSize.width,
          height: cardSize.height,
          child: Stack(
            children: [
              // Full-surface tap catcher to guarantee reliability
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _onCenterCardTap,
                ),
              ),
              Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: cardSize.width,
                    height: cardSize.height,
                    child: Center(
                      child: CircularHabitPreviewWidget(
                        habit: Habit(
                          id: 'onboarding_$index',
                          habitName: title,
                          emoji: emoji,
                          colorCode: accent.toARGB32(),
                          difficulty: HabitDifficulty.moderate,
                          dailyTarget: 1,
                          completions: _isCenterCardCompleted
                              ? {
                                  DateTime.now().toIso8601String(): CompletionEntry(
                                    id: DateTime.now().toIso8601String(),
                                    date: DateTime.now(),
                                    count: 1,
                                    isCompleted: true,
                                  ),
                                }
                              : {},
                        ),
                        showName: false, // Hide habit name in onboarding
                        isCompleted: _isCenterCardCompleted,
                        onTap: _onCenterCardTap,
                        showCompleteButton: true, // Show complete button
                        enableCompleteButton: false, // But make it non-tappable
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Regular card animation for other cards
    final double x = lerpDouble(initial.dx, dockedPos['x']!, value)!;
    final double y = lerpDouble(initial.dy, dockedPos['y']!, value)!;
    final double rotation = lerpDouble(initialRotation, dockedPos['rotation']!, value)!;
    final double scale = lerpDouble(1.0, dockedPos['scale']!, value)!;

    return Positioned(
      left: x,
      top: y,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: SizedBox(
            width: cardSize.width,
            height: cardSize.height,
            child: Center(
              child: CircularHabitPreviewWidget(
                habit: Habit(
                  id: 'onboarding_$index',
                  habitName: title,
                  emoji: emoji,
                  colorCode: accent.toARGB32(),
                  difficulty: HabitDifficulty.moderate,
                  dailyTarget: 1,
                ),
                showName: false, // Hide habit name in onboarding
                isCompleted: false,
                showCompleteButton: true, // Show complete button
                enableCompleteButton: false, // But make it non-tappable
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomCtaButton extends StatelessWidget {
  const _BottomCtaButton({
    required this.arrowOffsetX,
    required this.onPressed,
    this.label,
  });

  final Animation<double> arrowOffsetX;
  final VoidCallback? onPressed;

  /// Optional text label — when set, the button expands and shows text + glow.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLabel = label != null;

    // When a label is shown (aha-moment CTA), use a wider pill with gradient
    final double buttonHeight = context.height(0.062);
    final double buttonWidth = hasLabel ? context.width(0.65) : context.width(0.35);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(360),
        child: CustomBlurWidget(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: buttonHeight,
              width: buttonWidth,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(360),
                gradient: hasLabel
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.75),
                        ],
                      )
                    : null,
                color: hasLabel ? null : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                border: Border.all(
                  color: hasLabel ? theme.colorScheme.primary.withValues(alpha: 0.0) : theme.colorScheme.onSurface.withValues(alpha: 0.16),
                ),
                boxShadow: hasLabel
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.45),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: hasLabel
                  ? Text(
                      label!,
                      style: context.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : AnimatedBuilder(
                      animation: arrowOffsetX,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(arrowOffsetX.value, 0),
                          child: child,
                        );
                      },
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: context.isTablet ? 26 : 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
                      ),
                    ),
            ),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 350)),
      ),
    );
  }
}
