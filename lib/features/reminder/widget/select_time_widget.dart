import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../provider/picker_extend_provider.dart';
import '../provider/remind_time_provider.dart';
import '../provider/reminder_provider.dart';

class SelectTimeWidget extends ConsumerWidget {
  const SelectTimeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExtended = ref.watch(pickerExtendProvider);
    final reminderState = ref.watch(reminderProvider);
    final remindTime = reminderState.reminder?.reminderTime;
    final hasSelectedDays = reminderState.reminder?.days?.isNotEmpty ?? false;

    return AnimatedOpacity(
      duration: 350.ms,
      opacity: hasSelectedDays ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: 350.ms,
        height: hasSelectedDays ? null : 0,
        child: Column(
          children: [
            CustomButton(
              onPressed: hasSelectedDays ? ref.watch(pickerExtendProvider.notifier).toggleExtend : null,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.reminder_select_time.tr(),
                        style: context.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.titleMedium?.color?.withValues(alpha: hasSelectedDays ? 1.0 : 0.5),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            remindTime?.toHHMM() ?? LocaleKeys.common_none.tr(),
                            style: context.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: hasSelectedDays ? Colors.blueAccent : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            isExtended ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: context.titleMedium?.color?.withValues(alpha: hasSelectedDays ? 1.0 : 0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedContainer(
              duration: 350.ms,
              curve: Curves.easeOutCubic,
              height: isExtended && hasSelectedDays ? 200 : 0,
              child: ClipRect(
                child: OverflowBox(
                  maxHeight: 200,
                  child: AnimatedOpacity(
                    duration: 350.ms,
                    opacity: isExtended && hasSelectedDays ? 1 : 0,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: remindTime ?? DateTime.now().copyWith(hour: 12, minute: 0),
                      use24hFormat: true,
                      onDateTimeChanged: (DateTime value) {
                        if (isExtended && hasSelectedDays) {
                          ref.watch(remindTimeProvider.notifier).setTime(value);
                          ref.watch(reminderProvider.notifier).updateTime(value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
