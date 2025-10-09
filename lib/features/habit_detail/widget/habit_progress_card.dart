import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitform/models/habit/habit_extension.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_entry.dart';
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
            LocaleKeys.habit_detail_progress.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.titleLarge.color,
            ),
          ),
          const Spacer(),
          CircularActionButton(
            iconSize: 24,
            onPressed: () => _showFormationInfoDialog(context),
            icon: CupertinoIcons.info,
          ),
        ],
      ),
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Progress Circle and Stats
              Center(
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentHabit = ref.watch(habitDetailProvider);
                    final habitStats = ref.watch(habitStatisticsProvider);

                    // Calculate statistics if not cached or invalid (using Future.microtask to avoid build-time modification)
                    if (habitStats == null || !habitStats.isValid) {
                      Future.microtask(() {
                        ref.read(habitStatisticsProvider.notifier).calculateStatistics(currentHabit ?? habit);
                      });
                    }

                    final formationProgress = habitStats?.formationProgress ?? 0.0;
                    return _CircularProgress(
                      progress: formationProgress / 100,
                      color: Color(habit.colorCode),
                      centerChild: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${formationProgress.clamp(0, 99).toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.titleLarge.color,
                            ),
                          ),
                          Text(
                            LocaleKeys.habit_detail_formation.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.bodyMedium.color?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Weekly Progress Chart
              _WeeklyProgressChart(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  void _showFormationInfoDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          LocaleKeys.habit_detail_probability_info_title.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.titleLarge.color,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.habit_detail_probability_info_description.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: context.bodyMedium.color,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              LocaleKeys.common_ok.tr(),
              style: TextStyle(
                color: Color(habit.colorCode),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    final weeklyData = habitStats?.weeklyData ?? _getWeeklyData(habit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.habit_detail_last_7_days.tr(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.titleLarge.color,
          ),
        ),
        const SizedBox(height: 12),
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

    final currentRatio = _getWeeklyData(currentHabit)[index];

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Update completion status using the provider
    final today = DateUtils.dateOnly(DateTime.now());
    final targetDate = today.subtract(Duration(days: 6 - index));

    // Guard: Do not allow marking future dates
    if (targetDate.isAfter(today)) {
      return;
    }

    final completionEntry = CompletionEntry(
      id: '${targetDate.year}-${targetDate.month}-${targetDate.day}',
      date: targetDate,
      // true -> increment count, false -> decrement count
      isCompleted: increment ? (currentRatio < 1.0) : false,
    );

    try {
      // Use the provider which will update both local state and home provider
      await ref.read(habitDetailProvider.notifier).markHabitAsComplete(currentHabit.id, completionEntry);
    } catch (e, s) {
      // Handle error - could show a snackbar or dialog
      LogHelper.shared.errorPrint('Error updating completion: $e\nStacktrace:$s');
    }
  }

  Future<void> _handleTap(int index, Habit habit) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final targetDate = today.subtract(Duration(days: 6 - index));
    final dateKey = '${targetDate.year}-${targetDate.month}-${targetDate.day}';
    final ratio = _getWeeklyData(habit)[index];

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

  List<double> _getWeeklyData(Habit habit) {
    final today = DateUtils.dateOnly(DateTime.now());
    final weeklyData = <double>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final ratio = habit.getCompletionRatioForDate(date);
      weeklyData.add(ratio);
    }

    return weeklyData;
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
