import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/edit_habit/provider/edit_habit_provider.dart';
import 'package:habitrise/features/reminder/extension/easy_day.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/core.dart';
import '/core/helpers/notifications/notification_helper.dart';
import '../../../core/widgets/my_list_tile.dart';
import '../models/days/days_enum.dart';
import '../models/reminder/reminder_model.dart';
import '../provider/reminder_provider.dart';
import 'reminder_page.dart';

class ReminderSelectionWidget extends ConsumerStatefulWidget {
  final void Function(ReminderModel?)? onReminderChanged;
  final ReminderModel? initialReminder;

  const ReminderSelectionWidget({
    super.key,
    this.onReminderChanged,
    this.initialReminder,
    this.header,
  });

  final Widget? header;

  @override
  ConsumerState<ReminderSelectionWidget> createState() => _ReminderSelectionWidgetState();
}

class _ReminderSelectionWidgetState extends ConsumerState<ReminderSelectionWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use provided initialReminder or fallback to editHabitProvider
      final reminderToInitialize = widget.initialReminder ?? ref.watch(editHabitProvider)?.reminderModel;
      ref.watch(reminderProvider.notifier).initializeReminder(reminderToInitialize);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to ensure updates
    final reminderState = ref.watch(reminderProvider);
    final reminder = reminderState.reminder;
    final days = reminder?.days;

    // Call callback when reminder changes
    ref.listen(reminderProvider, (previous, next) {
      if (previous?.reminder != next.reminder && widget.onReminderChanged != null) {
        widget.onReminderChanged!(next.reminder);
      }
    });

    return CupertinoListSection.insetGrouped(
      header: widget.header,
      children: [
        MyListTile(
          
          trailing: CupertinoListTileChevron(),
          additionalInfo: Row(
            children: [
              if (reminder?.hasMultipleReminders == true) ...[
                // Multiple reminders case
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (reminder!.multipleReminders!.days != null && reminder.multipleReminders!.days!.isNotEmpty) ...[
                      SizedBox(
                        child: reminder.multipleReminders!.days!.length == 7
                            ? Text(
                                LocaleKeys.habit_daily.tr(),
                                style: context.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Wrap(
                                children: List.generate(
                                  reminder.multipleReminders!.days!.length,
                                  (index) {
                                    final Days day = reminder.multipleReminders!.days![index];
                                    return Text(
                                      reminder.multipleReminders!.days!.isLast(index) ? day.shortenDayName : "${day.shortenDayName}, ",
                                      style: context.bodySmall,
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    if (reminder.multipleReminders!.reminderTimes.isNotEmpty) ...[
                      SizedBox(
                        child: Wrap(
                          children: List.generate(
                            reminder.multipleReminders!.reminderTimes.length,
                            (index) {
                              final time = reminder.multipleReminders!.reminderTimes[index];
                              final isLast = index == reminder.multipleReminders!.reminderTimes.length - 1;
                              return Text(
                                isLast ? time.toHHMM() : "${time.toHHMM()}, ",
                                style: context.bodySmall.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ] else if (days != null && days.isNotEmpty) ...[
                // Single reminder case
                SizedBox(
                  child: days.length == 7
                      ? Text(
                          LocaleKeys.habit_daily.tr(),
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Wrap(
                          children: List.generate(
                            days.length,
                            (index) {
                              final Days day = days[index];
                              return Text(
                                days.isLast(index) ? day.shortenDayName : "${day.shortenDayName}, ",
                                style: context.bodySmall,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ],
          ),
          onTap: () async {
            context.hideKeyboard();

            final permissionStatus = await NotificationHelper.shared.requestNotificationPermission();

            switch (permissionStatus) {
              case PermissionStatus.granted:
                if (context.mounted) {
                  await showCupertinoSheet(
                    enableDrag: false,
                    context: context,
                    builder: (contextFromSheet) => const ReminderPage(),
                  );
                }
                break;

              case PermissionStatus.permanentlyDenied || PermissionStatus.denied:
                if (context.mounted) {
                  final shouldOpenSettings = await showCupertinoDialog<bool>(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Notifications Permission'),
                      content: const Text('To set reminders, please enable notifications in settings.'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          child: const Text('Settings'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );

                  if (shouldOpenSettings == true) {
                    await openAppSettings();
                  }
                }
                break;

              default:
                // For denied or other cases, do nothing as the permission request
                // will have already been shown by the requestNotificationPermission method
                break;
            }
          },
          title: _getReminderTitle(reminderState.reminder),
        ),
      ],
    );
  }

  String _getReminderTitle(ReminderModel? reminder) {
    if (reminder == null) return LocaleKeys.common_none.tr();

    if (reminder.hasMultipleReminders) {
      final times = reminder.multipleReminders!.sortedReminderTimes;
      if (times.isEmpty) return LocaleKeys.common_none.tr();

      if (times.length == 1) {
        return times.first.toHHMM();
      } else {
        // Show all times separated by commas
        return times.map((time) => time.toHHMM()).join(', ');
      }
    } else if (reminder.hasSingleReminder) {
      return reminder.reminderTime!.toHHMM();
    }

    return LocaleKeys.common_none.tr();
  }
}
