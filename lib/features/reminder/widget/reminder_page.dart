import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../provider/reminder_provider.dart';
import 'days_selection_widget.dart';
import 'multiple_reminder_times_widget.dart';
import 'reminder_mode_toggle_widget.dart';
import 'select_time_widget.dart';
import 'selection_buttons.dart';

class ReminderPage extends ConsumerWidget {
  const ReminderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: SheetHeader(
        closeButtonPosition: CloseButtonPosition.left,
        title: LocaleKeys.habit_reminder.tr(),
        trailing: TrailingActionButton(
          title: LocaleKeys.common_done.tr(),
          
          onPressed: () {
            navigator.pop();
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Column(
              children: [
                CustomSection(
                  text: LocaleKeys.common_days.tr(),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        DaySelectionWidget(),
                        SizedBox(height: 5),
                        SelectionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Only show reminder mode and time sections if days are selected
            Consumer(
              builder: (context, ref, child) {
                final reminderState = ref.watch(reminderProvider);

                if (!reminderState.hasSelectedDays) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    const ReminderModeToggleWidget(),
                    Consumer(
                      builder: (context, ref, child) {
                        final hasMultipleReminders = reminderState.reminder?.hasMultipleReminders ?? false;

                        if (hasMultipleReminders) {
                          return const MultipleReminderTimesWidget();
                        } else {
                          return CustomSection(
                            text: LocaleKeys.reminder_time.tr(),
                            child: const SelectTimeWidget().animate(),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            const Padding(padding: EdgeInsets.only(bottom: 32)),
          ],
        ),
      ),
    );
  }
}
