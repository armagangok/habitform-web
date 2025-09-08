import 'dart:ui';

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
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _particleAnimation;
  int _lastNotifiedScore = 0;

  @override
  void initState() {
    super.initState();

    // Haptic feedback for achievement
    HapticFeedback.lightImpact();

    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _scoreController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    _particleController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    _scoreAnimation = Tween<double>(begin: 0.0, end: widget.newScore.toDouble()).animate(CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic));
    _lastNotifiedScore = 0;
    _scoreController.addListener(() {
      final current = _scoreAnimation.value.round();
      if (current > _lastNotifiedScore) {
        HapticFeedback.selectionClick();
        _lastNotifiedScore = current;
      }
    });

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _particleController, curve: Curves.easeOut));

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _scoreController.forward();
    });
    _particleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _scoreController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: Container(
                width: 320, // Ideal width

                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: context.cupertinoTheme.barBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Achievement Icon with particles
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Particle effects
                          AnimatedBuilder(
                            animation: _particleAnimation,
                            builder: (context, child) {
                              final particleColor = widget.pointsGained > 0 ? CupertinoColors.systemGreen : CupertinoColors.systemOrange;
                              return Transform.rotate(
                                angle: _particleAnimation.value * 2 * 3.14159,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        particleColor.withValues(alpha: 0.3 * _particleAnimation.value),
                                        particleColor.withValues(alpha: 0.1 * _particleAnimation.value),
                                        particleColor.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Main icon
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: widget.pointsGained > 0 ? CupertinoColors.systemGreen.withValues(alpha: 0.1) : CupertinoColors.systemOrange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.habit.emoji ?? '✨',
                                    style: context.headlineMedium.copyWith(fontSize: 40),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Text(
                        widget.habit.habitName,
                        style: context.titleLarge.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: widget.pointsGained > 0 ? CupertinoColors.systemGreen : CupertinoColors.systemOrange,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 4),

                      // Achievement title
                      Text(
                        widget.pointsGained > 0 ? 'Great Progress!' : 'Score Update',
                        style: context.headlineMedium.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      // Category and message

                      Text(
                        widget.message,
                        style: context.bodySmall.copyWith(
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Progress percentage score
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          final animatedScore = _scoreAnimation.value;
                          return Text(
                            '${animatedScore.round()}',
                            style: context.headlineMedium.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _getFormationScoreColor(animatedScore),
                              fontFeatures: [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Formation Progress Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: context.cupertinoTheme.barBackgroundColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getFormationScoreColor(_scoreAnimation.value).withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Days remaining info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Formation Progress',
                                  style: context.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _getFormationScoreColor(_scoreAnimation.value),
                                  ),
                                ),
                                Text(
                                  '${_getRemainingDaysByCompletions()} days left',
                                  style: context.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: context.bodyMedium.color?.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Progress bar - Cupertino style
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: context.cupertinoTheme.brightness == Brightness.dark ? CupertinoColors.systemFill : CupertinoColors.systemGrey5,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Stack(
                                    children: [
                                      Container(
                                        width: constraints.maxWidth * _getFormationProgressByCompletions(),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: _getFormationScoreColor(_scoreAnimation.value),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Progress percentage and total days
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(_getFormationProgressByCompletions() * 100).round()}% complete',
                                  style: context.bodySmall.copyWith(
                                    color: context.bodySmall.color?.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${_getCompletedDays()}/$_totalFormationDays days',
                                  style: context.bodySmall.copyWith(
                                    color: context.bodySmall.color?.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Formation progress message
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          final animatedScore = _scoreAnimation.value;
                          return Text(
                            _getFormationMessage(animatedScore.round()),
                            style: context.bodySmall.copyWith(
                              fontSize: 12,
                              color: context.bodySmall.color?.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          child: Text('Continue'),
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
    );
  }

  Color _getFormationScoreColor(double score) {
    if (score >= 90) return const Color(0xFF4CAF50); // Green - Excellent
    if (score >= 70) return const Color(0xFF8BC34A); // Light Green - Good
    if (score >= 50) return const Color(0xFFFFC107); // Amber - Moderate
    return const Color(0xFFF44336); // Red - Insufficient
  }

  // Calculate total formation days needed for this habit
  HabitDifficulty get _defaultDifficulty => HabitDifficulty.moderate;

  int get _totalFormationDays => _defaultDifficulty.estimatedFormationDays;

  // Count completed unique days for the habit
  int _getCompletedDays() {
    return widget.habit.completions.calculateFormationScore();
  }

  // Remaining days to reach formation based on completions
  int _getRemainingDaysByCompletions() {
    return widget.habit.completions.getRemainingFormationDays(_totalFormationDays);
  }

  // Progress ratio based on completions
  double _getFormationProgressByCompletions() {
    return widget.habit.completions.calculateFormationProgress(_totalFormationDays);
  }

  String _getFormationMessage(int score) {
    final remainingDays = _getRemainingDaysByCompletions();
    final totalDays = _totalFormationDays;
    final difficultyName = _defaultDifficulty.displayName;

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
