import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '../provider/reminder_provider.dart';

class ReminderModeToggleWidget extends ConsumerWidget {
  const ReminderModeToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderState = ref.watch(reminderProvider);
    final hasMultipleReminders = reminderState.reminder?.hasMultipleReminders ?? false;

    return CupertinoListSection.insetGrouped(
      header: Text('How many reminders?'),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () => ref.read(reminderProvider.notifier).setReminderMode(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: !hasMultipleReminders ? context.primary : context.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: !hasMultipleReminders ? context.primary : context.selectionHandleColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.clock,
                              size: 16,
                              color: !hasMultipleReminders ? Colors.white : context.cupertinoTextTheme.textStyle.color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Once a day',
                              style: context.bodyMedium.copyWith(
                                color: !hasMultipleReminders ? Colors.white : context.cupertinoTextTheme.textStyle.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () => ref.read(reminderProvider.notifier).setReminderMode(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: hasMultipleReminders ? context.primary : context.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasMultipleReminders ? context.primary : context.selectionHandleColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.clock_fill,
                              size: 16,
                              color: hasMultipleReminders ? Colors.white : context.cupertinoTextTheme.textStyle.color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Multiple times',
                              style: context.bodyMedium.copyWith(
                                color: hasMultipleReminders ? Colors.white : context.cupertinoTextTheme.textStyle.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (hasMultipleReminders) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.lightbulb,
                        size: 16,
                        color: context.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Perfect for habits like "Drink Water" - set reminders at 8 AM, 2 PM, and 8 PM',
                          style: context.bodySmall.copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
      ],
    );
  }
}
