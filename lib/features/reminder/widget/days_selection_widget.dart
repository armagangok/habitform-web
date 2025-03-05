import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/widgets/category_widget/multi_selection_category_widget.dart';

import '../../../core/core.dart';
import '../extension/easy_day.dart';
import '../models/days/days_enum.dart';
import '../provider/day_selection_provider.dart';
import '../provider/reminder_provider.dart';

class DaySelectionWidget extends ConsumerStatefulWidget {
  const DaySelectionWidget({super.key});

  @override
  ConsumerState<DaySelectionWidget> createState() => _DaysGridViewBuilderState();
}

class _DaysGridViewBuilderState extends ConsumerState<DaySelectionWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reminderState = ref.watch(reminderProvider);
      final days = reminderState.reminder?.days;
      if (days != null) {
        ref.watch(daySelectionProvider.notifier).setDays(days);
      }
    });
  }

  void _onDaysSelected(List<Days> selectedDays) {
    ref.watch(daySelectionProvider.notifier).setDays(selectedDays);
    ref.watch(reminderProvider.notifier).updateDays(selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDays = ref.watch(daySelectionProvider);

    return MultiCategoryWidget<Days>(
      categories: Days.values.toList(),
      initialSelection: selectedDays,
      onCategorySelected: _onDaysSelected,
      categoryLabelBuilder: (category) => category.getFullDayName,
      selection: Colors.deepOrangeAccent,
      unselectedColor: Colors.grey.withValues(alpha: .2),
    );
  }
}
