import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/completion_entry/completion_extension.dart';
import '/models/habit/habit_difficulty.dart';
import '/models/models.dart';
import '../../habit_formation/provider/habit_formation_provider.dart';
import '../../habit_formation/provider/habit_formation_state.dart';
import '../providers/habit_detail_provider.dart';

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
        mainAxisSize: MainAxisSize.min,
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
        ],
      ),
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Progress Circle and Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Progress Circle
                  Consumer(
                    builder: (context, ref, child) {
                      final currentHabit = ref.watch(habitDetailProvider);
                      final formationState = ref.watch(formationProvider);

                      // Get habit statistic from formation provider
                      HabitStatistic? habitStatistic;
                      if (formationState.hasValue && formationState.value != null) {
                        habitStatistic = formationState.value!.habitStatistics[habit.id];
                      }

                      final currentProgressData = _calculateProgressData(currentHabit ?? habit, habitStatistic);
                      return _CircularProgress(
                        progress: currentProgressData.formationProgress / 100,
                        color: Color(habit.colorCode),
                        centerChild: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${currentProgressData.formationProgress.toStringAsFixed(0)}%",
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

                  // Progress Stats
                ],
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

  ProgressData _calculateProgressData(Habit habit, HabitStatistic? habitStatistic) {
    if (habit.completions.isEmpty) {
      return ProgressData(
        completionRate: 0.0,
        currentStreak: 0,
        streakProgress: 0.0,
        formationProgress: 0.0,
        thisMonthCompleted: 0,
        thisMonthTotal: 0,
        thisMonthRate: 0.0,
        weeklyData: List.filled(7, 0.0),
      );
    }

    // Use formation provider data if available, otherwise fallback to local calculation
    final completionRate = habitStatistic?.progressPercentage ?? habit.completions.calculateProgressPercentage();
    final formationProgress = habitStatistic?.formationProbability ?? _calculateLocalFormationProbability(habit);

    // Calculate streaks using extension methods (these are not in formation provider yet)
    final currentStreak = habit.completions.calculateCurrentStreak();
    final longestStreak = habit.completions.calculateLongestStreak();
    final streakProgress = longestStreak > 0 ? (currentStreak / longestStreak).clamp(0.0, 1.0) : 0.0;

    // This month data using extension method
    final now = DateTime.now();
    final thisMonthCompletions = habit.completions.getCompletionsForMonth(now.year, now.month);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final thisMonthRate = thisMonthCompletions.length / daysInMonth;

    // Weekly data (last 7 days) using extension method
    final today = DateUtils.dateOnly(DateTime.now());
    final weeklyData = <double>[];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final isCompleted = habit.completions.isDateCompleted(date);
      weeklyData.add(isCompleted ? 1.0 : 0.0);
    }

    return ProgressData(
      completionRate: completionRate,
      currentStreak: currentStreak,
      streakProgress: streakProgress,
      formationProgress: formationProgress,
      thisMonthCompleted: thisMonthCompletions.length,
      thisMonthTotal: daysInMonth,
      thisMonthRate: thisMonthRate,
      weeklyData: weeklyData,
    );
  }

  // Calculate formation probability locally when provider data is not available
  double _calculateLocalFormationProbability(Habit habit) {
    if (habit.completions.isEmpty) return 0.0;

    // Use a dummy date since the method now uses first completion date internally
    final dummyDate = DateTime.now();

    return habit.completions.calculateFormationProbability(
      dummyDate, // This parameter is now ignored, but kept for compatibility
      habit.difficulty.estimatedFormationDays,
      habit.difficulty.minimumCompletionRate,
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
  @override
  Widget build(BuildContext context) {
    final habit = ref.watch(habitDetailProvider);
    if (habit == null) return const SizedBox.shrink();

    final weeklyData = _getWeeklyData(habit);

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

            return _WeeklyDayCell(
              index: index,
              isCompleted: isCompleted,
              habitColor: Color(habit.colorCode),
              onTap: () => _toggleCompletion(index, habit),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _toggleCompletion(int index, Habit habit) async {
    // Get the current habit from the provider to ensure we have the latest data
    final currentHabit = ref.read(habitDetailProvider);
    if (currentHabit == null) return;

    final isCurrentlyCompleted = _getWeeklyData(currentHabit)[index];

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Update completion status using the provider
    final today = DateUtils.dateOnly(DateTime.now());
    final targetDate = today.subtract(Duration(days: 6 - index));

    final completionEntry = CompletionEntry(
      id: '${targetDate.year}-${targetDate.month}-${targetDate.day}',
      date: targetDate,
      isCompleted: !isCurrentlyCompleted,
    );

    try {
      // Use the provider which will update both local state and home provider
      await ref.read(habitDetailProvider.notifier).markHabitAsComplete(currentHabit.id, completionEntry);
    } catch (e, s) {
      // Handle error - could show a snackbar or dialog
      LogHelper.shared.errorPrint('Error updating completion: $e\nStacktrace:$s');
    }
  }

  List<bool> _getWeeklyData(Habit habit) {
    final today = DateUtils.dateOnly(DateTime.now());
    final weeklyData = <bool>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final isCompleted = habit.completions.isDateCompleted(date);
      weeklyData.add(isCompleted);
    }

    return weeklyData;
  }
}

class _WeeklyDayCell extends StatefulWidget {
  final int index;
  final bool isCompleted;
  final Color habitColor;
  final VoidCallback onTap;

  const _WeeklyDayCell({
    required this.index,
    required this.isCompleted,
    required this.habitColor,
    required this.onTap,
  });

  @override
  State<_WeeklyDayCell> createState() => _WeeklyDayCellState();
}

class _WeeklyDayCellState extends State<_WeeklyDayCell> {
  @override
  Widget build(BuildContext context) {
    final days = [LocaleKeys.habit_detail_mon.tr(), LocaleKeys.habit_detail_tue.tr(), LocaleKeys.habit_detail_wed.tr(), LocaleKeys.habit_detail_thu.tr(), LocaleKeys.habit_detail_fri.tr(), LocaleKeys.habit_detail_sat.tr(), LocaleKeys.habit_detail_sun.tr()];

    return CustomButton(
      onPressed: widget.onTap,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: widget.isCompleted ? widget.habitColor : widget.habitColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: widget.isCompleted
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
            days[widget.index],
            style: TextStyle(
              fontSize: 10,
              color: context.bodyMedium.color?.withValues(alpha: 0.6),
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
