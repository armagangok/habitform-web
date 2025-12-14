import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/reminder/models/reminder/reminder_model.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_extension.dart';
import '/models/habit/habit_model.dart';
import '../../../components/habit_probability_dialog.dart';
import '../../../components/reward_rating_dialog.dart';
import '../../../provider/home_provider.dart';

/// Circular habit item for the constellation view
class CircularHabitWidget extends ConsumerStatefulWidget {
  final Habit habit;
  final bool isSelected;
  final bool isDragging;
  final bool isConnecting;

  final VoidCallback? onComplete;
  final bool? showName;
  final bool useProvider; // If false, uses widget.habit directly without provider
  final bool showCompleteButton; // If true, shows complete button even when useProvider is false
  final bool enableCompleteButton; // If false, complete button is visible but not tappable

  const CircularHabitWidget({
    super.key,
    required this.habit,
    this.isSelected = false,
    this.isDragging = false,
    this.isConnecting = false,
    this.onComplete,
    this.showName,
    this.useProvider = true, // Default to true for backward compatibility
    this.showCompleteButton = false, // Default to false for backward compatibility
    this.enableCompleteButton = true, // Default to true for backward compatibility
  });

  @override
  ConsumerState<CircularHabitWidget> createState() => _CircularHabitWidgetState();
}

class _CircularHabitWidgetState extends ConsumerState<CircularHabitWidget> {
  // Track decreasing mode for multi-completion support (similar to Last 7 Days)
  final Map<String, bool> _decreasingModeByDateKey = {};

  Future<void> _toggleCompletion() async {
    if (!mounted) return;

    HapticFeedback.mediumImpact();

    final today = DateUtils.dateOnly(DateTime.now());
    final dateKey = '${today.year}-${today.month}-${today.day}';
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
    final beforeRatio = (beforeCount / beforeTarget).clamp(0.0, 1.0);

    // Determine current mode (similar to Last 7 Days widget)
    bool isDecreasing = _decreasingModeByDateKey[dateKey] ?? false;
    if (beforeRatio >= 1.0) {
      isDecreasing = true;
    } else if (beforeRatio == 0.0) {
      isDecreasing = false;
    }

    // Choose direction: when decreasing, continue until 0; when increasing, continue until full
    final shouldIncrement = !isDecreasing;
    final beforeFull = beforeCount >= beforeTarget;

    await homeNotifier.adjustHabitCompletion(
      widget.habit.id,
      today,
      increment: shouldIncrement,
    );

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
      final afterTarget = afterHabit.dailyTarget <= 0 ? 1 : afterHabit.dailyTarget;
      final afterFull = afterCount >= afterTarget;
      final afterRatio = (afterCount / afterTarget).clamp(0.0, 1.0);

      // Update decreasing mode after action based on new ratio (similar to Last 7 Days)
      if (afterRatio >= 1.0) {
        _decreasingModeByDateKey[dateKey] = true;
      } else if (afterRatio == 0.0) {
        _decreasingModeByDateKey[dateKey] = false;
      }

      // Show reward rating dialog when habit is newly completed
      // User must rate how they felt, then we show probability dialog
      if (!beforeFull && afterFull) {
        await _showRewardRatingDialog(updatedHabit: afterHabit, previousHabit: beforeHabit);
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Achievement dialog error: $e');
    }

    widget.onComplete?.call();
  }

  double _getProgressPercentage(Habit habit) {
    return habit.calculateWeightedProgressPercentageFromFirstCompletion();
  }

  String _getReminderTimeText(ReminderModel reminder) {
    if (reminder.hasMultipleReminders) {
      final times = reminder.multipleReminders!.sortedReminderTimes;
      if (times.isEmpty) return '';
      if (times.length == 1) {
        return times.first.toHHMM();
      } else {
        // Show first 2 times, or all if 2 or less
        final displayTimes = times.take(2).map((time) => time.toHHMM()).join(', ');
        return times.length > 2 ? '$displayTimes...' : displayTimes;
      }
    } else if (reminder.hasSingleReminder) {
      return reminder.reminderTime!.toHHMM();
    }
    return '';
  }

  /// Show reward rating dialog first, then update completion and show probability dialog
  Future<void> _showRewardRatingDialog({
    required Habit updatedHabit,
    required Habit previousHabit,
  }) async {
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Show reward rating dialog (mandatory - user must select)
    // Dialog returns the selected rating when closed
    double? rewardRating;
    try {
      rewardRating = await showCupertinoDialog<double>(
        context: context,
        barrierDismissible: false, // User must select a rating
        builder: (dialogContext) => RewardRatingDialog(
          habit: updatedHabit,
        ),
      );
    } catch (e) {
      LogHelper.shared.errorPrint('Error showing reward rating dialog: $e');
      return;
    }

    if (!mounted || rewardRating == null) return;

    // Small delay to ensure dialog is fully closed before proceeding
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // Update the completion entry with reward rating
    final today = DateUtils.dateOnly(DateTime.now());
    final dateKey = '${today.year}-${today.month}-${today.day}';

    // Get current completion entry
    final currentHabit = ref.read(homeProvider).maybeWhen(
          data: (homeState) => homeState.habits.firstWhere(
            (h) => h.id == updatedHabit.id,
            orElse: () => updatedHabit,
          ),
          orElse: () => updatedHabit,
        );

    final existingEntry = currentHabit.completions[dateKey];
    if (existingEntry != null) {
      // Update completion entry with reward rating
      final updatedEntry = existingEntry.copyWith(rewardRating: rewardRating);
      final updatedCompletions = Map<String, CompletionEntry>.from(currentHabit.completions);
      updatedCompletions[dateKey] = updatedEntry;

      // Update habit locally
      final habitWithRating = currentHabit.copyWith(completions: updatedCompletions);

      // Save to service via home provider
      await ref.read(homeProvider.notifier).updateHabit(habitWithRating);

      // Refresh to get updated habit
      await ref.read(homeProvider.notifier).fetchHabits();

      // Small delay before showing probability dialog
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // Show probability dialog after rating is saved
      await _showAchievementIfEarned(
        previousHabit: previousHabit,
        updatedHabit: habitWithRating,
      );
    } else {
      // If entry not found, just show probability dialog
      if (!mounted) return;
      await _showAchievementIfEarned(
        previousHabit: previousHabit,
        updatedHabit: updatedHabit,
      );
    }
  }

  Future<void> _showAchievementIfEarned({required Habit previousHabit, required Habit updatedHabit}) async {
    if (!mounted) return;

    final previousScore = _getProgressPercentage(previousHabit);
    final newScore = _getProgressPercentage(updatedHabit);

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

  @override
  Widget build(BuildContext context) {
    // Use provider if enabled, otherwise use widget.habit directly
    // Optimized: Only watch the specific habit instead of entire homeProvider
    final currentHabit = widget.useProvider
        ? ref.watch(
            homeProvider.select(
              (state) => state.maybeWhen(
                data: (homeState) => homeState.habits.firstWhere(
                  (h) => h.id == widget.habit.id,
                  orElse: () => widget.habit,
                ),
                orElse: () => widget.habit,
              ),
            ),
          )
        : widget.habit;

    final today = DateTime.now();
    final count = currentHabit.getCountForDate(today);
    final target = currentHabit.dailyTarget <= 0 ? 1 : currentHabit.dailyTarget;
    final ratio = (count / target).clamp(0.0, 1.0);
    final isCompleted = ratio >= 1.0;

    final habitColor = Color(currentHabit.colorCode);
    final emoji = currentHabit.emoji ?? '🎯';
    final streak = currentHabit.calculateCurrentStreak();

    const double size = 90.0;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final dragScale = widget.isDragging ? 1.15 : 1.0;

    return Transform.scale(
      scale: dragScale,
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reminder time (top, if exists)
            if (currentHabit.reminderModel != null && currentHabit.reminderModel!.hasAnyReminders) ...[
              AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: widget.showName ?? true ? 1.0 : 0.0,
                child: Text(
                  _getReminderTimeText(currentHabit.reminderModel!),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.labelSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 2.5),
            ],

            // Main circular item
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: size + 10,
              height: size + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? CupertinoColors.systemGrey6.darkColor : Colors.white,
                border: Border.all(
                  color: widget.isSelected || widget.isDragging
                      ? habitColor
                      : widget.isConnecting
                          ? habitColor
                          : isCompleted
                              ? habitColor
                              : habitColor.withValues(alpha: 0.7),
                  width: widget.isSelected || widget.isDragging ? 3.5 : 2.5,
                ),
                boxShadow: [
                  if (widget.isDragging) ...[
                    BoxShadow(
                      color: habitColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ] else if (isCompleted) ...[
                    BoxShadow(
                      color: habitColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ] else ...[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Emoji
                  Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 42,
                      fontFeatures: [
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),

                  // Streak badge (top right)
                  // if (streak > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: CustomBlurWidget(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: habitColor.withValues(alpha: 0.7),
                            width: 1,
                          ),
                          color: habitColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.flame_fill,
                              size: 14,
                              color: context.theme.primaryContrastingColor.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$streak',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFeatures: [
                                  FontFeature.tabularFigures(),
                                ],
                                color: context.theme.primaryContrastingColor.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Complete button (bottom right) - show if useProvider is true or showCompleteButton is true
                  if (widget.useProvider || widget.showCompleteButton)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: !widget.enableCompleteButton,
                        child: CustomButton(
                          onPressed: _toggleCompletion,
                          child: CustomBlurWidget(
                            borderRadius: BorderRadius.circular(100),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // Progressive alpha based on completion ratio (similar to Last 7 Days)
                                color: habitColor.withValues(alpha: (0.1 + (0.9 * ratio)).clamp(0.1, 1.0)),
                                border: Border.all(
                                  color: habitColor,
                                  width: 1,
                                ),
                                boxShadow: isCompleted
                                    ? [
                                        BoxShadow(
                                          color: habitColor.withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: FaIcon(
                                  isCompleted ? FontAwesomeIcons.check : FontAwesomeIcons.plus,
                                  size: 17,
                                  color: isCompleted
                                      ? Colors.white // Always white when completed (background is habitColor)
                                      : habitColor, // Use habitColor when not completed (background is light)
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Habit name (with animation support)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              opacity: widget.showName ?? true ? 1.0 : 0.0,
              child: CustomBlurWidget(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: habitColor.withValues(alpha: 0.195),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Text(
                      currentHabit.habitName,
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: context.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.8),
                      ),
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
}
