import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../provider/picker_extend_provider.dart';
import '../provider/remind_time_provider.dart';
import '../provider/reminder_provider.dart';

class SelectTimeWidget extends ConsumerWidget {
  const SelectTimeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickerExtendState = ref.watch(pickerExtendProvider);
    final reminderState = ref.watch(reminderProvider);
    final remindTime = reminderState.reminder?.reminderTime;

    return Column(
      children: [
        CustomButton(
          onPressed: () {
            ref.read(pickerExtendProvider.notifier).toggleExtend();
          },
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
                      color: context.titleMedium?.color,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        remindTime?.toHHMM() ?? LocaleKeys.common_none.tr(),
                        style: context.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        pickerExtendState.isExtended ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: context.titleMedium?.color,
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
          height: pickerExtendState.isExtended ? 200 : 0,
          child: ClipRect(
            child: OverflowBox(
              maxHeight: 200,
              child: AnimatedOpacity(
                duration: 350.ms,
                opacity: pickerExtendState.isExtended ? 1 : 0,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: remindTime ?? DateTime.now().copyWith(hour: 12, minute: 0),
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime value) {
                    if (pickerExtendState.isExtended) {
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
    );
  }
}
