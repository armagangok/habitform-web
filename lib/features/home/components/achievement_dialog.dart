import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';

import '../../../core/core.dart';
import '../../../models/completion_entry/completion_extension.dart';
import '../../../models/habit/habit_difficulty.dart';
import '../../../models/habit/habit_model.dart';

class AchievementDialog extends StatefulWidget {
  const AchievementDialog({
    super.key,
    required this.habit,
    required this.pointsGained,
    required this.previousScore,
    required this.newScore,
    required this.message,
  });

  final Habit habit;
  final int pointsGained;
  final int previousScore;
  final int newScore;
  final String message;

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _scoreController;
  late AnimationController _particleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late ConfettiController _confettiController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int _lastNotifiedScore = 0;

  @override
  void initState() {
    super.initState();

    // Haptic feedback for achievement
    HapticFeedback.lightImpact();

    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scoreController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    _particleController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Calculate formation probability for animation
    final formationProbability = _calculateFormationProbability();
    _scoreAnimation = Tween<double>(begin: 0.0, end: formationProbability).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _lastNotifiedScore = 0;
    _scoreController.addListener(() {
      final current = _scoreAnimation.value.round();
      if (current > _lastNotifiedScore) {
        HapticFeedback.selectionClick();
        _lastNotifiedScore = current;
      }
    });

    // Start animations with staggered timing for smooth appearance
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
        _particleController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _confettiController.play();
      }
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _scoreController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _scoreController.dispose();
    _particleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitColor = Color(widget.habit.colorCode);

    return CustomBlurWidget(
      child: Stack(
        children: [
          // Main dialog with liquid glass effect
          AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _slideAnimation, _scaleAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Center(
                      child: CupertinoPopupSurface(
                        child: ColoredBox(
                          color: habitColor.withValues(alpha: 0.075),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: context.height(0.85),
                              maxWidth: context.width(0.9),
                            ),
                            child: Padding(
                              padding: context.padding(0.04),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Achievement Emoji with premium effects
                                    _buildAnimatedEmoji(context, habitColor),
                                    SizedBox(height: context.height(0.02)),

                                    // Habit name
                                    Text(
                                      widget.habit.habitName,
                                      style: context.headlineMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    // Achievement title
                                    Text(
                                      widget.pointsGained > 0 ? LocaleKeys.achievement_dialog_amazing_progress.tr() : LocaleKeys.achievement_dialog_keep_going.tr(),
                                      style: context.titleLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: habitColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: context.height(0.02)),

                                    // Score display with premium styling
                                    _buildScoreDisplay(context, theme, habitColor),
                                    SizedBox(height: context.height(0.02)),

                                    // Progress section
                                    _buildProgressSection(context, theme, habitColor),
                                    SizedBox(height: context.height(0.02)),

                                    // Continue button with premium styling
                                    _buildPremiumButton(context, theme, habitColor),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Confetti overlay - positioned on top of dialog content
          Align(
            alignment: const Alignment(0, -0.3),
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              minBlastForce: 10,
              maxBlastForce: 25,
              gravity: 0.3,
              particleDrag: 0.1,
              shouldLoop: false,
              colors: [
                habitColor,
                habitColor.withValues(alpha: 0.8),
                habitColor.withValues(alpha: 0.6),
                const Color(0xFFFFD700),
                const Color(0xFFFF6B6B),
                const Color(0xFF4ECDC4),
              ],
              createParticlePath: _drawStar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedEmoji(BuildContext context, Color habitColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _particleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Floating particles
              AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(context.width(0.3), context.width(0.3)),
                    painter: _ParticlePainter(
                      progress: _particleAnimation.value,
                      color: habitColor,
                    ),
                  );
                },
              ),
              // Main icon container with liquid glass effect
              Container(
                width: context.width(0.25),
                height: context.width(0.25),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      habitColor.withValues(alpha: 0.15),
                      habitColor.withValues(alpha: 0.08),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: habitColor.withValues(alpha: 0.25),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.habit.emoji ?? '✨',
                    style: TextStyle(fontSize: context.width(0.12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreDisplay(BuildContext context, ThemeData theme, Color habitColor) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final animatedScore = _scoreAnimation.value;
        final progress = animatedScore / 100.0;
        final scoreColor = _getFormationScoreColor(animatedScore);

        return _buildAdvancedCircularProgress(context, progress, animatedScore, scoreColor, theme);
      },
    );
  }

  Widget _buildAdvancedCircularProgress(
    BuildContext context,
    double progress,
    double animatedScore,
    Color scoreColor,
    ThemeData theme,
  ) {
    return Container(
      width: context.width(0.3),
      height: context.width(0.3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            scoreColor.withValues(alpha: 0.15),
            scoreColor.withValues(alpha: 0.08),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.2),
            blurRadius: 50,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large animated score
            AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return Text(
                  '${animatedScore.round()}',
                  style: context.displayLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                    fontSize: 42,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                    shadows: [
                      Shadow(
                        color: scoreColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Formation status
            Text(
              _getFormationStatus(progress),
              style: context.titleMedium.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: context.width(0.04),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getFormationStatus(double progress) {
    if (progress >= 0.9) return LocaleKeys.achievement_dialog_excellent.tr();
    if (progress >= 0.7) return LocaleKeys.achievement_dialog_great.tr();
    if (progress >= 0.5) return LocaleKeys.achievement_dialog_good.tr();
    return LocaleKeys.achievement_dialog_keep_going_status.tr();
  }

  Widget _buildProgressSection(BuildContext context, ThemeData theme, Color habitColor) {
    final remainingDays = _getRemainingDaysByCompletions();
    final totalDays = _totalFormationDays;

    return CupertinoCard(
      color: habitColor.withValues(alpha: 0.05),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.width(0.04),
          vertical: context.height(0.012),
        ),
        decoration: const BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and progress indicator
            Row(
              mainAxisAlignment: remainingDays == 0 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _getFormationProgressTitle(),
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: habitColor,
                    ),
                    textAlign: remainingDays == 0 ? TextAlign.center : TextAlign.start,
                  ),
                ),
                if (remainingDays > 0) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.width(0.03),
                      vertical: context.height(0.008),
                    ),
                    decoration: BoxDecoration(
                      color: habitColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(context.width(0.02)),
                    ),
                    child: Text(
                      _getFormationDaysText(),
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: habitColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: context.height(0.02)),

            // Show special message for fully formed habits
            if (remainingDays == 0) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.width(0.04),
                  vertical: context.height(0.012),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4CAF50).withValues(alpha: 0.15),
                      const Color(0xFF4CAF50).withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Text(
                  '${LocaleKeys.achievement_dialog_congratulations_fully_formed.tr()} ${LocaleKeys.achievement_dialog_formation_takes_days.tr(namedArgs: {'total': totalDays.toString()})}',
                  style: context.bodyMedium.copyWith(
                    color: const Color(0xFF4CAF50),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: context.height(0.015)),
            ],

            // Clear formation message - only show if habit is not fully formed
            if (remainingDays > 0) ...[
              Column(
                children: [
                  Text(
                    _getFormationMessage(widget.newScore),
                    style: context.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.height(0.01)),
                  Text(
                    LocaleKeys.achievement_dialog_formation_takes_days.tr(namedArgs: {'total': totalDays.toString()}),
                    style: context.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumButton(BuildContext context, ThemeData theme, Color habitColor) {
    return CupertinoButton(
      color: habitColor,
      borderRadius: BorderRadius.circular(90),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            LocaleKeys.achievement_dialog_continue.tr(),
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
    );
  }

  Path _drawStar(Size size) {
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

  Color _getFormationScoreColor(double score) {
    if (score >= 90) return const Color(0xFF4CAF50); // Green - Excellent
    if (score >= 70) return const Color(0xFF8BC34A); // Light Green - Good
    if (score >= 50) return const Color(0xFFFFC107); // Amber - Moderate
    return const Color(0xFFF44336); // Red - Insufficient
  }

  // Calculate total formation days needed for this habit
  int get _totalFormationDays => widget.habit.difficulty.estimatedFormationDays;

  // Count completed unique days for the habit

  // Remaining days to reach formation based on completions
  int _getRemainingDaysByCompletions() {
    return widget.habit.completions.getRemainingFormationDays(_totalFormationDays);
  }

  String _getFormationProgressTitle() {
    final remainingDays = _getRemainingDaysByCompletions();

    if (remainingDays == 0) {
      return LocaleKeys.achievement_dialog_habit_fully_formed.tr();
    } else if (remainingDays <= 7) {
      return LocaleKeys.achievement_dialog_almost_there.tr();
    } else if (remainingDays <= 14) {
      return LocaleKeys.achievement_dialog_strong_progress.tr();
    } else {
      return LocaleKeys.achievement_dialog_building_momentum.tr();
    }
  }

  String _getFormationDaysText() {
    final remainingDays = _getRemainingDaysByCompletions();
    final totalDays = _totalFormationDays;

    if (remainingDays == 0) {
      return LocaleKeys.achievement_dialog_complete.tr();
    } else if (remainingDays == 1) {
      return LocaleKeys.achievement_dialog_day_left.tr();
    } else if (remainingDays <= 7) {
      return LocaleKeys.achievement_dialog_days_left.tr(namedArgs: {'days': remainingDays.toString()});
    } else {
      return LocaleKeys.achievement_dialog_days_of_total.tr(namedArgs: {
        'remaining': remainingDays.toString(),
        'total': totalDays.toString(),
      });
    }
  }

  String _getFormationMessage(int score) {
    final remainingDays = _getRemainingDaysByCompletions();
    final totalDays = _totalFormationDays;
    final difficulty = widget.habit.difficulty;
    final difficultyName = difficulty.displayName;

    if (score >= 90) {
      if (remainingDays == 0) {
        return LocaleKeys.achievement_dialog_congratulations_fully_formed.tr();
      } else {
        return LocaleKeys.achievement_dialog_outstanding_progress.tr(namedArgs: {'days': remainingDays.toString()});
      }
    } else if (score >= 70) {
      if (remainingDays == 0) {
        return LocaleKeys.achievement_dialog_congratulations_fully_formed.tr();
      } else {
        return LocaleKeys.achievement_dialog_great_progress.tr(namedArgs: {'days': remainingDays.toString()});
      }
    } else if (score >= 50) {
      return LocaleKeys.achievement_dialog_good_work.tr(namedArgs: {
        'difficulty': difficultyName,
        'total': totalDays.toString(),
        'remaining': remainingDays.toString(),
      });
    } else {
      return LocaleKeys.achievement_dialog_keep_going_message.tr(namedArgs: {
        'difficulty': difficultyName,
        'remaining': remainingDays.toString(),
      });
    }
  }

  /// Calculate formation probability using the same logic as Habit Detail and Formation pages
  double _calculateFormationProbability() {
    if (widget.habit.completions.isEmpty) return 0.0;

    // Use a dummy date since the method now uses first completion date internally
    final dummyDate = DateTime.now();

    return widget.habit.completions.calculateFormationProbability(
      dummyDate, // This parameter is now ignored, but kept for compatibility
      widget.habit.difficulty.estimatedFormationDays,
      widget.habit.difficulty.minimumCompletionRate,
      widget.habit.dailyTarget,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15 * progress)
      ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent animation

    for (int i = 0; i < 12; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (random.nextDouble() * 4 + 2) * progress;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
