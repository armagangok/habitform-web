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

    return CupertinoListTile(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: const Icon(
        CupertinoIcons.clock_fill,
        color: CupertinoColors.systemGrey,
        size: 22,
      ),
      title: Text(
        timeString.isNotEmpty ? timeString : 'Scheduled',
      ),
      subtitle: days.isNotEmpty
          ? Text(
              days.join(', '),
            )
          : null,
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
