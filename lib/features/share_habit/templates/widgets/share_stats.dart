import '../../../../models/completion_entry/completion_extension.dart';
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
  final map = habit.completions;
  final now = DateTime.now();
  final thisMonth = map.getCompletionsForMonth(now.year, now.month);

  final current = map.calculateCurrentStreak();
  final longest = map.calculateLongestStreak();
  final completed = map.values.where((e) => e.isCompleted).length;
  final percent = map.calculateProgressPercentageFromFirstCompletion();

  return ShareStats(
    currentStreak: current,
    longestStreak: longest,
    completedDays: completed,
    progressPercent: percent,
    thisMonthCompleted: thisMonth.length,
  );
}
