import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/reminder/models/reminder/reminder_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/core.dart';
import '../../../core/helpers/notifications/notification_helper.dart';
import '../extension/easy_day.dart';
import '../models/days/days_enum.dart';
import '../provider/reminder_provider.dart';
import 'reminder_page_widget.dart';

class ReminderSelectionWidget extends ConsumerStatefulWidget {
  final ReminderModel? reminderModel;
  const ReminderSelectionWidget({super.key, this.reminderModel});

  @override
  ConsumerState<ReminderSelectionWidget> createState() => _ReminderSelectionWidgetState();
}

class _ReminderSelectionWidgetState extends ConsumerState<ReminderSelectionWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(reminderProvider.notifier).initializeReminder(widget.reminderModel);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to ensure updates
    final reminderState = ref.watch(reminderProvider);
    final days = reminderState.reminder?.days;
    final remindTime = reminderState.reminder?.reminderTime;

    return CustomHeader(
      text: LocaleKeys.habit_reminder.tr().toUpperCase(),
      child: CustomButton(
        onPressed: () async {
          context.hideKeyboard();

          final permissionStatus = await NotificationHelper.shared.requestNotificationPermission();

          switch (permissionStatus) {
            case PermissionStatus.granted:
              if (context.mounted) {
                await showCupertinoModalBottomSheet(
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        remindTime?.toHHMM() ?? LocaleKeys.common_none.tr(),
                        style: context.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: context.titleMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (days != null && days.isNotEmpty) ...[
                      SizedBox(
                        height: 20,
                        child: days.length == 7
                            ? Text(
                                LocaleKeys.habit_daily.tr(),
                                style: context.bodyMedium?.copyWith(
                                  color: Colors.deepOrangeAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  days.length,
                                  (index) {
                                    final Days day = days[index];
                                    return Center(
                                      child: Text(
                                        days.isLast(index) ? day.shortenDayName : "${day.shortenDayName}, ",
                                        style: context.bodySmall?.copyWith(
                                          color: Colors.deepOrangeAccent,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    CupertinoListTileChevron(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
