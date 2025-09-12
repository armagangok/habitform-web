import 'dart:math';
import 'dart:ui';

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

    _scaleController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scoreController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);
    _particleController = AnimationController(duration: const Duration(milliseconds: 3000), vsync: this);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.newScore.toDouble()).animate(
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

    // Start animations with staggered timing
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _pulseController.repeat(reverse: true);
        _particleController.forward();
        _confettiController.play();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
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
    final habitColor = _getFormationScoreColor(widget.newScore.toDouble());

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Confetti overlay
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
          // Main dialog
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _slideAnimation, _scaleAnimation]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Center(
                        child: Container(
                          width: context.width(0.85),
                          constraints: BoxConstraints(
                            maxWidth: 400,
                            maxHeight: context.height(0.8),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.colorScheme.surface.withValues(alpha: 0.95),
                                theme.colorScheme.surface.withValues(alpha: 0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(context.width(0.08)),
                            border: Border.all(
                              color: habitColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: habitColor.withValues(alpha: 0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(context.width(0.08)),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: context.padding(0.06),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Achievement Icon with premium effects
                                      _buildPremiumIcon(context, habitColor),
                                      SizedBox(height: context.height(0.03)),

                                      // Habit name
                                      Text(
                                        widget.habit.habitName,
                                        style: context.headlineMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: context.height(0.01)),

                                      // Achievement title
                                      Text(
                                        widget.pointsGained > 0 ? 'Amazing Progress! 🎉' : 'Keep Going! 💪',
                                        style: context.titleLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: habitColor,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: context.height(0.03)),

                                      // Score display with premium styling
                                      _buildScoreDisplay(context, theme, habitColor),
                                      SizedBox(height: context.height(0.03)),

                                      // Progress section
                                      _buildProgressSection(context, theme, habitColor),
                                      SizedBox(height: context.height(0.03)),

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
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumIcon(BuildContext context, Color habitColor) {
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
              // Main icon container
              Container(
                width: context.width(0.25),
                height: context.width(0.25),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      habitColor.withValues(alpha: 0.2),
                      habitColor.withValues(alpha: 0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: habitColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
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

  Widget _buildProgressSection(BuildContext context, ThemeData theme, Color habitColor) {
    return Container(
      padding: context.padding(0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.5),
            theme.colorScheme.surface.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(context.width(0.06)),
        border: Border.all(
          color: habitColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getFormationProgressTitle(),
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: habitColor,
                  ),
                ),
              ),
              Text(
                _getFormationDaysText(),
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: context.height(0.015)),
          // Premium progress bar
          Container(
            height: context.height(0.008),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.height(0.004)),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth * _getFormationProgressByCompletions(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(context.height(0.004)),
                        gradient: LinearGradient(
                          colors: [habitColor, habitColor.withValues(alpha: 0.7)],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: context.height(0.015)),
          Text(
            _getFormationMessage(widget.newScore),
            style: context.bodySmall.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumButton(BuildContext context, ThemeData theme, Color habitColor) {
    return Container(
      width: double.infinity,
      height: context.height(0.06),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.width(0.08)),
        gradient: LinearGradient(
          colors: [habitColor, habitColor.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: habitColor.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CupertinoButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
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

  // Progress ratio based on completions
  double _getFormationProgressByCompletions() {
    return widget.habit.completions.calculateFormationProgress(_totalFormationDays);
  }

  String _getFormationProgressTitle() {
    final remainingDays = _getRemainingDaysByCompletions();

    if (remainingDays == 0) {
      return 'Habit Fully Formed! 🎉';
    } else if (remainingDays <= 7) {
      return 'Almost There! 🔥';
    } else if (remainingDays <= 14) {
      return 'Strong Progress! 💪';
    } else {
      return 'Building Momentum! 🚀';
    }
  }

  String _getFormationDaysText() {
    final remainingDays = _getRemainingDaysByCompletions();
    final totalDays = _totalFormationDays;

    if (remainingDays == 0) {
      return 'Complete!';
    } else if (remainingDays == 1) {
      return '1 day left';
    } else if (remainingDays <= 7) {
      return '$remainingDays days left';
    } else {
      return '$remainingDays of $totalDays days';
    }
  }

  String _getFormationMessage(int score) {
    final remainingDays = _getRemainingDaysByCompletions();
    final totalDays = _totalFormationDays;
    final difficulty = widget.habit.difficulty;
    final difficultyName = difficulty.displayName;

    if (score >= 90) {
      if (remainingDays == 0) {
        return 'Excellent! Your habit is fully formed. Keep maintaining this consistency! 🎉';
      } else {
        return 'Excellent! Just $remainingDays more days until your habit is fully formed! 🎉';
      }
    } else if (score >= 70) {
      return 'Great progress! You\'re building a strong habit foundation. $remainingDays days left! 💪';
    } else if (score >= 50) {
      return 'Good work! This $difficultyName habit takes $totalDays days to form. $remainingDays days remaining! 📈';
    } else {
      return 'Keep going! This $difficultyName habit needs more consistency. $remainingDays days to go! 🌱';
    }
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
