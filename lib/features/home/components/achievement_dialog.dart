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

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _ringRotationController;
  late ConfettiController _confettiController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _ringRotationAnimation;

  int _lastNotifiedScore = 0;

  @override
  void initState() {
    super.initState();

    // Haptic feedback for achievement
    HapticFeedback.lightImpact();

    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scoreController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);

    _fadeController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _ringRotationController = AnimationController(duration: const Duration(milliseconds: 6000), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Calculate formation probability for animation
    final formationProbability = _calculateFormationProbability();
    _scoreAnimation = Tween<double>(begin: 0.0, end: formationProbability).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _ringRotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _ringRotationController, curve: Curves.linear),
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

    // Subtle breathing/pulse for glow effects
    _pulseController.repeat(reverse: true);
    _ringRotationController.repeat();

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
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _ringRotationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        LocaleKeys.achievement_dialog_habit_probability.tr(),
                                        style: context.titleMedium.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: context.height(0.01)),

                                  _buildAnimatedEmoji(context, habitColor),

                                  SizedBox(height: context.height(0.01)),

                                  // Score display with premium styling
                                  _buildScoreDisplay(context, cupertinoTheme, habitColor),
                                  SizedBox(height: context.height(0.01)),

                                  // Progress section
                                  _buildProgressSection(context, cupertinoTheme, habitColor),
                                  SizedBox(height: context.height(0.02)),

                                  // Continue button with premium styling
                                  _buildPremiumButton(context, habitColor),
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
              numberOfParticles: 15,
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
                const Color.fromARGB(255, 112, 205, 78),
              ],
              createParticlePath: _drawStar,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedEmoji(BuildContext context, Color habitColor) {
    final size = context.width(0.28);
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseAnimation,
      ]),
      builder: (context, child) {
        final glowScale = _pulseAnimation.value;
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Soft outer glow
              Transform.scale(
                scale: glowScale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: habitColor.withValues(alpha: 0.30),
                        blurRadius: 35,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              // Gradient ring with subtle sheen
              AnimatedBuilder(
                animation: _ringRotationAnimation,
                builder: (context, _) {
                  return CustomPaint(
                    isComplex: true,
                    willChange: true,
                    size: Size.square(size),
                    painter: _GradientRingPainter(
                      baseColor: habitColor,
                      glowFactor: (_pulseAnimation.value - 1.0).abs(),
                      rotation: _ringRotationAnimation.value,
                    ),
                  );
                },
              ),
              // Inner glassy circle with emoji
              Container(
                width: size * 0.72,
                height: size * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      habitColor.withValues(alpha: 0.22),
                      habitColor.withValues(alpha: 0.10),
                    ],
                  ),
                  border: Border.all(
                    color: habitColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: habitColor.withValues(alpha: 0.20),
                      blurRadius: 18,
                      spreadRadius: 2,
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

  Widget _buildScoreDisplay(BuildContext context, CupertinoThemeData theme, Color habitColor) {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final animatedScore = _scoreAnimation.value;
        final progress = animatedScore / 100.0;
        final scoreColor = _getFormationScoreColor(animatedScore);

        return _buildProgress(progress, animatedScore, scoreColor, theme);
      },
    );
  }

  Widget _buildProgress(
    double progress,
    double animatedScore,
    Color scoreColor,
    CupertinoThemeData theme,
  ) {
    return Builder(builder: (context) {
      final diameter = context.width(0.5);
      return SizedBox(
        height: diameter,
        width: diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background ring and progress with sheen
            CustomPaint(
              size: Size.square(diameter),
              painter: _GlossyProgressPainter(
                progress: progress.clamp(0.0, 1.0),
                baseColor: scoreColor,
                sheenPhase: _pulseAnimation.value,
              ),
            ),
            // Centered score and label
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Text(
                      '${animatedScore.round()}',
                      style: context.displayLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                        fontSize: 44,
                        fontFeatures: [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProgressSection(BuildContext context, CupertinoThemeData theme, Color habitColor) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final remainingDays = _getRemainingDaysByCompletions();

    return CupertinoCard(
      color: habitColor.withValues(alpha: 0.05),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.width(0.04),
          vertical: context.height(0.014),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chips row (wrap to avoid overflow)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: context.width(0.02),
              runSpacing: context.height(0.006),
              children: [
                _InfoChip(
                  icon: CupertinoIcons.flame_fill,
                  label: widget.habit.difficulty.displayName,
                  color: habitColor,
                ),
                _InfoChip(
                  icon: CupertinoIcons.calendar_badge_plus,
                  label: remainingDays == 0 ? LocaleKeys.achievement_dialog_habit_fully_formed.tr() : '${remainingDays.toString()} ${LocaleKeys.common_days.tr()}',
                  color: habitColor,
                ),
              ],
            ),
            SizedBox(height: context.height(0.012)),
            if (remainingDays == 0)
              Text(
                LocaleKeys.achievement_dialog_congratulations_fully_formed.tr(),
                style: context.bodyMedium.copyWith(
                  color: const Color(0xFF4CAF50),
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              )
            else
              Text(
                _getFormationMessage(widget.newScore),
                style: context.bodyMedium.copyWith(
                  color: cupertinoTheme.textTheme.textStyle.color ?? CupertinoColors.label,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumButton(BuildContext context, Color habitColor) {
    final gradient = LinearGradient(
      colors: [
        habitColor.withValues(alpha: 0.95),
        habitColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return CupertinoButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      },
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(90),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(90),
          boxShadow: [
            BoxShadow(
              color: habitColor.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.width(0.07),
          vertical: context.height(0.014),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleKeys.achievement_dialog_continue.tr(),
                  style: context.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
                SizedBox(width: context.width(0.02)),
                const Icon(
                  CupertinoIcons.arrow_right_circle_fill,
                  color: CupertinoColors.white,
                ),
              ],
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
    // Map score [0,100] to hue [0 (red) .. 120 (green)] for smoother variety
    final clamped = score.clamp(0.0, 100.0);
    final t = clamped / 100.0;
    final hue = 120.0 * t; // 0 -> red, 120 -> green

    // Slightly increase saturation and lightness for higher scores for richer colors
    final saturation = 0.55 + (0.25 * t); // 0.55 .. 0.80
    final lightness = 0.45 + (0.10 * t); // 0.45 .. 0.55

    return HSLColor.fromAHSL(1.0, hue, saturation.clamp(0.0, 1.0), lightness.clamp(0.0, 1.0)).toColor();
  }

  // Calculate total formation days needed for this habit
  int get _totalFormationDays => widget.habit.difficulty.estimatedFormationDays;

  // Count completed unique days for the habit

  // Remaining days to reach formation based on completions
  int _getRemainingDaysByCompletions() {
    return widget.habit.completions.getRemainingFormationDays(_totalFormationDays);
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

    return widget.habit.completions.calculateHabitProbability(
      dummyDate, // This parameter is now ignored, but kept for compatibility
      widget.habit.difficulty.estimatedFormationDays,
      widget.habit.difficulty.minimumCompletionRate,
      widget.habit.dailyTarget,
    );
  }
}

// Decorative gradient ring behind the emoji
class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({required this.baseColor, required this.glowFactor, this.rotation = 0.0});

  final Color baseColor;
  final double glowFactor; // 0..~ for subtle width/shadow variation
  final double rotation; // radians

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    // Background subtle ring with anti-alias
    final bgPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = baseColor.withValues(alpha: 0.10);
    canvas.drawCircle(center, radius * 0.86, bgPaint);

    // Gradient sweep ring
    final sweepPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10 + glowFactor * 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2)
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        tileMode: TileMode.repeated,
        transform: GradientRotation(-pi / 2 + rotation),
        colors: [
          baseColor.withValues(alpha: 0.00),
          baseColor.withValues(alpha: 0.45),
          const Color(0xFFFFD700).withValues(alpha: 0.55),
          baseColor.withValues(alpha: 0.45),
          baseColor.withValues(alpha: 0.00),
        ],
        stops: const [0.00, 0.30, 0.50, 0.70, 1.00],
      ).createShader(rect);

    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.78);
    canvas.drawArc(ringRect, -pi / 2, 2 * pi, false, sweepPaint);

    // Inner highlight ring
    final inner = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = CupertinoColors.white.withValues(alpha: 0.20);
    canvas.drawCircle(center, radius * 0.62, inner);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor || oldDelegate.glowFactor != glowFactor || oldDelegate.rotation != rotation;
  }
}

// Glossy circular progress with subtle moving sheen
class _GlossyProgressPainter extends CustomPainter {
  _GlossyProgressPainter({required this.progress, required this.baseColor, required this.sheenPhase});

  final double progress; // 0..1
  final Color baseColor;
  final double sheenPhase; // 0.95..1.05 breathing value

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    // Background track with soft edges
    final trackPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
      ..color = baseColor.withValues(alpha: 0.10);
    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.80);
    canvas.drawArc(ringRect, -pi / 2, 2 * pi, false, trackPaint);

    // Under-glow to soften outer border
    final glowPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = baseColor.withValues(alpha: 0.25);
    final sweepAngle = (2 * pi) * progress;
    canvas.drawArc(ringRect, -pi / 2, sweepAngle, false, glowPaint);

    // Progress gradient with seamless ends and clamp tile mode
    final progressPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        tileMode: TileMode.clamp,
        transform: const GradientRotation(-pi / 2),
        colors: [
          baseColor.withValues(alpha: 0.15),
          baseColor.withValues(alpha: 0.90),
          const Color(0xFFFFD700),
          baseColor.withValues(alpha: 0.90),
          baseColor.withValues(alpha: 0.15),
        ],
        stops: const [0.00, 0.40, 0.55, 0.70, 1.00],
      ).createShader(rect);
    canvas.drawArc(ringRect, -pi / 2, sweepAngle, false, progressPaint);

    // Sheen highlight moving along the progress end
    final headAngle = -pi / 2 + sweepAngle;
    final headOffset = Offset(
      center.dx + (radius * 0.80) * cos(headAngle),
      center.dy + (radius * 0.80) * sin(headAngle),
    );
    final sheenPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF).withValues(alpha: 0.90),
          const Color(0xFFFFFFFF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: headOffset, radius: 18 + (sheenPhase - 1.0).abs() * 20));
    canvas.drawCircle(headOffset, 10 + (sheenPhase - 1.0).abs() * 6, sheenPaint);

    // Inner subtle shadow to enhance depth
    final innerShadow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = CupertinoColors.black.withValues(alpha: 0.05);
    canvas.drawCircle(center, radius * 0.62, innerShadow);
  }

  @override
  bool shouldRepaint(covariant _GlossyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.baseColor != baseColor || oldDelegate.sheenPhase != sheenPhase;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.width(0.42);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.width(0.025),
        vertical: context.height(0.006),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: context.width(0.012)),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: context.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
