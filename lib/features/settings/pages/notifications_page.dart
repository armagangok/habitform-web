import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/core.dart';
import '/core/helpers/notifications/notification_helper.dart';
import '/core/widgets/notification_limit_widget.dart';
import '/features/reminder/models/reminder/reminder_model.dart';
import '/services/habit_service/habit_service_interface.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with SingleTickerProviderStateMixin {
  List<PendingNotificationRequest> _notifications = [];
  List<ReminderModel> _activeReminders = [];
  bool _isLoading = true;
  final Map<String, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await NotificationHelper.shared.listScheduledNotifications();

      // Get active reminders for notification limit widget
      final activeHabits = await habitService.getHabits();
      final reminders = <ReminderModel>[];
      for (final habit in activeHabits) {
        if (habit.reminderModel != null && habit.reminderModel!.hasAnyReminders) {
          reminders.add(habit.reminderModel!);
        }
      }

      setState(() {
        _notifications = notifications;
        _activeReminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      LogHelper.shared.debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _deleteNotification(PendingNotificationRequest notification) async {
    try {
      // Parse notification info for better dialog
      String dayInfo = 'this notification';
      String timeInfo = '';

      Map<String, dynamic>? payloadData;
      if (notification.payload != null && notification.payload!.isNotEmpty) {
        try {
          payloadData = jsonDecode(notification.payload!);
          final timeString = payloadData?['time'] ?? '';
          final days = List<String>.from(payloadData?['days'] ?? []);

          dayInfo = _getSpecificDayForNotification(notification, days);
          if (timeString.isNotEmpty) {
            timeInfo = ' at $timeString';
          }
        } catch (e) {
          LogHelper.shared.debugPrint('Error parsing payload for delete dialog: $e');
        }
      }

      // Show confirmation dialog
      final confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Delete Reminder'),
          content: Text('Are you sure you want to delete the reminder for $dayInfo$timeInfo?'),
          actions: [
            CupertinoDialogAction(
              child: Text(LocaleKeys.common_cancel.tr()),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(LocaleKeys.common_delete.tr()),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Cancel the specific notification
        await NotificationHelper.shared.cancelNotification(notification.id);

        // Reload notifications to update the list
        await _loadNotifications();

        // Show success message
        if (mounted) {
          AppFlushbar.shared.successFlushbar(
            'Reminder for $dayInfo deleted successfully',
          );
        }
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error deleting notification: $e');
      if (mounted) {
        AppFlushbar.shared.errorFlushbar(
          'Failed to delete notification',
        );
      }
    }
  }

  Future<void> _deleteAllNotificationsForHabit(String habitName, List<PendingNotificationRequest> notifications) async {
    try {
      // Show confirmation dialog
      final confirmed = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Delete All Reminders'),
          content: Text('Are you sure you want to delete all ${notifications.length} reminders for "$habitName"?'),
          actions: [
            CupertinoDialogAction(
              child: Text(LocaleKeys.common_cancel.tr()),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(LocaleKeys.common_delete.tr()),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Cancel all notifications for this habit
        for (final notification in notifications) {
          await NotificationHelper.shared.cancelNotification(notification.id);
        }

        // Reload notifications to update the list
        await _loadNotifications();

        // Show success message
        if (mounted) {
          AppFlushbar.shared.successFlushbar(
            'All reminders for "$habitName" deleted successfully',
          );
        }
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error deleting all notifications: $e');
      if (mounted) {
        AppFlushbar.shared.errorFlushbar(
          'Failed to delete all reminders',
        );
      }
    }
  }

  /// Determine which specific day a notification represents based on its ID and payload
  String _getSpecificDayForNotification(PendingNotificationRequest notification, List<String> days) {
    if (days.isEmpty) {
      return 'Unknown Day';
    }

    if (days.length == 1) {
      return days.first;
    }

    // For multiple days, try to infer the specific day from the notification ID
    // This is based on the notification ID calculation: baseId + (dayIndex * 100) + timeIndex
    try {
      final notificationId = notification.id;

      // Try to find which day this notification belongs to by checking the ID pattern
      // We'll use modulo 100 to get the day index component
      final dayComponent = notificationId % 100;

      // Map day indices to day names (assuming Days enum order: Monday=0, Tuesday=1, etc.)
      const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      const shortDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

      if (dayComponent < dayNames.length) {
        // Try to match with the actual days in the payload
        final dayName = dayNames[dayComponent];
        final shortDayName = shortDayNames[dayComponent];

        // Check if this day is in the actual days list
        if (days.any((day) => day.toLowerCase().contains(dayName.toLowerCase()) || day.toLowerCase().contains(shortDayName.toLowerCase()))) {
          return shortDayName;
        }
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error determining specific day: $e');
    }

    // Fallback: show first day or count
    return days.isNotEmpty ? days.first : 'Unknown Day';
  }

  Map<String, List<PendingNotificationRequest>> _groupNotificationsByHabit() {
    final Map<String, List<PendingNotificationRequest>> grouped = {};
    for (var notification in _notifications) {
      final habitName = notification.title ?? 'Unknown Habit';
      if (!grouped.containsKey(habitName)) {
        grouped[habitName] = [];
      }
      grouped[habitName]!.add(notification);
    }
    return grouped;
  }

  void _showNotificationBreakdown() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => NotificationBreakdownDialog(reminders: _activeReminders),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => NotificationBreakdownDialog(reminders: _activeReminders),
      );
    }
  }

  Widget _buildNotificationItem(PendingNotificationRequest notification) {
    Map<String, dynamic>? payloadData;
    if (notification.payload != null && notification.payload!.isNotEmpty) {
      try {
        payloadData = jsonDecode(notification.payload!);
      } catch (e) {
        LogHelper.shared.debugPrint('Error parsing payload: $e');
      }
    }

    String timeString = payloadData?['time'] ?? '';
    List<String> days = List<String>.from(payloadData?['days'] ?? []);

    if (timeString.isEmpty && notification.body != null) {
      final bodyParts = notification.body!.split(' at ');
      if (bodyParts.length > 1) {
        timeString = bodyParts[1].split(' -').first.trim();
        final daysString = bodyParts[0].trim();
        if (daysString.isNotEmpty) {
          days = daysString.split(', ');
        }
      }
    }

    // Determine the specific day for this notification
    String dayInfo = _getSpecificDayForNotification(notification, days);

    return CupertinoListTile(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          CupertinoIcons.clock_fill,
          color: CupertinoColors.systemGrey,
          size: 20,
        ),
      ),
      title: Text(
        dayInfo,
        style: context.titleSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        timeString.isNotEmpty ? 'At $timeString' : 'Scheduled',
        style: context.bodySmall.copyWith(
          color: CupertinoColors.systemGrey,
        ),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        onPressed: () => _deleteNotification(notification),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CupertinoColors.systemRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            CupertinoIcons.trash,
            color: CupertinoColors.systemRed,
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableGroup(String habitName, List<PendingNotificationRequest> notifications) {
    final isExpanded = _expandedStates[habitName] ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: isExpanded ? 0.25 : 0,
            child: const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 20,
            ),
          ),
          title: Text(
            habitName,
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${notifications.length} ${LocaleKeys.notifications_reminders.tr()}',
            style: context.bodySmall.copyWith(
              color: CupertinoColors.systemGrey,
            ),
          ),
          trailing: notifications.length > 1
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () => _deleteAllNotificationsForHabit(habitName, notifications),
                  child: const Icon(
                    CupertinoIcons.trash_circle,
                    color: CupertinoColors.systemRed,
                    size: 24,
                  ),
                )
              : null,
          onTap: () {
            setState(() {
              _expandedStates[habitName] = !isExpanded;
            });
          },
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: child,
            );
          },
          child: isExpanded
              ? Column(
                  key: ValueKey<String>(habitName),
                  mainAxisSize: MainAxisSize.min,
                  children: notifications.map((notification) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: _buildNotificationItem(notification),
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: context.theme.scaffoldBackgroundColor.withValues(alpha: .4),
          previousPageTitle: LocaleKeys.settings_settings.tr(),
          middle: Text(LocaleKeys.habit_reminder.tr()),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              // Notification limit widget
              if (!_isLoading && _activeReminders.isNotEmpty)
                SliverToBoxAdapter(
                  child: NotificationLimitWidget(
                    reminders: _activeReminders,
                    onOptimizePressed: () => _showNotificationBreakdown(),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: CupertinoListSection.insetGrouped(
                    header: Text(LocaleKeys.notifications_settings.tr()),
                    children: [
                      CupertinoListTile(
                        leading: const Icon(
                          CupertinoIcons.settings,
                          color: CupertinoColors.systemGrey,
                          size: 22,
                        ),
                        title: Text(LocaleKeys.notifications_app_notification_settings.tr()),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () => openAppSettings(),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: CupertinoListSection.insetGrouped(
                  header: Text(LocaleKeys.notifications_scheduled_notifications.tr()),
                  children: [
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CupertinoActivityIndicator(),
                        ),
                      )
                    else if (_notifications.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            LocaleKeys.notifications_no_scheduled_notifications.tr(),
                          ),
                        ),
                      )
                    else
                      ...(_groupNotificationsByHabit().entries.map((entry) {
                        return _buildExpandableGroup(entry.key, entry.value);
                      }).toList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
