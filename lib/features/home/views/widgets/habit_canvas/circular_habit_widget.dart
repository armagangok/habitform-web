import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/reminder/models/reminder/reminder_model.dart';
import '/models/habit/habit_extension.dart';
import '/models/habit/habit_model.dart';
import '../../../components/habit_probability_dialog.dart';
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

class _CircularHabitWidgetState extends ConsumerState<CircularHabitWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleCompletion() async {
    if (!mounted) return;

    HapticFeedback.mediumImpact();

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

    await homeNotifier.adjustHabitCompletion(
      widget.habit.id,
      today,
      increment: !beforeFull,
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

      // Show achievement dialog when habit is newly completed
      if (!beforeFull && afterFull) {
        await _showAchievementIfEarned(previousHabit: beforeHabit, updatedHabit: afterHabit);
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

  @override
  Widget build(BuildContext context) {
    // Use provider if enabled, otherwise use widget.habit directly
    final currentHabit = widget.useProvider
        ? ref.watch(homeProvider).maybeWhen(
              data: (homeState) => homeState.habits.firstWhere(
                (h) => h.id == widget.habit.id,
                orElse: () => widget.habit,
              ),
              orElse: () => widget.habit,
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

    // Handle pulse animation
    if (isCompleted && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isCompleted && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    const double size = 90.0;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = isCompleted ? 1.0 : _pulseAnimation.value;
        final dragScale = widget.isDragging ? 1.15 : 1.0;
        return Transform.scale(scale: scale * dragScale, child: child);
      },
      child: SizedBox(
        width: size + 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reminder time (top, if exists)
            if (currentHabit.reminderModel != null && currentHabit.reminderModel!.hasAnyReminders) ...[
              AnimatedOpacity(
                duration: const Duration(milliseconds: 350),
                opacity: widget.showName ?? true ? 1.0 : 0.0,
                child: SizedBox(
                  width: size + 20,
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
              ),
              const SizedBox(height: 3),
            ],

            // Main circular item
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: size,
              height: size,
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
                      fontSize: 38,
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: habitColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: habitColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.flame_fill,
                            size: 13,
                            color: habitColor.colorRegardingToBrightness,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$streak',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: habitColor.colorRegardingToBrightness,
                            ),
                          ),
                        ],
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
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: habitColor.withValues(alpha: isCompleted ? 1.0 : 0.1),
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
                              child: Icon(
                                isCompleted ? CupertinoIcons.checkmark : CupertinoIcons.plus,
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
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Habit name (with animation support)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              opacity: widget.showName ?? true ? 1.0 : 0.0,
              child: CustomBlurWidget(
                borderRadius: BorderRadius.circular(100),
                child: ColoredBox(
                  color: habitColor.withValues(alpha: 0.195),
                  child: SizedBox(
                    width: size + 20,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text(
                        currentHabit.habitName,
                        textAlign: TextAlign.center,
                        maxLines: null,
                        overflow: TextOverflow.ellipsis,
                        style: context.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.87),
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
    );
  }
}
