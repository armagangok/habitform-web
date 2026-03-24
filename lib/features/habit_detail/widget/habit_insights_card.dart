import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/habit/habit_extension.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../../habit_probability/provider/habit_probability_provider.dart';
import '../../habit_probability/provider/habit_probability_state.dart';

class HabitInsightsCard extends ConsumerWidget {
  final Habit habit;

  const HabitInsightsCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formationState = ref.watch(probabilityProvider);

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
            LocaleKeys.habit_detail_insights_achievements.tr(),
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
    final currentStreak = habit.calculateCurrentStreak();
    final longestStreak = habit.calculateLongestStreak();
    final completionRate = habitStatistic?.progressPercentage ?? _calculateCompletionRate();

    final achievements = <Achievement>[];
    final insights = <InsightItem>[];

    // Achievements
    if (currentStreak >= 7) {
      achievements.add(
        Achievement(
          title: LocaleKeys.habit_detail_achievement_week_warrior.tr(),
          description: LocaleKeys.habit_detail_achievement_week_warrior_description.tr().replaceAll('{{streak}}', currentStreak.toString()),
          icon: FontAwesomeIcons.fire,
          color: Colors.orange,
          isNew: currentStreak == 7,
        ),
      );
    }

    if (currentStreak >= 30) {
      achievements.add(
        Achievement(
          title: LocaleKeys.habit_detail_achievement_monthly_master.tr(),
          description: LocaleKeys.habit_detail_achievement_monthly_master_description.tr(),
          icon: FontAwesomeIcons.medal,
          color: Colors.amber,
          isNew: currentStreak == 30,
        ),
      );
    }

    if (longestStreak >= 66) {
      achievements.add(
        Achievement(
          title: LocaleKeys.habit_detail_achievement_habit_hero.tr(),
          description: LocaleKeys.habit_detail_achievement_probability_threshold.tr(),
          icon: FontAwesomeIcons.crown,
          color: Colors.purple,
          isNew: longestStreak == 66,
        ),
      );
    }

    if (completionRate >= 90) {
      achievements.add(
        Achievement(
          title: LocaleKeys.habit_detail_achievement_perfectionist.tr(),
          description: LocaleKeys.habit_detail_achievement_perfectionist_description.tr().replaceAll('{{rate}}', completionRate.toStringAsFixed(0)),
          icon: FontAwesomeIcons.star,
          color: Colors.blue,
          isNew: false,
        ),
      );
    }

    // Insights
    if (currentStreak > longestStreak * 0.8) {
      insights.add(
        InsightItem(
          title: LocaleKeys.habit_detail_achievement_consistency_champion.tr(),
          description: LocaleKeys.habit_detail_achievement_consistency_description.tr().replaceAll('{{percentage}}', (currentStreak / longestStreak * 100).toStringAsFixed(0)),
          type: InsightType.positive,
        ),
      );
    }

    if (_isWeekendWarrior()) {
      insights.add(
        InsightItem(
          title: LocaleKeys.habit_detail_achievement_weekend_warrior.tr(),
          description: LocaleKeys.habit_detail_achievement_weekend_description.tr(),
          type: InsightType.positive,
        ),
      );
    }

    if (_getMissedDaysThisWeek() > 2) {
      insights.add(
        InsightItem(
          title: LocaleKeys.habit_detail_achievement_weekly_checkin.tr(),
          description: LocaleKeys.habit_detail_achievement_weekly_description.tr().replaceAll('{{days}}', _getMissedDaysThisWeek().toString()),
          type: InsightType.motivational,
        ),
      );
    }

    final probabilityProgress = habitStatistic?.probabilityScore ?? habit.calculateHabitProbability();
    if (probabilityProgress >= 50 && probabilityProgress < 100) {
      insights.add(
        InsightItem(
          title: LocaleKeys.habit_detail_achievement_probability_journey.tr(),
          description: LocaleKeys.habit_detail_achievement_probability_description.tr().replaceAll('{{percentage}}', probabilityProgress.toStringAsFixed(0)),
          type: InsightType.informational,
        ),
      );
    }

    return HabitInsights(
      achievements: achievements,
      insights: insights,
    );
  }

  double _calculateCompletionRate() {
    if (habit.completions.isEmpty) return 0.0;
    return habit.calculateWeightedProgressPercentageFromFirstCompletion();
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
      final isCompleted = habit.isDateCompleted(date);
      if (!isCompleted) {
        missedDays++;
      }
    }

    return missedDays;
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
          LocaleKeys.habit_detail_achievements.tr(),
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
              .map(
                (achievement) => _AchievementBadge(
                  achievement: achievement,
                ),
              )
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
                        LocaleKeys.habit_detail_new.tr(),
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
          LocaleKeys.habit_detail_smart_insights.tr(),
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
    final currentStreak = habit.calculateCurrentStreak();
    final completionRate = _calculateCompletionRate();

    if (currentStreak >= 30) {
      return MotivationalQuote(
        text: LocaleKeys.habit_detail_quote_aristotle.tr(),
        author: LocaleKeys.habit_detail_quote_aristotle_author.tr(),
      );
    } else if (completionRate >= 80) {
      return MotivationalQuote(
        text: LocaleKeys.habit_detail_quote_collier.tr(),
        author: LocaleKeys.habit_detail_quote_collier_author.tr(),
      );
    } else if (currentStreak >= 7) {
      return MotivationalQuote(
        text: LocaleKeys.habit_detail_quote_twain.tr(),
        author: LocaleKeys.habit_detail_quote_twain_author.tr(),
      );
    } else {
      return MotivationalQuote(
        text: LocaleKeys.habit_detail_quote_lao_tzu.tr(),
        author: LocaleKeys.habit_detail_quote_lao_tzu_author.tr(),
      );
    }
  }

  double _calculateCompletionRate() {
    if (habit.completions.isEmpty) return 0.0;
    return habit.calculateProgressPercentageFromFirstCompletion();
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
