import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../../edit_habit/edit_habit_page.dart';
import '../../edit_habit/provider/edit_habit_provider.dart';
import '../providers/habit_detail_provider.dart';
import '../widget/habit_heatmap_card.dart';
import '../widget/habit_insights_card.dart';
import '../widget/habit_milestones_card.dart';
import '../widget/habit_progress_card.dart';
import '../widget/habit_statistics_card.dart';
import '../widget/modern_action_buttons.dart';

class HabitDetailPage extends ConsumerWidget {
  const HabitDetailPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentHabit = ref.watch(habitDetailProvider);

    if (currentHabit == null) {
      return const SizedBox.shrink();
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // SliverAppBar with habit header
              _buildSliverAppBar(context, currentHabit, ref),

              // Progress card
              SliverToBoxAdapter(
                child: HabitProgressCard(habit: currentHabit),
              ),

              // Statistics card
              SliverToBoxAdapter(
                child: HabitStatisticsCard(habit: currentHabit),
              ),

              // Heatmap card
              SliverToBoxAdapter(
                child: HabitHeatmapCard(habit: currentHabit),
              ),

              // Milestones card
              SliverToBoxAdapter(
                child: HabitMilestonesCard(habit: currentHabit),
              ),

              // Insights card
              SliverToBoxAdapter(
                child: HabitInsightsCard(habit: currentHabit),
              ),

              // Bottom spacing for safe area
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          ActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Habit habit, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 190.0,
      floating: false,
      pinned: true,
      backgroundColor: context.scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        habit.habitName,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.titleLarge.color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(habit.colorCode).withValues(alpha: 0.3),
                Color(habit.colorCode).withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _habitEmoji(context, habit),
                const SizedBox(height: 16),
                if (habit.habitDescription != null && habit.habitDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32) + const EdgeInsets.only(bottom: 16),
                    child: Text(
                      habit.habitDescription!,
                      style: TextStyle(
                        color: context.bodyMedium.color?.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(13.0),
        child: CircularActionButton(
          icon: CupertinoIcons.back,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: CircularActionButton(
            icon: CupertinoIcons.pencil,
            onPressed: () {
              ref.watch(editHabitProvider.notifier).initHabit(habit);
              showCupertinoSheet(
                enableDrag: false,
                context: context,
                builder: (context) => EditHabitPage(habit: habit),
              );
            },
          ),
        ),
      ],
    );
  }

  Container _habitEmoji(BuildContext context, Habit habit) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: context.cupertinoTheme.scaffoldBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Color(habit.colorCode).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(habit.colorCode).withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          habit.emoji ?? "🎯",
          style: const TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}
