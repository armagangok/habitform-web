import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_extension.dart';
import '/models/models.dart';
import '../../../habit_detail/page/habit_detail.dart';
import '../../../habit_detail/providers/habit_detail_provider.dart';
import '../../components/achievement_dialog.dart';
import '../../provider/home_provider.dart';

class HabitWidget extends ConsumerStatefulWidget {
  const HabitWidget({super.key, required this.habit});

  final Habit habit;

  @override
  ConsumerState<HabitWidget> createState() => _HabitWidgetState();
}

class _HabitWidgetState extends ConsumerState<HabitWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _tapScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _tapScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08).chain(CurveTween(curve: Curves.easeOut)), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 45),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
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
      builder: (_) => AchievementDialog(
        habit: updatedHabit,
        pointsGained: 10,
        previousScore: previousScore.round(),
        newScore: newScore.round(),
        message: 'Nice! You completed today. Keep the streak going! 🔥',
      ),
    );
  }

  Widget _buildCompletionIndicator(double ratio, Color habitColor) {
    if (ratio >= 1.0) {
      return Container(
        key: const ValueKey<bool>(true),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: habitColor,
          boxShadow: [
            BoxShadow(
              color: habitColor.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          CupertinoIcons.checkmark,
          color: Colors.white,
          size: 18,
        ),
      );
    } else {
      return Container(
        key: const ValueKey<bool>(false),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: habitColor.withValues(alpha: (0.12 + 0.88 * ratio).clamp(0.12, 1.0)),
          border: Border.all(color: habitColor.withValues(alpha: 0.6), width: 2.5),
        ),
        child: Icon(
          CupertinoIcons.circle,
          color: Colors.transparent,
          size: 20,
        ),
      );
    }
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

      await _controller.forward(from: 0.0);

      if (!mounted) return;
      // If currently in decreasing mode, switch to decrement instead
      await homeNotifier.adjustHabitCompletion(widget.habit.id, today, increment: !_isDecreasingMode);

      // Only show achievement when crossing from below target to full target
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
        if (!beforeFull && afterFull) {
          await _showAchievementIfEarned(previousHabit: beforeHabit, updatedHabit: afterHabit);
        }
      } catch (e) {
        LogHelper.shared.debugPrint('Achievement dialog error: $e');
      }
    } catch (e) {
      // Genel hata durumunda sessizce devam et
      LogHelper.shared.debugPrint('Toggle habit error: $e');
    }
  }

  void _decrementToday() async {
    if (!mounted) return;
    try {
      final today = DateTime.now();
      final homeNotifier = ref.read(homeProvider.notifier);
      _isDecreasingMode = true;
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
    // Update decreasing mode based on current ratio
    if (ratio >= 1.0) {
      _isDecreasingMode = true;
    } else if (ratio == 0.0) {
      _isDecreasingMode = false;
    }
    final habitColor = Color(currentHabit.colorCode);
    final emoji = currentHabit.emoji ?? '🎯';
    final streak = currentHabit.calculateCurrentStreak();

    return CustomButton(
      onPressed: _openHabitDetail,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: habitColor.withValues(alpha: ratio > 0 ? 0.1 : 0.025),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: habitColor.withValues(alpha: 0.35), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Emoji - top left
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: habitColor.withValues(alpha: 0.12),
                        border: Border.all(color: habitColor.withValues(alpha: 0.25)),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),

                    // Streak pill - top right
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: habitColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: habitColor.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.flame_fill, size: 16, color: habitColor),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                              return FadeTransition(
                                opacity: curved,
                                child: ScaleTransition(scale: curved, child: child),
                              );
                            },
                            child: Text(
                              '$streak',
                              key: ValueKey<int>(streak),
                              style: context.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: habitColor,
                                fontFeatures: [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Habit name - bottom left
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        habitName,
                        maxLines: null,
                        style: context.titleLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),

                    // Complete button - bottom right
                    CustomButton(
                      onPressed: _incrementToday,
                      onLongPressed: _decrementToday,
                      child: ScaleTransition(
                        scale: _tapScaleAnimation,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
                            return FadeTransition(
                              opacity: curved,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
                                child: child,
                              ),
                            );
                          },
                          child: _buildCompletionIndicator(ratio, habitColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
