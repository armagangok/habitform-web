import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../providers/habit_detail_provider.dart';
import '../providers/habit_statistics_provider.dart';

class HabitProgressCard extends ConsumerWidget {
  final Habit habit;

  const HabitProgressCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoListSection.insetGrouped(
      header: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            FontAwesomeIcons.chartPie,
            size: 20,
            color: Color(habit.colorCode),
          ),
          const SizedBox(width: 8),
          Text(
            LocaleKeys.habit_detail_last_7_days.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.titleLarge.color,
            ),
          ),
          // const Spacer(),
          // CircularActionButton(
          //   iconSize: 24,
          //   onPressed: () => _showFormationInfoDialog(context),
          //   icon: CupertinoIcons.info,
          // ),
        ],
      ),
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Progress Circle and Stats

              // Weekly Progress Chart

              _WeeklyProgressChart(),
            ],
          ),
        ),
      ],
    );
  }

  // void _showFormationInfoDialog(BuildContext context) {
  //   showCupertinoDialog(
  //     context: context,
  //     builder: (context) => CupertinoAlertDialog(
  //       title: Text(
  //         LocaleKeys.habit_detail_probability_info_title.tr(),
  //         style: TextStyle(
  //           fontSize: 18,
  //           fontWeight: FontWeight.bold,
  //           color: context.titleLarge.color,
  //         ),
  //       ),
  //       content: Padding(
  //         padding: const EdgeInsets.only(top: 16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               LocaleKeys.habit_detail_probability_info_description.tr(),
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 color: context.bodyMedium.color,
  //                 height: 1.1,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         CupertinoDialogAction(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: Text(
  //             LocaleKeys.common_ok.tr(),
  //             style: TextStyle(
  //               color: Color(habit.colorCode),
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class _CircularProgress extends StatefulWidget {
  final double progress;
  final Color color;
  final Widget centerChild;

  const _CircularProgress({
    required this.progress,
    required this.color,
    required this.centerChild,
  });

  @override
  State<_CircularProgress> createState() => _CircularProgressState();
}

class _CircularProgressState extends State<_CircularProgress> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _CircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularProgressPainter(
              progress: _animation.value,
              color: widget.color,
            ),
            child: Center(child: widget.centerChild),
          );
        },
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WeeklyProgressChart extends ConsumerStatefulWidget {
  const _WeeklyProgressChart();

  @override
  ConsumerState<_WeeklyProgressChart> createState() => _WeeklyProgressChartState();
}

class _WeeklyProgressChartState extends ConsumerState<_WeeklyProgressChart> {
  final Map<String, bool> _decreasingModeByDateKey = {};

  @override
  Widget build(BuildContext context) {
    final habit = ref.watch(habitDetailProvider);
    if (habit == null) return const SizedBox.shrink();

    final habitStats = ref.watch(habitStatisticsProvider);
    // Use cached weekly data from statistics provider to avoid duplicate calculation
    // If not available yet, trigger calculation and show loading state
    final weeklyData = habitStats?.weeklyData;

    // Trigger statistics calculation if not already calculated
    if (weeklyData == null) {
      // Use Future.microtask to avoid build-time modification
      Future.microtask(() {
        ref.read(habitStatisticsProvider.notifier).calculateStatistics(habit);
      });
      // Return loading state while calculating
      return CupertinoListSection.insetGrouped(
        header: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              FontAwesomeIcons.chartPie,
              size: 20,
              color: Color(habit.colorCode),
            ),
            const SizedBox(width: 8),
            Text(
              LocaleKeys.habit_detail_last_7_days.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.titleLarge.color,
              ),
            ),
          ],
        ),
        children: [
          const CupertinoListTile(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            title: Center(child: CupertinoActivityIndicator()),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isCompleted = weeklyData[index];
            final today = DateUtils.dateOnly(DateTime.now());
            final dateForIndex = today.subtract(Duration(days: 6 - index));
            final isFuture = dateForIndex.isAfter(today);

            // Decide default mode based on current ratio at build time
            final dateKey = '${dateForIndex.year}-${dateForIndex.month}-${dateForIndex.day}';
            final ratio = weeklyData[index];
            if (ratio >= 1.0) {
              _decreasingModeByDateKey[dateKey] = true;
            } else if (ratio == 0.0) {
              _decreasingModeByDateKey[dateKey] = false;
            }

            return _WeeklyDayCell(
              index: index,
              isCompleted: isCompleted,
              habitColor: Color(habit.colorCode),
              date: dateForIndex,
              isDisabled: isFuture,
              onTap: () => _handleTap(index, habit),
              onLongPress: () => {},
            );
          }),
        ),
      ],
    );
  }

  Future<void> _adjustCompletion(int index, Habit habit, {required bool increment}) async {
    // Get the current habit from the provider to ensure we have the latest data
    final currentHabit = ref.read(habitDetailProvider);
    if (currentHabit == null) return;

    // Get ratio from cached statistics or calculate directly using extension method
    final habitStats = ref.read(habitStatisticsProvider);
    final weeklyData = habitStats?.weeklyData;
    final today = DateUtils.dateOnly(DateTime.now());
    final targetDate = today.subtract(Duration(days: 6 - index));
    final dateKey = '${targetDate.year}-${targetDate.month}-${targetDate.day}';
    final currentRatio = weeklyData != null && weeklyData.length > index ? weeklyData[index] : currentHabit.getCompletionRatioForDate(targetDate);

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Guard: Do not allow marking future dates
    if (targetDate.isAfter(today)) {
      return;
    }

    // Get before count for reward rating dialog
    final beforeCount = currentHabit.getCountForDate(targetDate);
    // final previousHabit = currentHabit;

    final completionEntry = CompletionEntry(
      id: dateKey,
      date: targetDate,
      // true -> increment count, false -> decrement count
      isCompleted: increment ? (currentRatio < 1.0) : false,
    );

    try {
      // Use the provider which will update both local state and home provider
      await ref.read(habitDetailProvider.notifier).markHabitAsComplete(currentHabit.id, completionEntry);

      // Show reward rating dialog for each increment in multi-completion mode
      if (increment) {
        // Get updated habit after completion
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted || !context.mounted) return;

        final updatedHabit = ref.read(habitDetailProvider);
        if (updatedHabit != null) {
          final afterCount = updatedHabit.getCountForDate(targetDate);

          // Show reward rating dialog if count increased
          if (afterCount > beforeCount) {
            // await _showRewardRatingDialog(
            //   context: context,
            //   updatedHabit: updatedHabit,
            //   previousHabit: previousHabit,
            //   targetDate: targetDate,
            //   dateKey: dateKey,
            // );
          }
        }
      }
    } catch (e, s) {
      // Handle error - could show a snackbar or dialog
      LogHelper.shared.errorPrint('Error updating completion: $e\nStacktrace:$s');
    }
  }

  // Future<void> _showRewardRatingDialog({
  //   required BuildContext context,
  //   required Habit updatedHabit,
  //   required Habit previousHabit,
  //   required DateTime targetDate,
  //   required String dateKey,
  // }) async {
  //   if (!mounted) return;
  //
  //   await Future.delayed(const Duration(milliseconds: 500));
  //   if (!mounted || !context.mounted) return;
  //
  //   // Show reward rating dialog (mandatory - user must select)
  //   // Dialog returns the selected rating when closed
  //   double? rewardRating;
  //   try {
  //     rewardRating = await showCupertinoDialog<double>(
  //       context: context,
  //       barrierDismissible: false, // User must select a rating
  //       builder: (dialogContext) => RewardRatingDialog(
  //         habit: updatedHabit,
  //       ),
  //     );
  //   } catch (e) {
  //     LogHelper.shared.errorPrint('Error showing reward rating dialog: $e');
  //     return;
  //   }
  //
  //   if (!mounted || rewardRating == null) return;
  //
  //   // Small delay to ensure dialog is fully closed before proceeding
  //   await Future.delayed(const Duration(milliseconds: 200));
  //   if (!mounted || !context.mounted) return;
  //
  //   // Get current completion entry
  //   final currentHabit = ref.read(habitDetailProvider);
  //   if (currentHabit == null) return;
  //
  //   final existingEntry = currentHabit.completions[dateKey];
  //   if (existingEntry != null) {
  //     // Update completion entry with reward rating
  //     final updatedEntry = existingEntry.copyWith(rewardRating: rewardRating);
  //     final updatedCompletions = Map<String, CompletionEntry>.from(currentHabit.completions);
  //     updatedCompletions[dateKey] = updatedEntry;
  //
  //     // Update habit locally
  //     final habitWithRating = currentHabit.copyWith(completions: updatedCompletions);
  //
  //     // Save to service via habit detail provider
  //     await ref.read(habitDetailProvider.notifier).updateHabit(habitWithRating);
  //   }
  // }

  Future<void> _handleTap(int index, Habit habit) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final targetDate = today.subtract(Duration(days: 6 - index));
    final dateKey = '${targetDate.year}-${targetDate.month}-${targetDate.day}';

    // Get ratio from cached statistics or calculate directly
    final habitStats = ref.read(habitStatisticsProvider);
    final weeklyData = habitStats?.weeklyData;
    final ratio = weeklyData != null && weeklyData.length > index ? weeklyData[index] : habit.getCompletionRatioForDate(targetDate);

    // Determine current mode
    bool isDecreasing = _decreasingModeByDateKey[dateKey] ?? false;
    if (ratio >= 1.0) {
      isDecreasing = true;
    } else if (ratio == 0.0) {
      isDecreasing = false;
    }

    // Choose direction: when decreasing, continue until 0; when increasing, continue until full
    final shouldIncrement = !isDecreasing;
    await _adjustCompletion(index, habit, increment: shouldIncrement);

    // Update mode after action based on new ratio estimate
    final target = habit.dailyTarget <= 0 ? 1 : habit.dailyTarget;
    final currentCount = habit.getCountForDate(targetDate);
    final nextCount = shouldIncrement ? (currentCount + 1).clamp(0, target) : (currentCount - 1).clamp(0, target);
    if (nextCount >= target) {
      _decreasingModeByDateKey[dateKey] = true;
    } else if (nextCount <= 0) {
      _decreasingModeByDateKey[dateKey] = false;
    }
    if (mounted) setState(() {});
  }
}

class _WeeklyDayCell extends StatefulWidget {
  final int index;
  final double isCompleted; // ratio 0..1
  final Color habitColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final DateTime date;
  final bool isDisabled;

  const _WeeklyDayCell({
    required this.index,
    required this.isCompleted,
    required this.habitColor,
    required this.onTap,
    this.onLongPress,
    required this.date,
    this.isDisabled = false,
  });

  @override
  State<_WeeklyDayCell> createState() => _WeeklyDayCellState();
}

class _WeeklyDayCellState extends State<_WeeklyDayCell> {
  @override
  Widget build(BuildContext context) {
    final weekdayLabels = {
      DateTime.monday: LocaleKeys.habit_detail_mon.tr(),
      DateTime.tuesday: LocaleKeys.habit_detail_tue.tr(),
      DateTime.wednesday: LocaleKeys.habit_detail_wed.tr(),
      DateTime.thursday: LocaleKeys.habit_detail_thu.tr(),
      DateTime.friday: LocaleKeys.habit_detail_fri.tr(),
      DateTime.saturday: LocaleKeys.habit_detail_sat.tr(),
      DateTime.sunday: LocaleKeys.habit_detail_sun.tr(),
    };

    return CustomButton(
      onPressed: widget.isDisabled ? null : widget.onTap,
      onLongPressed: widget.isDisabled ? null : widget.onLongPress,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.habitColor.withValues(alpha: (0.1 + (0.9 * widget.isCompleted)).clamp(0.1, 1.0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: widget.isCompleted >= 1.0
                  ? const Icon(
                      FontAwesomeIcons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weekdayLabels[widget.date.weekday] ?? '',
            style: TextStyle(
              fontSize: 10,
              color: (context.bodyMedium.color?.withValues(alpha: 0.6))?.withValues(alpha: widget.isDisabled ? 0.3 : 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressData {
  final double completionRate;
  final int currentStreak;
  final double streakProgress;
  final double formationProgress;
  final int thisMonthCompleted;
  final int thisMonthTotal;
  final double thisMonthRate;
  final List<double> weeklyData;

  const ProgressData({
    required this.completionRate,
    required this.currentStreak,
    required this.streakProgress,
    required this.formationProgress,
    required this.thisMonthCompleted,
    required this.thisMonthTotal,
    required this.thisMonthRate,
    required this.weeklyData,
  });
}
