import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../models/habit/habit_model.dart';
import '../../../purchase/providers/purchase_provider.dart';
import '../../provider/share_template_provider.dart';
import 'template_calendar.dart';
import 'template_heatmap.dart';
import 'template_overview.dart';
import 'template_poster.dart';

class ShareTemplateSwitcher extends ConsumerWidget {
  final Habit habit;
  final ScrollController? controller;
  final Color accentColor;

  const ShareTemplateSwitcher({
    super.key,
    required this.habit,
    this.controller,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(shareTemplateProvider);
    final isPro = ref.watch(purchaseProvider).value?.isSubscriptionActive ?? false;
    final selectedConfig = selected.templates[selected.selectedIndex];
    final selectedId = selectedConfig.id;

    final bool locked = selectedConfig.requiresPro && !isPro;

    switch (selectedId) {
      case 'calendar':
        return TemplateCalendar(habit: habit, accentColor: accentColor, controller: controller);
      case 'minimal':
        return TemplateOverview(habit: habit, accentColor: accentColor);
      case 'overview':
        return _LockedWrapper(
          locked: locked,
          child: TemplateOverview(habit: habit, accentColor: accentColor),
        );
      case 'heatmap':
        return _LockedWrapper(
          locked: locked,
          child: TemplateHeatmap(habit: habit, accentColor: accentColor),
        );
      case 'poster':
        return _LockedWrapper(
          locked: locked,
          child: TemplatePoster(habit: habit, accentColor: accentColor, controller: controller),
        );
      default:
        return TemplateCalendar(habit: habit, accentColor: accentColor, controller: controller);
    }
  }
}

class _LockedWrapper extends StatelessWidget {
  final bool locked;
  final Widget child;

  const _LockedWrapper({required this.locked, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: .25,
          child: AbsorbPointer(
            absorbing: true,
            child: child,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.cupertinoTheme.barBackgroundColor.withValues(alpha: .95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.lock_fill, size: 14, color: context.titleLarge.color),
              const SizedBox(width: 6),
              Text('Unlock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.titleLarge.color)),
            ],
          ),
        ),
      ],
    );
  }
}
