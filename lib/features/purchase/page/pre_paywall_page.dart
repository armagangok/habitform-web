import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../services/analytics_service.dart';
import '../../onboarding/enum/user_goal_enum.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../providers/purchase_provider.dart';

/// Pre-Paywall warm-up page shown between onboarding and the native paywall.
///
/// Goal: Build perceived value, reduce purchase anxiety, and prime the user
/// psychologically before the pricing screen. Converts cold traffic into
/// warm, motivated prospects.
///
/// Structure:
/// 1. Hero — value promise headline + micro-stats (social proof numbers)
/// 2. Testimonials — 3 real-looking reviews with names & roles
/// 3. Feature highlights — the 3 most compelling unlocks
/// 4. Risk reducers — cancel anytime + privacy note
/// 5. Primary CTA — "Unlock Full Access" with glowing gradient
class PrePaywallPage extends ConsumerStatefulWidget {
  const PrePaywallPage({super.key, this.isFromOnboarding = true});

  final bool isFromOnboarding;

  @override
  ConsumerState<PrePaywallPage> createState() => _PrePaywallPageState();
}

class _PrePaywallPageState extends ConsumerState<PrePaywallPage> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _ctaController;
  late final AnimationController _glowController;
  late final AnimationController _revealController;

  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _ctaScaleAnim;
  late final Animation<double> _glowAnim;
  late final Animation<double> _revealFadeAnim;
  late final Animation<Offset> _revealSlideAnim;

  late final ScrollController _scrollController;

  bool _isLoading = false;
  bool _isCtaRevealed = false;

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

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _ctaScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctaController, curve: Curves.elasticOut),
    );

    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _revealFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutCubic),
    );

    _revealSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeOutCubic),
    );

    _scrollController = ScrollController()..addListener(_onScroll);

    _startAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goals = ref.read(onboardingProvider).selectedGoals;
      final selectedGoal = goals.isNotEmpty ? goals.first.name : null;
      AnalyticsService.logPaywallShown(
        source: widget.isFromOnboarding ? 'onboarding' : 'other',
        userGoal: selectedGoal,
      );
    });
  }

  void _onScroll() {
    if (_isCtaRevealed) return;

    // Trigger reveal when user is very close to bottom
    if (_scrollController.hasClients && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 40) {
      _revealCTA();
    }
  }

  void _revealCTA() {
    if (_isCtaRevealed) return;
    setState(() => _isCtaRevealed = true);
    _revealController.forward();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _entryController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _ctaController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _ctaController.dispose();
    _glowController.dispose();
    _revealController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onUnlock() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(purchaseProvider.notifier).presentPaywall(
            isFromOnboarding: widget.isFromOnboarding,
          );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSkip() {
    if (widget.isFromOnboarding) {
      // Still go through paywall even on skip — just present it directly
      ref.read(purchaseProvider.notifier).presentPaywall(
            isFromOnboarding: widget.isFromOnboarding,
          );
    } else {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoPageScaffold(
      child: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: context.symmetricPadding(horizontal: 0.055),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: context.height(0.03)),
                      _buildHero(context, theme),

                      SizedBox(height: context.height(0.04)),
                      _buildTestimonials(context, theme),
                      SizedBox(height: context.height(0.04)),
                      _buildFeatureHighlights(context),
                      SizedBox(height: context.height(0.03)),
                      _buildRiskReducers(context),
                      // Space for fixed bottom CTA
                    ]),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _revealFadeAnim,
                    child: SlideTransition(
                      position: _revealSlideAnim,
                      child: _buildFixedCta(context, theme),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Hero ────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context, ThemeData theme) {
    // Personalise headline from selected goal
    final goals = ref.read(onboardingProvider).selectedGoals;
    final headline = _headlineForGoal(goals.isNotEmpty ? goals.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          headline,
          style: context.headlineLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            height: 1.15,
            fontSize: 30,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.height(0.012)),
        Padding(
          padding: context.symmetricPadding(horizontal: 0.04),
          child: Text(
            'Join thousands of people who transformed their lives with HabitForm Pro.',
            style: context.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _headlineForGoal(UserGoal? goal) {
    switch (goal) {
      case UserGoal.betterProductivity:
        return 'Unlock peak productivity';
      case UserGoal.buildRoutine:
        return 'Build a routine that sticks';
      case UserGoal.breakBadHabits:
        return 'Break free from bad habits';
      case UserGoal.getHealthier:
        return 'Your healthier life starts here';
      case UserGoal.timeManagement:
        return 'Master your time, own your day';
      case UserGoal.reduceStress:
        return 'Find calm in your daily routine';
      case UserGoal.other:
      case null:
        return 'Build habits that actually stick';
    }
  }

  // ─── Social Proof Numbers ────────────────────────────────────────────────

  // Widget _buildSocialProof(BuildContext context, ThemeData theme) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //       vertical: context.height(0.022),
  //       horizontal: context.width(0.04),
  //     ),
  //     decoration: BoxDecoration(
  //       color: theme.colorScheme.primary.withValues(alpha: 0.06),
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(
  //         color: theme.colorScheme.primary.withValues(alpha: 0.15),
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         _statItem(context, theme, '50K+', LocaleKeys.paywall_social_active_users.tr()),
  //         _divider(theme),
  //         _statItem(context, theme, '4.9 ★', LocaleKeys.paywall_social_app_store_rating.tr()),
  //         _divider(theme),
  //         _statItem(context, theme, '91%', LocaleKeys.paywall_social_success_rate.tr()),
  //       ],
  //     ),
  //   );
  // }

  // ─── Testimonials ────────────────────────────────────────────────────────

  Widget _buildTestimonials(BuildContext context, ThemeData theme) {
    final testimonials = [
      (
        name: LocaleKeys.paywall_testimonial_1_name.tr(),
        role: LocaleKeys.paywall_testimonial_1_user_type.tr(),
        comment: LocaleKeys.paywall_testimonial_1_comment.tr(),
      ),
      (
        name: LocaleKeys.paywall_testimonial_2_name.tr(),
        role: LocaleKeys.paywall_testimonial_2_user_type.tr(),
        comment: LocaleKeys.paywall_testimonial_2_comment.tr(),
      ),
      (
        name: LocaleKeys.paywall_testimonial_3_name.tr(),
        role: LocaleKeys.paywall_testimonial_3_user_type.tr(),
        comment: LocaleKeys.paywall_testimonial_3_comment.tr(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.paywall_what_users_saying.tr(),
          style: context.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: context.height(0.015)),
        ...testimonials.map(
          (t) => Padding(
            padding: EdgeInsets.only(bottom: context.height(0.012)),
            child: _testimonialCard(context, theme, t.name, t.role, t.comment),
          ),
        ),
      ],
    );
  }

  Widget _testimonialCard(
    BuildContext context,
    ThemeData theme,
    String name,
    String role,
    String comment,
  ) {
    return CupertinoCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar initials
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : '?',
                    style: context.titleSmall.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: context.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      role,
                      style: context.bodySmall.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '⭐⭐⭐⭐⭐',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"$comment"',
            style: context.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Feature Highlights ───────────────────────────────────────────────────

  Widget _buildFeatureHighlights(BuildContext context) {
    final features = [
      (
        icon: CupertinoIcons.infinite,
        title: 'Unlimited Habits',
        desc: 'No cap — track every area of your life.',
        color: const Color(0xFF1DB954),
      ),
      (
        icon: CupertinoIcons.chart_bar_square_fill,
        title: 'Formation Probability',
        desc: 'Science-backed score that shows how close you are to automatic.',
        color: const Color(0xFF0C6CF2),
      ),
      (
        icon: CupertinoIcons.bolt_fill,
        title: 'Home Widget + Reminders',
        desc: 'Complete habits from your lock screen. Never break a streak.',
        color: const Color(0xFFF5A623),
      ),
      (
        icon: CupertinoIcons.cloud_fill,
        title: 'Cloud Sync & Backup',
        desc: 'Keep habits synced across all your devices securely.',
        color: const Color(0xFF9B51E0),
      ),
      (
        icon: CupertinoIcons.doc_text_fill,
        title: 'Data Export (CSV)',
        desc: 'Export your habit history for backup or external analysis.',
        color: const Color(0xFFF2994A),
      ),
      (
        icon: CupertinoIcons.map_fill,
        title: 'Habit Map Visualization',
        desc: 'See how your habits connect and build stronger routines.',
        color: const Color(0xFF2D9CDB),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.paywall_what_you_get.tr(),
          style: context.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: context.height(0.015)),
        ...features.map(
          (f) => Padding(
            padding: EdgeInsets.only(bottom: context.height(0.01)),
            child: _featureRow(context, f.icon, f.title, f.desc, f.color),
          ),
        ),
      ],
    );
  }

  Widget _featureRow(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Builder(
      builder: (context) {
        return CupertinoCard(
          padding: const EdgeInsets.all(12),
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: context.bodySmall.copyWith(
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: context.cupertinoTheme.primaryContrastingColor.withValues(
                  alpha: .8,
                ),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Risk Reducers ────────────────────────────────────────────────────────

  Widget _buildRiskReducers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        children: [
          _riskChip(
            CupertinoIcons.xmark_circle,
            'Cancel Anytime',
          ),
          _riskChip(
            CupertinoIcons.lock_shield_fill,
            'Privacy Protected',
          ),
          _riskChip(
            CupertinoIcons.creditcard,
            'Secure Checkout',
          ),
        ],
      ),
    );
  }

  Widget _riskChip(IconData icon, String label) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: context.bodySmall.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Fixed Bottom CTA ────────────────────────────────────────────────────

  Widget _buildFixedCta(BuildContext context, ThemeData theme) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.75),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.width(0.055),
                context.height(0.016),
                context.width(0.055),
                context.height(0.016),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Primary CTA
                  ScaleTransition(
                    scale: _ctaScaleAnim,
                    child: AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (context, _) {
                        return GestureDetector(
                          onTap: _isLoading ? null : _onUnlock,
                          child: Container(
                            height: context.height(0.065),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.75),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.35 * _glowAnim.value),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CupertinoActivityIndicator(
                                      color: CupertinoColors.white,
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          CupertinoIcons.lock_open_fill,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Unlock Full Access',
                                          style: context.bodyLarge.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Secondary skip link
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: _isLoading ? null : _onSkip,
                    child: Text(
                      'See pricing options',
                      style: context.bodySmall.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Background subtle particle painter ──────────────────────────────────────
