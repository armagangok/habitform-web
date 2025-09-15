import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../models/habit/habit_model.dart';
import '../../provider/share_template_provider.dart';
import 'template_calendar.dart';
import 'template_heatmap.dart';
import 'template_overview.dart';
import 'template_poster.dart';

class ShareTemplateSwitcher extends ConsumerWidget {
  final Habit habit;
  final ScrollController? controller;
  final Color accentColor;

  const ShareTemplateSwitcher({super.key, required this.habit, this.controller, required this.accentColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(shareTemplateProvider.select((s) => s.templates[s.selectedIndex].id));

    switch (selectedId) {
      case 'calendar':
        return TemplateCalendar(habit: habit, accentColor: accentColor, controller: controller);
      case 'minimal':
        return TemplateOverview(habit: habit, accentColor: accentColor);
      case 'overview':
        return TemplateOverview(habit: habit, accentColor: accentColor);
      case 'heatmap':
        return TemplateHeatmap(habit: habit, accentColor: accentColor);
      case 'poster':
        return TemplatePoster(habit: habit, accentColor: accentColor, controller: controller);
      default:
        return TemplateCalendar(habit: habit, accentColor: accentColor, controller: controller);
    }
  }
}
