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
  final ValueNotifier<double> _collapseFraction = ValueNotifier<double>(0.0); // 0.0 expanded → 1.0 collapsed

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _collapseFraction.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Compute collapse fraction based on current offset
    final double maxScroll = (_expandedHeight - kToolbarHeight).clamp(0.0, double.infinity);
    if (maxScroll <= 0) return;
    final double newFraction = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    // Only update if the change is significant (reduces unnecessary ValueNotifier updates)
    if ((newFraction - _collapseFraction.value).abs() > 0.02) {
      _collapseFraction.value = newFraction;
    }
  }

  Color _resolveTitleColor(BuildContext context, Habit habit, double fraction) {
    // When expanded, prefer on-primary contrast (white). When collapsed, use default title color.
    final Color expandedColor = Colors.white;
    final Color collapsedColor = context.titleLarge.color ?? Colors.black;
    return Color.lerp(expandedColor, collapsedColor, fraction) ?? collapsedColor;
  }

  (Color icon, Color bg) _resolveIconColors(BuildContext context, double fraction) {
    final Color expandedIcon = Colors.white;
    final Color collapsedIcon = context.titleLarge.color ?? Colors.black;
    final Color expandedBg = Colors.white.withValues(alpha: 0.18);
    final Color collapsedBg = context.cupertinoTheme.barBackgroundColor.withValues(alpha: 0.11);
    final icon = Color.lerp(expandedIcon, collapsedIcon, fraction) ?? collapsedIcon;
    final bg = Color.lerp(expandedBg, collapsedBg, fraction) ?? collapsedBg;
    return (icon, bg);
  }

  @override
  Widget build(BuildContext context) {
    final currentHabit = ref.watch(habitDetailProvider);

    if (currentHabit == null) {
      // Show loading state while habit data is being loaded
      return const CupertinoPageScaffold(
        navigationBar: SheetHeader(
          title: '',
          closeButtonPosition: CloseButtonPosition.left,
        ),
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    // Removed debug print to avoid extra console noise during scroll

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SliverAppBar with habit header
              _buildSliverAppBar(context, currentHabit),

              // Progress card - lazy loaded with longer delay for heavy data processing
              SliverToBoxAdapter(
                child: _LazyLoadedWidget(
                  delay: const Duration(milliseconds: 250),
                  child: RepaintBoundary(
                    child: HabitProgressCard(habit: currentHabit),
                  ),
                ),
              ),

              // Overview widget - lazy loaded with longer delay for streak calculations
              SliverToBoxAdapter(
                child: _LazyLoadedWidget(
                  delay: const Duration(milliseconds: 350),
                  child: RepaintBoundary(
                    child: HabitOverviewWidget(habit: currentHabit),
                  ),
                ),
              ),

              // Lazy load heavy widgets with staggered delays to prevent UI blocking
              SliverToBoxAdapter(
                child: _LazyLoadedWidget(
                  delay: const Duration(milliseconds: 450),
                  child: RepaintBoundary(
                    child: HabitHeatmapCard(habit: currentHabit),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _LazyLoadedWidget(
                  delay: const Duration(milliseconds: 550),
                  child: RepaintBoundary(
                    child: HabitMilestonesCard(habit: currentHabit),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _LazyLoadedWidget(
                  delay: const Duration(milliseconds: 650),
                  child: RepaintBoundary(
                    child: HabitInsightsCard(habit: currentHabit),
                  ),
                ),
              ),

              // Bottom spacing for safe area
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
          const ActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Habit habit) {
    return SliverAppBar(
      expandedHeight: _expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: context.scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: ValueListenableBuilder<double>(
        valueListenable: _collapseFraction,
        builder: (context, fraction, _) {
          final titleColor = _resolveTitleColor(context, habit, fraction);
          return Text(
            habit.habitName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: titleColor,
            ),
          );
        },
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      leading: ValueListenableBuilder<double>(
        valueListenable: _collapseFraction,
        builder: (context, fraction, _) {
          final (iconColor, iconBg) = _resolveIconColors(context, fraction);
          return Padding(
            padding: const EdgeInsets.all(13.0),
            child: CircularActionButton(
              icon: CupertinoIcons.back,
              iconColor: iconColor,
              backgroundColor: iconBg,
              onPressed: () => Navigator.of(context).pop(),
            ),
          );
        },
      ),
      actions: [
        ValueListenableBuilder<double>(
          valueListenable: _collapseFraction,
          builder: (context, fraction, _) {
            final (iconColor, iconBg) = _resolveIconColors(context, fraction);
            return Padding(
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
            );
          },
        ),
      ],
    );
  }

  Container _habitEmoji(BuildContext context, Habit habit) {
    return Container(
      width: 96,
      height: 96,
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
          style: const TextStyle(fontSize: 48),
        ),
      ),
    );
  }
}

/// Widget that delays rendering its child until after the current frame
/// This helps improve initial page load performance by deferring heavy widgets
class _LazyLoadedWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _LazyLoadedWidget({
    required this.child,
    this.delay = const Duration(milliseconds: 0),
  });

  @override
  State<_LazyLoadedWidget> createState() => _LazyLoadedWidgetState();
}

class _LazyLoadedWidgetState extends State<_LazyLoadedWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Defer loading until after the current frame + optional delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Future.delayed(widget.delay, () {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      // Show a placeholder while loading
      return const SizedBox(
        height: 200,
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return widget.child;
  }
}
