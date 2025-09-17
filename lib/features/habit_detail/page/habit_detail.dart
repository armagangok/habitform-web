import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../../edit_habit/edit_habit_page.dart';
import '../../edit_habit/provider/edit_habit_provider.dart';
import '../providers/habit_detail_provider.dart';
import '../widget/habit_heatmap_card.dart';
import '../widget/habit_insights_card.dart';
import '../widget/habit_milestones_card.dart';
import '../widget/habit_overview_widget.dart';
import '../widget/habit_progress_card.dart';
import '../widget/modern_action_buttons.dart';

class HabitDetailPage extends ConsumerStatefulWidget {
  const HabitDetailPage({super.key});

  @override
  ConsumerState<HabitDetailPage> createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends ConsumerState<HabitDetailPage> {
  final ScrollController _scrollController = ScrollController();
  static const double _expandedHeight = 200.0;
  double _collapseFraction = 0.0; // 0.0 expanded → 1.0 collapsed

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Compute collapse fraction based on current offset
    final double maxScroll = (_expandedHeight - kToolbarHeight).clamp(0.0, double.infinity);
    if (maxScroll <= 0) return;
    final double newFraction = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    if ((newFraction - _collapseFraction).abs() > 0.02) {
      setState(() => _collapseFraction = newFraction);
    }
  }

  Color _resolveTitleColor(BuildContext context, Habit habit) {
    // When expanded, prefer on-primary contrast (white). When collapsed, use default title color.
    final Color expandedColor = Colors.white;
    final Color collapsedColor = context.titleLarge.color ?? Colors.black;
    return Color.lerp(expandedColor, collapsedColor, _collapseFraction) ?? collapsedColor;
  }

  (Color icon, Color bg) _resolveIconColors(BuildContext context) {
    final Color expandedIcon = Colors.white;
    final Color collapsedIcon = context.titleLarge.color ?? Colors.black;
    final Color expandedBg = Colors.white.withValues(alpha: 0.18);
    final Color collapsedBg = context.cupertinoTheme.barBackgroundColor.withValues(alpha: 0.11);
    final icon = Color.lerp(expandedIcon, collapsedIcon, _collapseFraction) ?? collapsedIcon;
    final bg = Color.lerp(expandedBg, collapsedBg, _collapseFraction) ?? collapsedBg;
    return (icon, bg);
  }

  @override
  Widget build(BuildContext context) {
    final currentHabit = ref.watch(habitDetailProvider);

    if (currentHabit == null) {
      return const SizedBox.shrink();
    }

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SliverAppBar with habit header
              _buildSliverAppBar(context, currentHabit),

              // Progress card
              SliverToBoxAdapter(
                child: HabitProgressCard(habit: currentHabit),
              ),

              // Overview widget (moved from Statistics page)
              SliverToBoxAdapter(
                child: HabitOverviewWidget(habit: currentHabit),
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

  Widget _buildSliverAppBar(BuildContext context, Habit habit) {
    final titleColor = _resolveTitleColor(context, habit);
    final (iconColor, iconBg) = _resolveIconColors(context);
    return SliverAppBar(
      expandedHeight: _expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: context.scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        habit.habitName,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: titleColor,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(habit.colorCode).withValues(alpha: 0.8),
                Color(habit.colorCode).withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _habitEmoji(context, habit),
                const SizedBox(height: 8),
                if (habit.habitDescription != null && habit.habitDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20) + const EdgeInsets.only(bottom: 2),
                    child: Text(
                      habit.habitDescription!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.15,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(13.0),
        child: CircularActionButton(
          icon: CupertinoIcons.back,
          iconColor: iconColor,
          backgroundColor: iconBg,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: CircularActionButton(
            icon: CupertinoIcons.pencil,
            iconColor: iconColor,
            backgroundColor: iconBg,
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
