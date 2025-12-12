import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_extension.dart';
import '/models/models.dart';
import '../../../habit_detail/page/habit_detail.dart';
import '../../../habit_detail/providers/habit_detail_provider.dart';
import '../../components/habit_probability_dialog.dart';
import '../../provider/home_provider.dart';

class HabitWidget extends ConsumerStatefulWidget {
  const HabitWidget({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<HabitWidget> createState() => _HabitWidgetState();
}

class _HabitWidgetState extends ConsumerState<HabitWidget> with TickerProviderStateMixin {
  // Completion button bounce animation
  late final AnimationController _completionController;
  late final Animation<double> _completionBounceAnimation;

  // Progress ring animation
  late final AnimationController _progressController;

  // Pulse animation for completed state
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Completion button bounce
    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _completionBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_completionController);

    // Progress ring animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Pulse animation for completed habits
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _completionController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _openHabitDetail() {
    ref.watch(habitDetailProvider.notifier).initHabit(widget.habit);

    showCupertinoSheet(
      enableDrag: false,
      context: context,
      builder: (contextFromSheet) => HabitDetailPage(),
    );
  }

  double _getProgressPercentage(Habit habit) {
    return habit.calculateWeightedProgressPercentageFromFirstCompletion();
  }

  Future<void> _showAchievementIfEarned({required Habit previousHabit, required Habit updatedHabit}) async {
    if (!mounted) return;

    final previousScore = _getProgressPercentage(previousHabit);
    final newScore = _getProgressPercentage(updatedHabit);

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    await showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => HabitProbabilityDialog(
        habit: updatedHabit,
        pointsGained: 10,
        previousScore: previousScore.round(),
        newScore: newScore.round(),
        message: 'Nice! You completed today. Keep the streak going! 🔥',
      ),
    );
  }

  // Circular progress ring widget
  Widget _buildProgressRing({
    required double progress,
    required Color color,
    required double size,
    required Widget child,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: 1.0,
              color: color.withValues(alpha: 0.15),
              strokeWidth: 4,
            ),
          ),
          // Progress ring
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _ProgressRingPainter(
                  progress: value,
                  color: color,
                  strokeWidth: 4,
                ),
              );
            },
          ),
          // Center content
          child,
        ],
      ),
    );
  }

  // Compact action button
  Widget _buildActionButton({
    required bool isCompleted,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return CustomButton(
      onPressed: onTap,
      onLongPressed: onLongPress,
      child: ScaleTransition(
        scale: _completionBounceAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? color : Colors.transparent,
            border: Border.all(
              color: color,
              width: isCompleted ? 0 : 2.5,
            ),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isCompleted
                ? Icon(
                    CupertinoIcons.checkmark,
                    key: const ValueKey('check'),
                    color: Colors.white,
                    size: 20,
                  )
                : Icon(
                    CupertinoIcons.plus,
                    key: const ValueKey('plus'),
                    color: color,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }

  bool _isDecreasingMode = false;

  void _incrementToday() async {
    if (!mounted) return;

    try {
      final today = DateTime.now();
      final homeNotifier = ref.read(homeProvider.notifier);
      final beforeHabit = ref.read(homeProvider).maybeWhen(
            data: (homeState) => homeState.habits.firstWhere(
              (h) => h.id == widget.habit.id,
              orElse: () => widget.habit,
            ),
            orElse: () => widget.habit,
          );
      final beforeCount = beforeHabit.getCountForDate(today);
      final beforeTarget = beforeHabit.dailyTarget <= 0 ? 1 : beforeHabit.dailyTarget;
      final beforeFull = beforeCount >= beforeTarget;

      _completionController.forward(from: 0.0);

      if (!mounted) return;
      await homeNotifier.adjustHabitCompletion(widget.habit.id, today, increment: !_isDecreasingMode);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;

      try {
        final afterHabit = ref.read(homeProvider).maybeWhen(
              data: (homeState) => homeState.habits.firstWhere(
                (h) => h.id == widget.habit.id,
                orElse: () => widget.habit,
              ),
              orElse: () => widget.habit,
            );
        if (!mounted) return;
        final afterCount = afterHabit.getCountForDate(today);
        final target = afterHabit.dailyTarget <= 0 ? 1 : afterHabit.dailyTarget;
        final afterFull = afterCount >= target;

        // Start pulse animation when completed
        if (!beforeFull && afterFull) {
          _pulseController.repeat(reverse: true);
          await _showAchievementIfEarned(previousHabit: beforeHabit, updatedHabit: afterHabit);
        }
      } catch (e) {
        LogHelper.shared.debugPrint('Achievement dialog error: $e');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Toggle habit error: $e');
    }
  }

  void _decrementToday() async {
    if (!mounted) return;
    try {
      final today = DateTime.now();
      final homeNotifier = ref.read(homeProvider.notifier);
      _isDecreasingMode = true;
      _pulseController.stop();
      _pulseController.reset();
      await homeNotifier.adjustHabitCompletion(widget.habit.id, today, increment: false);
    } catch (e) {
      LogHelper.shared.debugPrint('Decrement habit error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHabit = ref.watch(homeProvider).maybeWhen(
          data: (homeState) => homeState.habits.firstWhere(
            (h) => h.id == widget.habit.id,
            orElse: () => widget.habit,
          ),
          orElse: () => widget.habit,
        );

    final habitName = currentHabit.habitName;
    final today = DateTime.now();
    final count = currentHabit.getCountForDate(today);
    final ratio = currentHabit.dailyTarget > 0 ? (count / currentHabit.dailyTarget).clamp(0.0, 1.0) : 0.0;
    final isCompleted = ratio >= 1.0;

    // Update decreasing mode and pulse animation based on current ratio
    if (isCompleted) {
      _isDecreasingMode = true;
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (ratio == 0.0) {
        _isDecreasingMode = false;
      }
      _pulseController.stop();
      _pulseController.reset();
    }

    final habitColor = Color(currentHabit.colorCode);
    final emoji = currentHabit.emoji ?? '🎯';
    final streak = currentHabit.calculateCurrentStreak();

    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.white;

    return CustomButton(
      onPressed: _openHabitDetail,
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale = isCompleted ? _pulseAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isCompleted ? habitColor.withValues(alpha: 0.6) : habitColor.withValues(alpha: 0.2),
                width: isCompleted ? 2.5 : 1.5,
              ),
              boxShadow: [
                // Base elevation shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
                // Colored ambient glow
                if (isCompleted)
                  BoxShadow(
                    color: habitColor.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: -4,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                children: [
                  // Accent color strip at top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: isCompleted ? 6 : 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            habitColor,
                            habitColor.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: isCompleted
                            ? [
                                BoxShadow(
                                  color: habitColor.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      children: [
                        // Top section: Progress ring with emoji
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: _buildProgressRing(
                              progress: ratio,
                              color: habitColor,
                              size: 80,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: habitColor.withValues(alpha: 0.1),
                                  boxShadow: isCompleted
                                      ? [
                                          BoxShadow(
                                            color: habitColor.withValues(alpha: 0.2),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom section: Name, Streak, Action button
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Habit name - centered
                              Text(
                                habitName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: context.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Bottom row: Streak + Action button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Streak badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: habitColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.flame_fill,
                                          size: 14,
                                          color: habitColor,
                                        ),
                                        const SizedBox(width: 4),
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 300),
                                          transitionBuilder: (child, animation) {
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(0, 0.5),
                                                end: Offset.zero,
                                              ).animate(CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutBack,
                                              )),
                                              child: FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            '$streak',
                                            key: ValueKey<int>(streak),
                                            style: context.labelMedium.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: habitColor,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Action button
                                  _buildActionButton(
                                    isCompleted: isCompleted,
                                    color: habitColor,
                                    onTap: _incrementToday,
                                    onLongPress: _decrementToday,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

// Custom painter for progress ring
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc from top (-90 degrees)
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
