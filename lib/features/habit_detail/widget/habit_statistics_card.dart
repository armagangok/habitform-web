import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/completion_entry/completion_extension.dart';
import '/models/models.dart';

class HabitStatisticsCard extends ConsumerWidget {
  final Habit habit;

  const HabitStatisticsCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = _calculateStatistics();

    return CupertinoCard(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.chartLine,
                size: 20,
                color: Color(habit.colorCode),
              ),
              const SizedBox(width: 8),
              Text(
                "Statistics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.titleLarge.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Statistics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.86,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _StatisticItem(
                title: "Current Streak",
                value: "${stats.currentStreak}",
                suffix: stats.currentStreak == 1 ? " day" : " days",
                icon: FontAwesomeIcons.fire,
                color: Colors.orange,
                trend: _getStreakTrend(stats.currentStreak, stats.longestStreak),
              ),
              _StatisticItem(
                title: "Best Streak",
                value: "${stats.longestStreak}",
                suffix: stats.longestStreak == 1 ? " day" : " days",
                icon: FontAwesomeIcons.trophy,
                color: Colors.amber,
              ),
              _StatisticItem(
                title: "Success Rate",
                value: stats.successRate.toStringAsFixed(1),
                suffix: "%",
                icon: FontAwesomeIcons.bullseye,
                color: Color(habit.colorCode),
                trend: _getSuccessRateTrend(stats.successRate),
              ),
              _StatisticItem(
                title: "Total Completed",
                value: "${stats.completedDays}",
                suffix: stats.completedDays == 1 ? " day" : " days",
                icon: FontAwesomeIcons.circleCheck,
                color: Colors.green,
              ),
              _StatisticItem(
                title: "Days Active",
                value: "${stats.totalDays}",
                suffix: stats.totalDays == 1 ? " day" : " days",
                icon: FontAwesomeIcons.calendar,
                color: Colors.blue,
              ),
              _StatisticItem(
                title: "Formation Progress",
                value: stats.formationProgress.toStringAsFixed(0),
                suffix: "%",
                icon: FontAwesomeIcons.seedling,
                color: Colors.purple,
                showProgressBar: true,
                progressValue: stats.formationProgress / 100,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Additional Insights
          _buildAdditionalInsights(stats),
        ],
      ),
    );
  }

  Widget _buildAdditionalInsights(HabitStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(habit.colorCode).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Habit Insights",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(habit.colorCode),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getInsightMessage(stats),
                style: TextStyle(
                  fontSize: 13,
                  color: Color(habit.colorCode).withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  HabitStatistics _calculateStatistics() {
    final currentStreak = habit.completions.calculateCurrentStreak();
    final longestStreak = habit.completions.calculateLongestStreak();

    if (habit.completions.isEmpty) {
      return HabitStatistics(
        currentStreak: 0,
        longestStreak: 0,
        successRate: 0.0,
        completedDays: 0,
        totalDays: 0,
        formationProgress: 0.0,
        startDate: DateTime.now(),
      );
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final sortedDates = habit.completions.values.map((e) => DateUtils.dateOnly(e.date)).toList()..sort();
    final startDate = sortedDates.first;
    final daysSinceStart = today.difference(startDate).inDays + 1;
    final completedEntries = habit.completions.values.where((e) => e.isCompleted).length;
    final successRate = daysSinceStart > 0 ? (completedEntries / daysSinceStart) * 100.0 : 0.0;

    // Calculate formation progress based on difficulty
    final estimatedFormationDays = 66; // Default formation days
    final formationProgress = (daysSinceStart / estimatedFormationDays * 100.0).clamp(0.0, 100.0);

    return HabitStatistics(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      successRate: successRate,
      completedDays: completedEntries,
      totalDays: daysSinceStart,
      formationProgress: formationProgress,
      startDate: startDate,
    );
  }

  StatTrend _getStreakTrend(int current, int longest) {
    if (current == longest && current > 0) return StatTrend.excellent;
    if (current >= longest * 0.8) return StatTrend.good;
    if (current >= longest * 0.5) return StatTrend.average;
    return StatTrend.needsWork;
  }

  StatTrend _getSuccessRateTrend(double rate) {
    if (rate >= 90) return StatTrend.excellent;
    if (rate >= 75) return StatTrend.good;
    if (rate >= 50) return StatTrend.average;
    return StatTrend.needsWork;
  }

  String _getInsightMessage(HabitStatistics stats) {
    if (stats.currentStreak >= 7) {
      return "🔥 You're on fire! A ${stats.currentStreak}-day streak is incredible. Keep up the momentum!";
    } else if (stats.successRate >= 80) {
      return "⭐ Your ${stats.successRate.toStringAsFixed(0)}% success rate shows great consistency. You're building a strong habit!";
    } else if (stats.formationProgress >= 50) {
      return "🌱 You're ${stats.formationProgress.toStringAsFixed(0)}% through the habit formation process. Stay committed!";
    } else if (stats.completedDays >= 30) {
      return "💪 With ${stats.completedDays} completed days, you're proving your dedication. Small steps lead to big changes!";
    } else {
      return "🚀 Every journey begins with a single step. You're ${stats.totalDays} days into building this habit!";
    }
  }
}

class _StatisticItem extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final IconData icon;
  final Color color;
  final StatTrend? trend;
  final bool showProgressBar;
  final double progressValue;

  const _StatisticItem({
    required this.title,
    required this.value,
    this.suffix = "",
    required this.icon,
    required this.color,
    this.trend,
    this.showProgressBar = false,
    this.progressValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 3),
              if (trend != null)
                Icon(
                  _getTrendIcon(),
                  size: 9,
                  color: _getTrendColor(),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.titleLarge.color,
                    ),
                    children: [
                      TextSpan(text: value),
                      if (suffix.isNotEmpty)
                        TextSpan(
                          text: suffix,
                          style: TextStyle(
                            fontSize: 9,
                            color: context.bodyMedium.color?.withValues(alpha: 0.7),
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    color: context.bodyMedium.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showProgressBar) ...[
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTrendIcon() {
    switch (trend!) {
      case StatTrend.excellent:
        return FontAwesomeIcons.arrowTrendUp;
      case StatTrend.good:
        return FontAwesomeIcons.arrowUp;
      case StatTrend.average:
        return FontAwesomeIcons.minus;
      case StatTrend.needsWork:
        return FontAwesomeIcons.arrowDown;
    }
  }

  Color _getTrendColor() {
    switch (trend!) {
      case StatTrend.excellent:
        return Colors.green;
      case StatTrend.good:
        return Colors.lightGreen;
      case StatTrend.average:
        return Colors.orange;
      case StatTrend.needsWork:
        return Colors.red;
    }
  }
}

class HabitStatistics {
  final int currentStreak;
  final int longestStreak;
  final double successRate;
  final int completedDays;
  final int totalDays;
  final double formationProgress;
  final DateTime startDate;

  const HabitStatistics({
    required this.currentStreak,
    required this.longestStreak,
    required this.successRate,
    required this.completedDays,
    required this.totalDays,
    required this.formationProgress,
    required this.startDate,
  });
}

enum StatTrend {
  excellent,
  good,
  average,
  needsWork,
}
