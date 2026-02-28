import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_extension.dart';
import '/models/habit/habit_model.dart';
import '../../../components/habit_probability_dialog.dart';
import '../../../components/reward_rating_dialog.dart';
import '../../../provider/home_provider.dart';

/// Circular habit item for the constellation view
/// Works with both Habit and HabitSummary for performance optimization
class CircularHabitWidget extends ConsumerStatefulWidget {
  final dynamic habit; // Can be Habit or HabitSummary
  final bool isSelected;
  final bool isDragging;
  final bool isConnecting;

  final VoidCallback? onComplete;
  final bool? showName;
  final bool
      useProvider; // If false, uses widget.habit directly without provider
  final bool
      showCompleteButton; // If true, shows complete button even when useProvider is false
  final bool
      enableCompleteButton; // If false, complete button is visible but not tappable

  const CircularHabitWidget({
    super.key,
    required this.habit,
    this.isSelected = false,
    this.isDragging = false,
    this.isConnecting = false,
    this.onComplete,
    this.showName,
    this.useProvider = true, // Default to true for backward compatibility
    this.showCompleteButton =
        false, // Default to false for backward compatibility
    this.enableCompleteButton =
        true, // Default to true for backward compatibility
  });

  @override
  ConsumerState<CircularHabitWidget> createState() =>
      _CircularHabitWidgetState();
}

class _CircularHabitWidgetState extends ConsumerState<CircularHabitWidget> {
  // Track decreasing mode for multi-completion support (similar to Last 7 Days)
  final Map<String, bool> _decreasingModeByDateKey = {};

  // Static const values for performance optimization
  static const double _size = 90.0;
  static const double _containerSize = _size + 10;
  static const EdgeInsets _badgePadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 3);
  static const EdgeInsets _namePadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 5);
  static const BorderRadius _badgeBorderRadius =
      BorderRadius.all(Radius.circular(12));
  static const TextStyle _emojiStyle = TextStyle(
    fontSize: 42,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const TextStyle _streakStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  Future<void> _toggleCompletion() async {
    if (!mounted) return;

    HapticFeedback.mediumImpact();

    final today = DateUtils.dateOnly(DateTime.now());
    final dateKey = '${today.year}-${today.month}-${today.day}';
    final homeNotifier = ref.read(homeProvider.notifier);

    // Get full habit from provider for completion operations
    final beforeHabit = ref.read(homeProvider).maybeWhen(
          data: (homeState) => homeState.habits.firstWhere(
            (h) => h.id == widget.habit.id,
            orElse: () {
              // If not found, return widget.habit if it's a full Habit, otherwise we need to load it
              if (widget.habit is Habit) {
                return widget.habit as Habit;
              }
              // If it's a summary, we need to load the full habit
              throw Exception(
                  'Habit not found and cannot use summary for completion');
            },
          ),
          orElse: () {
            if (widget.habit is Habit) {
              return widget.habit as Habit;
            }
            throw Exception(
                'Habit not found and cannot use summary for completion');
          },
        );

    final beforeCount = beforeHabit.getCountForDate(today);
    final beforeTarget =
        beforeHabit.dailyTarget <= 0 ? 1 : beforeHabit.dailyTarget;
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
              orElse: () {
                if (widget.habit is Habit) {
                  return widget.habit as Habit;
                }
                throw Exception('Habit not found');
              },
            ),
            orElse: () {
              if (widget.habit is Habit) {
                return widget.habit as Habit;
              }
              throw Exception('Habit not found');
            },
          );
      if (!mounted) return;
      final afterCount = afterHabit.getCountForDate(today);
      final afterTarget =
          afterHabit.dailyTarget <= 0 ? 1 : afterHabit.dailyTarget;
      final afterRatio = (afterCount / afterTarget).clamp(0.0, 1.0);

      // Update decreasing mode after action based on new ratio (similar to Last 7 Days)
      if (afterRatio >= 1.0) {
        _decreasingModeByDateKey[dateKey] = true;
      } else if (afterRatio == 0.0) {
        _decreasingModeByDateKey[dateKey] = false;
      }

      // Show reward rating dialog for each increment in multi-completion mode
      // This allows users to rate each completion separately, which affects probability calculation
      if (shouldIncrement && afterCount > beforeCount) {
        await _showRewardRatingDialog(
            updatedHabit: afterHabit, previousHabit: beforeHabit);
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Achievement dialog error: $e');
    }

    widget.onComplete?.call();
  }

  double _getProgressPercentage(Habit habit) {
    return habit.calculateWeightedProgressPercentageFromFirstCompletion();
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
      final updatedCompletions =
          Map<String, CompletionEntry>.from(currentHabit.completions);
      updatedCompletions[dateKey] = updatedEntry;

      // Update habit locally
      final habitWithRating =
          currentHabit.copyWith(completions: updatedCompletions);

      // Save to service via home provider
      await ref.read(homeProvider.notifier).updateHabit(habitWithRating);

      // Refresh to get updated habit
      await ref.read(homeProvider.notifier).fetchHabits();

      // Small delay before showing probability dialog
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // Get the latest habit state after refresh to ensure reward rating is included
      final latestHabit = ref.read(homeProvider).maybeWhen(
            data: (homeState) => homeState.habits.firstWhere(
              (h) => h.id == updatedHabit.id,
              orElse: () => habitWithRating,
            ),
            orElse: () => habitWithRating,
          );

      // Show probability dialog after rating is saved
      await _showAchievementIfEarned(
        previousHabit: previousHabit,
        updatedHabit: latestHabit,
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

  Future<void> _showAchievementIfEarned(
      {required Habit previousHabit, required Habit updatedHabit}) async {
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
    // Use provider if enabled and habit is a full Habit, otherwise use widget.habit directly
    // For HabitSummary, we don't watch provider since summaries are lightweight
    final currentHabit = widget.useProvider && widget.habit is Habit
        ? ref.watch(
            homeProvider.select(
              (state) => state.maybeWhen(
                data: (homeState) => homeState.habits.firstWhere(
                  (h) => h.id == widget.habit.id,
                  orElse: () => widget.habit as Habit,
                ),
                orElse: () => widget.habit as Habit,
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

    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;
    final dragScale = widget.isDragging ? 1.15 : 1.0;

    return Transform.scale(
      scale: dragScale,
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Completion time (top, if exists) - displayed on main page
            if (currentHabit.completionTime != null) ...[
              Opacity(
                opacity: widget.showName ?? true ? 1.0 : 0.0,
                child: Text(
                  (currentHabit.completionTime as DateTime).toHHMM(),
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

            // Main circular item - using Container for better performance
            Container(
              width: _containerSize,
              height: _containerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? CupertinoColors.systemGrey6.darkColor
                    : Colors.white,
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
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
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
                  Text(emoji, style: _emojiStyle),

                  // Streak badge (top right) - optimized without BackdropFilter
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: _badgePadding,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: habitColor.withValues(alpha: 0.8),
                          width: 1,
                        ),
                        color: isDark
                            ? habitColor.withValues(alpha: 0.3)
                            : habitColor.withValues(alpha: 0.15),
                        borderRadius: _badgeBorderRadius,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.flame_fill,
                            size: 14,
                            color: context.theme.primaryContrastingColor
                                .withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$streak',
                            style: _streakStyle.copyWith(
                              color: context.theme.primaryContrastingColor
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Complete button (bottom right) - optimized without BackdropFilter
                  // Show if useProvider is true or showCompleteButton is true
                  if (widget.useProvider || widget.showCompleteButton)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: !widget.enableCompleteButton,
                        child: CustomButton(
                          onPressed: _toggleCompletion,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Progressive alpha based on completion ratio
                              color: habitColor.withValues(
                                  alpha: (0.1 + (0.9 * ratio)).clamp(0.1, 1.0)),
                              border: Border.all(
                                color: habitColor,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: habitColor.withValues(
                                      alpha: isCompleted ? 0.3 : 0.15),
                                  blurRadius: isCompleted ? 8 : 4,
                                  spreadRadius: isCompleted ? 1 : 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: FaIcon(
                                isCompleted
                                    ? FontAwesomeIcons.check
                                    : FontAwesomeIcons.plus,
                                size: 17,
                                color: isCompleted
                                    ? Colors
                                        .white // Always white when completed (background is habitColor)
                                    : habitColor, // Use habitColor when not completed (background is light)
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

            // Habit name - with optimized blur (lower sigma value for better performance)
            Opacity(
              opacity: widget.showName ?? true ? 1.0 : 0.0,
              child: ClipRRect(
                borderRadius: _badgeBorderRadius,
                child: BackdropFilter(
                  // Lower blur value (6 instead of 10) for better performance
                  filter: ImageFilter.blur(
                      sigmaX: 6, sigmaY: 6, tileMode: TileMode.decal),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? habitColor.withValues(alpha: 0.25)
                          : habitColor.withValues(alpha: 0.15),
                      borderRadius: _badgeBorderRadius,
                    ),
                    padding: _namePadding,
                    child: Text(
                      currentHabit.habitName,
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: context.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.95)
                            : Colors.black.withValues(alpha: 0.85),
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
