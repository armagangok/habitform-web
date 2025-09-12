import 'dart:math';
import 'dart:ui';

import 'package:confetti/confetti.dart';

import '../../../core/core.dart';
import '../../../models/habit/habit_model.dart';
import '../../home/components/achievement_dialog.dart';
import '../enum/onboarding_step_enum.dart';

/// Onboarding - Welcome page
///
/// Layout
/// - Top: "Welcome to" text
/// - Center: App logo
/// - Below logo: App name text (HabitRise)
/// - Bottom: CTA button with a gently oscillating arrow icon
class OnboardingWelcomePage extends StatefulWidget {
  const OnboardingWelcomePage({super.key, this.onContinue});

  final VoidCallback? onContinue;

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
    final isDark = theme.brightness == Brightness.dark;

    // Use transparent logo variants if available, falling back to regular app logos
    final String logoAsset = isDark ? 'assets/app/habitrise_dark_transparent.png' : 'assets/app/habitrise_light_transparent.png';

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.surface,
      child: Stack(
        children: [
          // A very soft radial vignette for depth/atmosphere
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.0,
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.05),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          // Habit demo cards layer
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                return AnimatedBuilder(
                  animation: Listenable.merge([_cardsAnim, _centerCardController]),
                  builder: (context, _) {
                    return Stack(children: [
                      _buildCard(
                        context,
                        index: 0,
                        screenSize: size,
                        color: const Color(0xFF0E291E),
                        accent: const Color(0xFF1DB954),
                        emoji: '🏃',
                        title: 'Running',
                        badgeValue: 12,
                        initial: Offset(-context.width(0.025), context.height(0.09)), // top-left with responsive positioning
                        initialRotation: -0.30,
                        isLeftSide: true,
                        tier: 1, // dock lower-left when stacked
                      ),
                      _buildCard(
                        context,
                        index: 1,
                        screenSize: size,
                        color: const Color(0xFF0C2B57),
                        accent: const Color(0xFF0C6CF2),
                        emoji: '📚',
                        title: 'Read Book',
                        badgeValue: 21,
                        initial: Offset(size.width - context.width(0.5) + context.width(0.1), context.height(0.1)), // top-right with responsive positioning
                        initialRotation: 0.4,
                        isLeftSide: false,
                        tier: 0,
                      ),
                      _buildCard(
                        context,
                        index: 2,
                        screenSize: size,
                        color: const Color(0xFF2A1547),
                        accent: const Color(0xFF9B59B6),
                        emoji: '🧘‍♂️',
                        title: 'Meditate',
                        badgeValue: 8,
                        initial: Offset(-context.width(0.025), size.height - context.height(0.4)), // bottom-left with responsive positioning
                        initialRotation: -0.2,
                        isLeftSide: true,
                        tier: 0, // dock upper-left when stacked
                      ),
                      _buildCard(
                        context,
                        index: 3,
                        screenSize: size,
                        color: const Color(0xFF0B2F35),
                        accent: const Color(0xFF2EC7E6),
                        emoji: '💧',
                        title: 'Drink Water',
                        badgeValue: 30,
                        initial: Offset(size.width - context.width(0.5) + context.width(0.012), size.height - context.height(0.4)), // bottom-right with responsive positioning
                        initialRotation: 0.2,
                        isLeftSide: false,
                        tier: 1,
                      ),
                    ]);
                  },
                );
              },
            ),
          ),
          // Confetti overlay (optimized)
          Align(
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
          // Content
          SafeArea(
            child: Padding(
              padding: context.symmetricPadding(horizontal: 0.06), // Responsive horizontal padding
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
                            // Welcome block fades out in place
                            Opacity(
                              opacity: 1.0 - progress,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Welcome to',
                                    style: context.headlineSmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CupertinoCard(
                                        color: CupertinoColors.black,
                                        padding: context.padding(0.04), // Responsive padding
                                        child: Image.asset(logoAsset, height: context.height(0.1), fit: BoxFit.contain), // Responsive logo size
                                      ),
                                      SizedBox(height: context.height(0.006)), // Responsive spacing
                                      Text(
                                        'HabitRise',
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
                            // Tagline fades in, then fades out when center card appears
                            // Never show tagline if final message is shown, if we're in completed state, or if motivational message is showing
                            if (_currentStep == OnboardingStep.cardsStackedAtBottom)
                              AnimatedOpacity(
                                opacity: (((progress > 0.02 || _showTagline) && !(_currentStep == OnboardingStep.exerciseCardInCenter && centerProgress > 0.7)) ? (_currentStep == OnboardingStep.exerciseCardInCenter ? (centerProgress > 0.7 ? 0.0 : progress * (1.0 - centerProgress.clamp(0.0, 0.7))) : progress) : 0.0),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                child: Padding(
                                  padding: context.symmetricPadding(horizontal: 0.025), // Responsive horizontal padding
                                  child: SizedBox(
                                    width: context.width(0.9),
                                    child: Text(
                                      'Build your dream life',
                                      style: context.headlineLarge.copyWith(
                                        fontSize: context.width(0.08), // 8% of screen width
                                        height: 1.1,
                                      ),
                                      textAlign: TextAlign.center,
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
                      bottom: context.height(0.022), // Responsive spacing from bottom
                      left: 0,
                      right: 0,
                      child: _BottomCtaButton(
                        arrowOffsetX: _arrowOffsetX,
                        onPressed: _isButtonDisabled ? null : _onCtaPressed,
                      ),
                    ),
                  // Center-step instruction (below the card area)
                  if (_currentStep == OnboardingStep.exerciseCardInCenter && !_isCenterCardCompleted)
                    Positioned(
                      top: context.dynamicHeight / 2 + context.height(0.12), // Position below the center card (card height/2 + 15 padding)
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: _isCenterCardReady ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 350),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.hand_point_right_fill, size: context.width(0.07), color: theme.colorScheme.primary), // Responsive icon size
                            SizedBox(height: context.height(0.01)), // Responsive spacing
                            Text(
                              'Try tapping on the habit card',
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
                      top: MediaQuery.of(context).size.height / 2 - context.height(0.25), // Position well above the center card
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        opacity: _showMotivationalMessage ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        child: Text(
                          'Just like that!',
                          style: context.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: context.width(0.06), // Responsive font size
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
                            child: Text(
                              'Change your life one habit at a time.',
                              style: context.headlineLarge.copyWith(
                                fontSize: context.width(0.08),
                                height: 1.1,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Congratulations messages below the card
                  if (_showMotivationalMessage)
                    Positioned(
                      top: (MediaQuery.of(context).size.height + context.width(0.5)) / 2, // Position below the center card (card bottom + padding)
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
                              'Congratulations!',
                              style: context.headlineSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1DB954),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.height(0.01)), // Responsive spacing
                            Text(
                              'You\'ve completed your first habit!',
                              style: context.titleMedium.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.height(0.005)), // Responsive spacing
                            Text(
                              'Every journey begins with a single step.',
                              style: context.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
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
          ),
        ],
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

    print('Debug: Button pressed, current step: ${_currentStep.name}');
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
        print('Debug: Starting center card animation');
        try {
          // Ensure center animation starts from 0 for a smooth transition
          _centerCardController.stop();
          _centerCardController.value = 0.0;
          setState(() {
            _currentStep = OnboardingStep.exerciseCardInCenter;
            _isCenterCardReady = true; // Enable card interaction immediately
          });
          await _centerCardController.forward();
          print('Debug: Center card animation completed');
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
          print('Debug: Card not completed or message not shown yet, current step: ${_currentStep.name}');
          setState(() {
            _isTransitioning = false;
            _isButtonDisabled = false;
          });
        }
        break;

      case OnboardingStep.completed:
        // Final step - handle final CTA button press
        if (_showFinalCta) {
          // Navigate to information page
          if (mounted) {
            Navigator.of(context).pushNamed('/onboardingInformation');
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

  Path _drawStar(Size size) {
    // draws a star
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step), halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep), halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  void _onCenterCardTap() async {
    if (_isCenterCardCompleted || !_isCenterCardReady) return;

    print('Debug: Center card tapped!');
    setState(() {
      _isCenterCardCompleted = true;
    });
    _runningStreak++; // Increment streak

    // Start confetti animation
    _confettiController.play();

    // Create a mock habit for the achievement dialog
    final mockHabit = Habit(
      id: 'onboarding_running',
      habitName: 'Running',
      emoji: '🏃',
      colorCode: 0xFF1DB954,
      completions: {},
    );

    // Show achievement dialog after a short delay
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AchievementDialog(
          habit: mockHabit,
          pointsGained: 10,
          previousScore: _runningStreak - 1,
          newScore: _runningStreak,
          message: 'Great job! You completed your first habit in the onboarding!',
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

  // Responsive docked positions for each card
  Map<String, double> _getDockedPosition(int index, Size screenSize, BuildContext context) {
    final double cardWidth = context.width(0.5);

    switch (index) {
      case 0: // Running card (left side, lower tier)
        return {
          'x': -context.width(0.025), // Left side with responsive margin
          'y': screenSize.height - context.height(0.21), // Bottom area
          'rotation': 0.5, // Slight left rotation
          'scale': 0.9, // Slightly smaller
        };
      case 1: // Read Book card (right side, upper tier)
        return {
          'x': screenSize.width - cardWidth - context.width(0.045), // Right side with responsive margin
          'y': screenSize.height - context.height(0.22), // Bottom area, slightly higher
          'rotation': -0.35, // Slight right rotation
          'scale': 0.92, // Slightly smaller
        };
      case 2: // Meditate card (left side, upper tier)
        return {
          'x': -context.width(0.025), // Left side with responsive margin
          'y': screenSize.height - context.height(0.1), // Bottom area, higher than running
          'rotation': 0.15, // Very slight left rotation
          'scale': 0.88, // Smaller
        };
      case 3: // Drink Water card (right side, lower tier)
        return {
          'x': screenSize.width - cardWidth - context.width(0.05), // Right side with responsive margin
          'y': screenSize.height - context.height(0.1), // Bottom area, lower than read book
          'rotation': -0.15, // Very slight right rotation
          'scale': 0.85, // Smallest
        };
      default:
        return {
          'x': 0.0,
          'y': 0.0,
          'rotation': 0.0,
          'scale': 1.0,
        };
    }
  }

  Widget _buildCard(
    BuildContext context, {
    required int index,
    required Size screenSize,
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
    // Responsive card size based on screen width (maintains aspect ratio)
    final double cardWidth = context.width(0.5); // 50% of screen width
    final double cardHeight = cardWidth; // Square aspect ratio
    final Size cardSize = Size(cardWidth, cardHeight);

    // Get responsive docked position for this card
    final dockedPos = _getDockedPosition(index, screenSize, context);

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
        print('Debug: Exercise card - centerCardValue: ${centerCardValue.toStringAsFixed(2)}, x: ${x.toStringAsFixed(1)} (from $currentX to $centerX)');
      }

      return Positioned(
        left: x,
        top: y,
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: _HabitCard(
              size: cardSize,
              background: color,
              accent: accent,
              emoji: emoji,
              title: title,
              badgeValue: _runningStreak, // Use dynamic streak value
              isCompleted: _isCenterCardCompleted,
              onTap: _onCenterCardTap, // Pass onTap to card
            ),
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
          child: _HabitCard(
            size: cardSize,
            background: color,
            accent: accent,
            emoji: emoji,
            title: title,
            badgeValue: badgeValue,
            isCompleted: false,
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
  });

  final Animation<double> arrowOffsetX;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Responsive button sizing
    final double buttonHeight = context.height(0.062); // 6.2% of screen height
    final double buttonWidth = context.width(0.35); // 35% of screen width
    final double borderRadius = context.width(0.07); // 7% of screen width
    final double iconSize = context.width(0.085); // 8.5% of screen width

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Material(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              child: Container(
                height: buttonHeight,
                width: buttonWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.16),
                  ),
                ),
                child: AnimatedBuilder(
                  animation: arrowOffsetX,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(arrowOffsetX.value, 0),
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: iconSize,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.size,
    required this.background,
    required this.accent,
    required this.emoji,
    required this.title,
    required this.badgeValue,
    this.isCompleted = false,
    this.onTap,
  });

  final Size size;
  final Color background;
  final Color accent;
  final String emoji;
  final String title;
  final int badgeValue;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color habitColor = accent;

    // Responsive sizing for card elements
    final double emojiSize = context.width(0.15); // 35% of card width
    final double iconSize = context.width(0.05); // 14% of card width
    final double completionIconSize = context.width(0.14); // 14% of card width
    final double borderRadius = context.width(0.08); // 10% of card width
    final double borderWidth = context.width(0.01); // 1% of card width

    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomBlurWidget(
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: habitColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: habitColor.withValues(alpha: 0.35), width: borderWidth),
            ),
            child: Padding(
              padding: context.padding(0.03), // 8% of screen width as padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top row: emoji + streak
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: emojiSize,
                        height: emojiSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: habitColor.withValues(alpha: 0.12),
                          border: Border.all(color: habitColor.withValues(alpha: 0.25)),
                        ),
                        child: Center(child: Text(emoji, style: TextStyle(fontSize: emojiSize * 0.5))),
                      ),
                      Container(
                        padding: context.symmetricPadding(horizontal: 0.02, vertical: 0.01), // Responsive padding
                        decoration: BoxDecoration(
                          color: habitColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(context.width(0.12)), // 12% of card width
                          border: Border.all(color: habitColor.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.flame_fill, size: iconSize, color: habitColor),
                            SizedBox(width: context.width(0.03)), // 3% of screen width
                            Text('$badgeValue', style: context.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: habitColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Bottom row: name + completion icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: null,
                          style: context.titleLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          isCompleted ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                          key: ValueKey<bool>(isCompleted),
                          color: habitColor,
                          size: completionIconSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
