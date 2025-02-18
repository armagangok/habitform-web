import 'package:permission_handler/permission_handler.dart';

import '/core/core.dart';
import '../../../core/helpers/notifications/notification_helper.dart';
import '../bloc/reminder/reminder_bloc.dart';
import '../extension/easy_day.dart';
import '../models/days/days_enum.dart';
import 'reminder_page_widget.dart';

class ReminderSelectionWidget extends StatelessWidget {
  const ReminderSelectionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (contextFromBuilder, state) {
        final days = state.reminder?.days;
        final remindTime = state.reminder?.reminderTime;

        return CustomHeader(
          text: LocaleKeys.habit_reminder.tr().toUpperCase(),
          child: Card(
            child: CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.all(10),
              onPressed: () async {
                contextFromBuilder.hideKeyboard();

                final permissionStatus = await NotificationHelper.shared.requestNotificationPermission();

                print(permissionStatus);

                switch (permissionStatus) {
                  case PermissionStatus.granted:
                    showCupertinoModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      builder: (contextFromSheet) {
                        final reminderBloc = contextFromBuilder.read<ReminderBloc>();
                        return BlocProvider.value(
                          value: reminderBloc,
                          child: const ReminderPage(),
                        );
                      },
                    );
                    break;

                  case PermissionStatus.permanentlyDenied || PermissionStatus.denied:
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
                    break;

                  default:

                    // For denied or other cases, do nothing as the permission request
                    // will have already been shown by the requestNotificationPermission method
                    break;
                }
              },
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
                        days != null && days.isNotEmpty
                            ? SizedBox(
                                height: 20,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: days.length,
                                  itemBuilder: (context, index) {
                                    final Days day = days[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 1.0),
                                      child: Text(
                                        days.isLast(index) ? day.getDayName : "${day.getDayName}, ",
                                        style: context.bodySmall?.copyWith(color: context.primary),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                  CupertinoListTileChevron(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
