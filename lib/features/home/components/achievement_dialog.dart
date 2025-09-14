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
                        child: SizedBox(
                          width: context.width(0.8),
                          child: Padding(
                            padding: context.padding(0.04),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Achievement Emoji with premium effects
                                  _buildAnimatedEmoji(context, habitColor),
                                  SizedBox(height: context.height(0.015)),

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
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle with gradient
        Container(
          width: context.width(0.4),
          height: context.width(0.4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                scoreColor.withValues(alpha: 0.1),
                scoreColor.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Outer ring (background)
        CustomPaint(
          size: Size(context.width(0.4), context.width(0.4)),
          painter: _CircularProgressPainter(
            progress: 1.0,
            strokeWidth: 8,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            startAngle: -90,
          ),
        ),

        // Progress ring with gradient
        CustomPaint(
          size: Size(context.width(0.4), context.width(0.4)),
          painter: _CircularProgressPainter(
            progress: progress,
            strokeWidth: 8,
            color: scoreColor,
            startAngle: -90,
            isGradient: true,
            gradientColors: _getProgressiveColors(progress),
          ),
        ),

        // Inner glow effect
        Container(
          width: context.width(0.35),
          height: context.width(0.35),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                scoreColor.withValues(alpha: 0.15),
                scoreColor.withValues(alpha: 0.05),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Center content
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated percentage
            AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return Text(
                  '${animatedScore.round()}',
                  style: context.displaySmall.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scoreColor,
                    fontFeatures: [
                      FontFeature.tabularFigures(),
                    ],
                    shadows: [
                      Shadow(
                        color: scoreColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: context.height(0.005)),

            // Formation status
            Text(
              _getFormationStatus(progress),
              style: context.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        // Floating particles around the circle
        ...List.generate(8, (index) {
          final angle = (index * 45.0) * (pi / 180);
          final radius = context.width(0.2);
          final x = cos(angle) * radius;
          final y = sin(angle) * radius;

          return Positioned(
            left: context.width(0.2) + x - 2,
            top: context.width(0.2) + y - 2,
            child: AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                final particleProgress = (_particleAnimation.value + index * 0.1) % 1.0;
                return Opacity(
                  opacity: (1 - particleProgress) * 0.6,
                  child: Transform.scale(
                    scale: 0.5 + particleProgress * 0.5,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scoreColor.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: scoreColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  List<Color> _getProgressiveColors(double progress) {
    if (progress >= 0.9) {
      return [
        const Color(0xFF4CAF50),
        const Color(0xFF8BC34A),
        const Color(0xFFCDDC39),
      ];
    } else if (progress >= 0.7) {
      return [
        const Color(0xFF8BC34A),
        const Color(0xFFCDDC39),
        const Color(0xFFFFC107),
      ];
    } else if (progress >= 0.5) {
      return [
        const Color(0xFFFFC107),
        const Color(0xFFFF9800),
        const Color(0xFFFF5722),
      ];
    } else {
      return [
        const Color(0xFFFF5722),
        const Color(0xFFF44336),
        const Color(0xFFE91E63),
      ];
    }
  }

  String _getFormationStatus(double progress) {
    if (progress >= 0.9) return 'Excellent!';
    if (progress >= 0.7) return 'Great!';
    if (progress >= 0.5) return 'Good';
    return 'Keep Going';
  }

  Widget _buildProgressSection(BuildContext context, ThemeData theme, Color habitColor) {
    return Container(
      padding: context.padding(0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.width(0.06)),
        border: Border.all(
          color: habitColor.withValues(alpha: 0.25),
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

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final double startAngle;
  final bool isGradient;
  final List<Color>? gradientColors;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.startAngle,
    this.isGradient = false,
    this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (isGradient && gradientColors != null && gradientColors!.length >= 2) {
      // Create gradient shader
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        colors: gradientColors!,
        startAngle: startAngle * (pi / 180),
        endAngle: (startAngle + 360 * progress) * (pi / 180),
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        rect,
        startAngle * (pi / 180),
        sweepAngle,
        false,
        paint,
      );
    } else {
      // Solid color
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * pi * progress;

      canvas.drawArc(
        rect,
        startAngle * (pi / 180),
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _CircularProgressPainter && (oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth);
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
