import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/core/widgets/category_widget/multi_selection_category_widget.dart';

import '../../../core/core.dart';
import '../extension/easy_day.dart';
import '../models/days/days_enum.dart';
import '../provider/day_selection_provider.dart';
import '../provider/reminder_provider.dart';

class DaysGridViewBuilder extends ConsumerStatefulWidget {
  const DaysGridViewBuilder({super.key});

  @override
  ConsumerState<DaysGridViewBuilder> createState() => _DaysGridViewBuilderState();
}

class _DaysGridViewBuilderState extends ConsumerState<DaysGridViewBuilder> {
  @override
  void initState() {
    super.initState();
    // Initialize days from reminder state
    _initializeDays();
  }

  void _initializeDays() {
    final reminderState = ref.watch(reminderProvider);
    final days = reminderState.reminder?.days;
    if (days != null) {
      ref.read(daySelectionProvider.notifier).setDays(days);
    }
  }

  void _updateDays(List<Days> selectedDays) {
    // Update both providers synchronously
    ref.read(daySelectionProvider.notifier).setDays(selectedDays);
    ref.watch(reminderProvider.notifier).updateDays(selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    // Watch both providers to ensure updates
    final daySelectionState = ref.watch(daySelectionProvider);
    final reminderState = ref.watch(reminderProvider);

    final selectedDays = daySelectionState.selectedDays;

    // Ensure synchronization between providers
    if (!listEquals(selectedDays, reminderState.reminder?.days)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateDays(selectedDays);
      });
    }

    return MultiCategoryWidget<Days>(
      categories: Days.values.toList(),
      initialSelection: selectedDays,
      onCategorySelected: _updateDays,
      categoryLabelBuilder: (category) => category.getFullDayName,
      selection: Colors.deepOrangeAccent,
    );
  }
}
