import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../services/analytics_service.dart';
import '../enum/user_goal_enum.dart';
import '../providers/onboarding_provider.dart';

/// Onboarding — Goal selection page
///
/// Lets users pick one or more goals so we can personalise the rest of the
/// funnel (feature highlights, PrePaywall headline, push-notification topics).
class OnboardingGoalPage extends ConsumerStatefulWidget {
  const OnboardingGoalPage({super.key});

  @override
  ConsumerState<OnboardingGoalPage> createState() => _OnboardingGoalPageState();
}

class _OnboardingGoalPageState extends ConsumerState<OnboardingGoalPage> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _ctaController;

  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _ctaFade;

  /// One controller per chip for staggered entrance.
  late final List<AnimationController> _chipControllers;
  late final List<Animation<double>> _chipFades;
  late final List<Animation<double>> _chipScales;

  static final _goals = UserGoal.allGoals;

  static const _goalEmojis = {
    UserGoal.betterProductivity: '🚀',
    UserGoal.buildRoutine: '📋',
    UserGoal.breakBadHabits: '🔓',
    UserGoal.getHealthier: '💪',
    UserGoal.timeManagement: '⏰',
    UserGoal.reduceStress: '🧘',
    UserGoal.other: '✨',
  };

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _ctaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _ctaFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctaController, curve: Curves.easeOutBack),
    );

    // Staggered chip animations
    _chipControllers = List.generate(
      _goals.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      ),
    );

    _chipFades = _chipControllers
        .map(
          (c) => Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOutCubic),
          ),
        )
        .toList();

    _chipScales = _chipControllers
        .map(
          (c) => Tween<double>(begin: 0.8, end: 1).animate(
            CurvedAnimation(parent: c, curve: Curves.easeOutBack),
          ),
        )
        .toList();

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _entryController.forward();

    // Stagger each chip by 80ms
    for (int i = 0; i < _chipControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      _chipControllers[i].forward();
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _ctaController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _ctaController.dispose();
    for (final c in _chipControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onContinue() {
    if (mounted) {
      AnalyticsService.logOnboardingStep('goal_selected');
      navigator.navigateAndClear(path: KRoute.onboardingAppFeatures);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = ref.watch(onboardingProvider).selectedGoals;
    final hasSelection = selected.isNotEmpty;

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: context.symmetricPadding(horizontal: 0.06),
          child: Column(
            children: [
              SizedBox(height: context.height(0.06)),

              // Title
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Text(
                    'onboarding.goals.page_title'.tr(),
                    style: context.headlineLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      color: theme.colorScheme.onSurface,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: context.height(0.012)),

              // Subtitle
              FadeTransition(
                opacity: _subtitleFade,
                child: Text(
                  'onboarding.goals.page_subtitle'.tr(),
                  style: context.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: context.height(0.05)),

              // Goal chips grid
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: List.generate(_goals.length, (i) {
                      final goal = _goals[i];
                      final isSelected = selected.contains(goal);
                      return FadeTransition(
                        opacity: _chipFades[i],
                        child: ScaleTransition(
                          scale: _chipScales[i],
                          child: _GoalChip(
                            emoji: _goalEmojis[goal] ?? '🎯',
                            label: goal.title,
                            isSelected: isSelected,
                            onTap: () => ref.read(onboardingProvider.notifier).toggleGoal(goal),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // CTA
              FadeTransition(
                opacity: _ctaFade,
                child: ScaleTransition(
                  scale: _ctaFade,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: context.height(0.025)),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: hasSelection ? 1.0 : 0.4,
                      child: GestureDetector(
                        onTap: hasSelection ? _onContinue : null,
                        child: Container(
                          width: double.infinity,
                          height: context.height(0.065),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withValues(alpha: 0.75),
                              ],
                            ),
                            boxShadow: hasSelection
                                ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              LocaleKeys.onboarding_continue_button.tr(),
                              style: context.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Goal Chip Widget ──────────────────────────────────────────────────────────

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.6) : theme.colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(
              label,
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
