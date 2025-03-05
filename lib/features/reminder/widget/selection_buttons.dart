import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../models/days/days_enum.dart';
import '../provider/day_selection_provider.dart';
import '../provider/picker_extend_provider.dart';
import '../provider/remind_time_provider.dart';
import '../provider/reminder_provider.dart';

class SelectionButtons extends ConsumerWidget {
  const SelectionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            onPressed: () {
              ref.watch(daySelectionProvider.notifier).setDays(Days.values.toList());
              ref.watch(remindTimeProvider.notifier).setTime(DateTime.now().copyWith(hour: 12, minute: 0));
              ref.watch(reminderProvider.notifier).updateDays(Days.values.toList());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
              child: Text(
                LocaleKeys.reminder_select_all.tr(),
                style: TextStyle(color: context.primary),
              ),
            ),
          ).animate().fadeIn(),
          CustomButton(
            onPressed: () {
              ref.watch(daySelectionProvider.notifier).clearDays();
              ref.watch(pickerExtendProvider.notifier).collapse();
              ref.watch(remindTimeProvider.notifier).clearTime();
              ref.watch(reminderProvider.notifier).updateDays(null);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5),
              child: Text(
                LocaleKeys.reminder_deselect_all.tr(),
                style: TextStyle(color: context.primary),
              ),
            ),
          ).animate().fadeIn(),
        ],
      ),
    );
  }
}
