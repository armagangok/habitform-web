import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_entry.dart';
import '/models/completion_entry/completion_extension.dart';
import '/models/models.dart';
import '../providers/habit_detail_provider.dart';

class HabitProgressCard extends ConsumerWidget {
  final Habit habit;

  const HabitProgressCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressData = _calculateProgressData(habit);

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
            "Progress",
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
                children: [
                  // Main Progress Circle
                  Expanded(
                    flex: 2,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final currentHabit = ref.watch(habitDetailProvider);
                        final currentProgressData = _calculateProgressData(currentHabit ?? habit);
                        return _CircularProgress(
                          progress: currentProgressData.completionRate / 100,
                          color: Color(habit.colorCode),
                          centerChild: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${currentProgressData.completionRate.toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: context.titleLarge.color,
                                ),
                              ),
                              Text(
                                "Success Rate",
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

                  const SizedBox(width: 24),

                  // Progress Stats
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProgressStatRow(
                          icon: FontAwesomeIcons.fire,
                          color: Colors.orange,
                          title: "Current Streak",
                          value: "${progressData.currentStreak} days",
                          progress: progressData.streakProgress,
                        ),
                        const SizedBox(height: 12),
                        _ProgressStatRow(
                          icon: FontAwesomeIcons.seedling,
                          color: Colors.green,
                          title: "Formation",
                          value: "${progressData.formationProgress.toStringAsFixed(0)}%",
                          progress: progressData.formationProgress / 100,
                        ),
                        const SizedBox(height: 12),
                        _ProgressStatRow(
                          icon: FontAwesomeIcons.calendar,
                          color: Colors.blue,
                          title: "This Month",
                          value: "${progressData.thisMonthCompleted}/${progressData.thisMonthTotal}",
                          progress: progressData.thisMonthRate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Weekly Progress Chart
              _WeeklyProgressChart(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  ProgressData _calculateProgressData(Habit habit) {
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

    final today = DateUtils.dateOnly(DateTime.now());
    final sortedDates = habit.completions.values.map((e) => DateUtils.dateOnly(e.date)).toList()..sort();
    final startDate = sortedDates.first;
    final daysSinceStart = today.difference(startDate).inDays + 1;
    final completedEntries = habit.completions.values.where((e) => e.isCompleted).length;
    final completionRate = daysSinceStart > 0 ? (completedEntries / daysSinceStart) * 100.0 : 0.0;

    final currentStreak = habit.completions.calculateCurrentStreak();
    final longestStreak = habit.completions.calculateLongestStreak();
    final streakProgress = longestStreak > 0 ? (currentStreak / longestStreak).clamp(0.0, 1.0) : 0.0;

    final estimatedFormationDays = 66; // Default formation days
    final formationProgress = (daysSinceStart / estimatedFormationDays * 100.0).clamp(0.0, 100.0);

    // This month data
    final now = DateTime.now();
    final thisMonthCompletions = habit.completions.getCompletionsForMonth(now.year, now.month);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final thisMonthRate = thisMonthCompletions.length / daysInMonth;

    // Weekly data (last 7 days)
    final weeklyData = <double>[];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final isCompleted = habit.completions.values.any((entry) => DateUtils.isSameDay(DateUtils.dateOnly(entry.date), date) && entry.isCompleted);
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

class _ProgressStatRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final double progress;

  const _ProgressStatRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: context.bodyMedium.color?.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.titleLarge.color,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

class _WeeklyProgressChart extends ConsumerStatefulWidget {
  const _WeeklyProgressChart();

  @override
  ConsumerState<_WeeklyProgressChart> createState() => _WeeklyProgressChartState();
}

class _WeeklyProgressChartState extends ConsumerState<_WeeklyProgressChart> with TickerProviderStateMixin {
  late AnimationController _lottieController;
  int? _animatingIndex;
  bool _showLottieAnimation = false;
  Timer? _animationTimeout;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationTimeout?.cancel();
    _lottieController.dispose();
    super.dispose();
  }

  void _resetAnimationState() {
    if (mounted) {
      _animationTimeout?.cancel();
      setState(() {
        _lottieController.reset();
        _animatingIndex = null;
        _showLottieAnimation = false;
      });
    }
  }

  Future<void> _toggleCompletion(int index, Habit habit) async {
    // Prevent multiple simultaneous toggles on the same cell
    if (_animatingIndex == index) return;

    // Get the current habit from the provider to ensure we have the latest data
    final currentHabit = ref.read(habitDetailProvider);
    if (currentHabit == null) return;

    final isCurrentlyCompleted = _getWeeklyData(currentHabit)[index];

    // Set Lottie animation state
    _animatingIndex = index;
    _showLottieAnimation = !isCurrentlyCompleted;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Start Lottie animation
    if (_showLottieAnimation) {
      _lottieController.forward();
    }

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

      // Wait a bit to ensure state is properly updated
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // Handle error - could show a snackbar or dialog
      print('Error updating completion: $e');
    } finally {
      // Always reset animation state, even if there was an error
      // Cancel any existing timeout
      _animationTimeout?.cancel();
      // Set a new timeout to reset the animation state
      _animationTimeout = Timer(const Duration(milliseconds: 1400), () {
        _resetAnimationState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = ref.watch(habitDetailProvider);
    if (habit == null) return const SizedBox.shrink();

    // Safety check: reset animation state if it's been stuck for too long
    if (_animatingIndex != null) {
      _animationTimeout?.cancel();
      _animationTimeout = Timer(const Duration(milliseconds: 2000), () {
        _resetAnimationState();
      });
    }

    final weeklyData = _getWeeklyData(habit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Last 7 Days",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.titleLarge.color,
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
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
            // Lottie animation overlay
            if (_showLottieAnimation && _animatingIndex != null)
              Positioned(
                left: _animatingIndex! * (MediaQuery.of(context).size.width - 32) / 7 + 16 - 30,
                top: -30,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Lottie.asset(
                    'assets/animations/completion.json',
                    controller: _lottieController,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to a simple checkmark animation if Lottie fails
                      return AnimatedBuilder(
                        animation: _lottieController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _lottieController.value,
                            child: Icon(
                              FontAwesomeIcons.check,
                              size: 30,
                              color: Color(habit.colorCode),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<bool> _getWeeklyData(Habit habit) {
    final today = DateUtils.dateOnly(DateTime.now());
    final weeklyData = <bool>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final isCompleted = habit.completions.values.any((entry) => DateUtils.isSameDay(DateUtils.dateOnly(entry.date), date) && entry.isCompleted);
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

class _WeeklyDayCellState extends State<_WeeklyDayCell> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    _animationController.forward().then((_) {
      _animationController.reset();
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          _startAnimation();
          widget.onTap();
        },
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isAnimating ? _scaleAnimation.value : 1.0,
                  child: Transform.rotate(
                    angle: _isAnimating && widget.isCompleted ? _rotationAnimation.value * 0.1 : 0.0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.isCompleted ? widget.habitColor : widget.habitColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _isAnimating && widget.isCompleted
                            ? [
                                BoxShadow(
                                  color: widget.habitColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: widget.isCompleted
                            ? FadeTransition(
                                opacity: _fadeAnimation,
                                child: const Icon(
                                  FontAwesomeIcons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                );
              },
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
