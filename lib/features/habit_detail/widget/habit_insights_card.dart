import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/habit_formation/provider/habit_formation_provider.dart';
import '/models/completion_entry/completion_extension.dart';
import '/models/habit/habit_difficulty.dart';
import '/models/models.dart';
import '../../habit_formation/provider/habit_formation_state.dart';

class HabitInsightsCard extends ConsumerWidget {
  final Habit habit;

  const HabitInsightsCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formationState = ref.watch(formationProvider);

    // Get habit statistic from formation provider
    HabitStatistic? habitStatistic;
    if (formationState.hasValue && formationState.value != null) {
      habitStatistic = formationState.value!.habitStatistics[habit.id];
    }

    final insights = _generateInsights(habitStatistic);

    return CupertinoListSection.insetGrouped(
      header: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.lightbulb,
            size: 20,
            color: Color(habit.colorCode),
          ),
          const SizedBox(width: 8),
          Text(
            "Insights & Achievements",
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
              // Achievements
              if (insights.achievements.isNotEmpty) ...[
                _AchievementsSection(achievements: insights.achievements, habit: habit),
                const SizedBox(height: 16),
              ],

              // Insights
              _InsightsSection(insights: insights.insights, habit: habit),

              const SizedBox(height: 16),

              // Motivation Quote
              _MotivationCard(habit: habit, insights: insights),
            ],
          ),
        ),
      ],
    );
  }

  HabitInsights _generateInsights(HabitStatistic? habitStatistic) {
    final currentStreak = habit.completions.calculateCurrentStreak();
    final longestStreak = habit.completions.calculateLongestStreak();
    final completionRate = habitStatistic?.progressPercentage ?? _calculateCompletionRate();

    final achievements = <Achievement>[];
    final insights = <InsightItem>[];

    // Achievements
    if (currentStreak >= 7) {
      achievements.add(Achievement(
        title: "Week Warrior",
        description: "$currentStreak day streak!",
        icon: FontAwesomeIcons.fire,
        color: Colors.orange,
        isNew: currentStreak == 7,
      ));
    }

    if (currentStreak >= 30) {
      achievements.add(Achievement(
        title: "Monthly Master",
        description: "30+ day streak!",
        icon: FontAwesomeIcons.medal,
        color: Colors.amber,
        isNew: currentStreak == 30,
      ));
    }

    if (longestStreak >= 66) {
      achievements.add(Achievement(
        title: "Habit Hero",
        description: "Reached the formation threshold!",
        icon: FontAwesomeIcons.crown,
        color: Colors.purple,
        isNew: longestStreak == 66,
      ));
    }

    if (completionRate >= 90) {
      achievements.add(Achievement(
        title: "Perfectionist",
        description: "${completionRate.toStringAsFixed(0)}% success rate!",
        icon: FontAwesomeIcons.star,
        color: Colors.blue,
        isNew: false,
      ));
    }

    // Insights
    if (currentStreak > longestStreak * 0.8) {
      insights.add(InsightItem(
        title: "Consistency Champion",
        description: "You're performing at ${(currentStreak / longestStreak * 100).toStringAsFixed(0)}% of your best streak!",
        type: InsightType.positive,
      ));
    }

    if (_isWeekendWarrior()) {
      insights.add(InsightItem(
        title: "Weekend Warrior",
        description: "You maintain great consistency even on weekends!",
        type: InsightType.positive,
      ));
    }

    if (_getMissedDaysThisWeek() > 2) {
      insights.add(InsightItem(
        title: "Weekly Check-in",
        description: "You've missed ${_getMissedDaysThisWeek()} days this week. Tomorrow is a fresh start!",
        type: InsightType.motivational,
      ));
    }

    final formationProgress = habitStatistic?.formationProbability ?? _getFormationProgress();
    if (formationProgress >= 50 && formationProgress < 100) {
      insights.add(InsightItem(
        title: "Formation Journey",
        description: "You're ${formationProgress.toStringAsFixed(0)}% through building this habit. The neural pathways are strengthening!",
        type: InsightType.informational,
      ));
    }

    return HabitInsights(
      achievements: achievements,
      insights: insights,
    );
  }

  double _calculateCompletionRate() {
    if (habit.completions.isEmpty) return 0.0;
    return habit.completions.calculateProgressPercentage();
  }

  bool _isWeekendWarrior() {
    int weekendCompletions = 0;
    int totalWeekends = 0;

    for (final entry in habit.completions.values) {
      final date = entry.date;
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        totalWeekends++;
        if (entry.isCompleted) {
          weekendCompletions++;
        }
      }
    }

    return totalWeekends > 0 && (weekendCompletions / totalWeekends) >= 0.8;
  }

  int _getMissedDaysThisWeek() {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    int missedDays = 0;
    for (int i = 0; i < today.weekday; i++) {
      final date = DateUtils.dateOnly(startOfWeek.add(Duration(days: i)));
      final isCompleted = habit.completions.isDateCompleted(date);
      if (!isCompleted) {
        missedDays++;
      }
    }

    return missedDays;
  }

  double _getFormationProgress() {
    // Fallback calculation when provider data is not available
    final estimatedFormationDays = habit.difficulty.estimatedFormationDays;
    return habit.completions.calculateFormationProgress(estimatedFormationDays) * 100.0;
  }
}

class _AchievementsSection extends StatelessWidget {
  final List<Achievement> achievements;
  final Habit habit;

  const _AchievementsSection({required this.achievements, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Achievements",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.titleLarge.color,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: achievements
              .map((achievement) => _AchievementBadge(
                    achievement: achievement,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;

  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: achievement.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            achievement.icon,
            size: 14,
            color: achievement.color,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: context.titleLarge.color,
                    ),
                  ),
                  if (achievement.isNew) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "NEW",
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 10,
                  color: achievement.color.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightsSection extends StatelessWidget {
  final List<InsightItem> insights;
  final Habit habit;

  const _InsightsSection({required this.insights, required this.habit});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Smart Insights",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.titleLarge.color,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => _InsightItem(insight: insight)),
      ],
    );
  }
}

class _InsightItem extends StatelessWidget {
  final InsightItem insight;

  const _InsightItem({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getInsightColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getInsightColor().withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getInsightIcon(),
            size: 16,
            color: _getInsightColor(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.titleLarge.color,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 2),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.bodyMedium.color?.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                  maxLines: 999,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getInsightColor() {
    switch (insight.type) {
      case InsightType.positive:
        return Colors.green;
      case InsightType.motivational:
        return Colors.orange;
      case InsightType.informational:
        return Colors.blue;
    }
  }

  IconData _getInsightIcon() {
    switch (insight.type) {
      case InsightType.positive:
        return FontAwesomeIcons.thumbsUp;
      case InsightType.motivational:
        return FontAwesomeIcons.rocket;
      case InsightType.informational:
        return FontAwesomeIcons.circleInfo;
    }
  }
}

class _MotivationCard extends StatelessWidget {
  final Habit habit;
  final HabitInsights insights;

  const _MotivationCard({required this.habit, required this.insights});

  @override
  Widget build(BuildContext context) {
    final quote = _getMotivationalQuote();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(habit.colorCode).withValues(alpha: 0.8),
            Color(habit.colorCode).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.quoteLeft,
            size: 16,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 8),
          Text(
            quote.text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 999,
          ),
          const SizedBox(height: 8),
          Text(
            "— ${quote.author}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 999,
          ),
        ],
      ),
    );
  }

  MotivationalQuote _getMotivationalQuote() {
    final currentStreak = habit.completions.calculateCurrentStreak();
    final completionRate = _calculateCompletionRate();

    if (currentStreak >= 30) {
      return MotivationalQuote(
        text: "Excellence is not a single act, but a habit. You are not what you do once in a while; you are what you do consistently.",
        author: "Aristotle",
      );
    } else if (completionRate >= 80) {
      return MotivationalQuote(
        text: "Success is the sum of small efforts, repeated day in and day out.",
        author: "Robert Collier",
      );
    } else if (currentStreak >= 7) {
      return MotivationalQuote(
        text: "The secret to getting ahead is getting started.",
        author: "Mark Twain",
      );
    } else {
      return MotivationalQuote(
        text: "A journey of a thousand miles begins with a single step.",
        author: "Lao Tzu",
      );
    }
  }

  double _calculateCompletionRate() {
    if (habit.completions.isEmpty) return 0.0;
    return habit.completions.calculateProgressPercentageFromFirstCompletion();
  }
}

class HabitInsights {
  final List<Achievement> achievements;
  final List<InsightItem> insights;

  const HabitInsights({
    required this.achievements,
    required this.insights,
  });
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isNew;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isNew = false,
  });
}

class InsightItem {
  final String title;
  final String description;
  final InsightType type;

  const InsightItem({
    required this.title,
    required this.description,
    required this.type,
  });
}

enum InsightType {
  positive,
  motivational,
  informational,
}

class MotivationalQuote {
  final String text;
  final String author;

  const MotivationalQuote({
    required this.text,
    required this.author,
  });
}
