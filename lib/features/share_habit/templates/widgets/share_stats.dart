import 'package:habitform/models/habit/habit_extension.dart';

import '../../../../models/habit/habit_model.dart';

class ShareStats {
  final int currentStreak;
  final int longestStreak;
  final int completedDays;
  final double progressPercent; // 0..1
  final int thisMonthCompleted;

  const ShareStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.completedDays,
    required this.progressPercent,
    required this.thisMonthCompleted,
  });
}

ShareStats buildShareStats(Habit habit) {
  final now = DateTime.now();
  final thisMonth = habit.getCompletionsForMonth(now.year, now.month);

  final current = habit.calculateCurrentStreak();
  final longest = habit.calculateLongestStreak();
  final completed = habit.completions.values.where((e) => e.isCompleted).length;
  final percent = habit.calculateProgressPercentageFromFirstCompletion();

  return ShareStats(
    currentStreak: current,
    longestStreak: longest,
    completedDays: completed,
    progressPercent: percent,
    thisMonthCompleted: thisMonth.length,
  );
}
