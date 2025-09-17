import 'package:habitrise/core/core.dart';

import '/core/helpers/notifications/notification_utils.dart';
import '/core/widgets/notification_limit_widget.dart';
import '/features/reminder/models/days/days_enum.dart';
import '/features/reminder/models/multiple_reminder/multiple_reminder_model.dart';
import '/features/reminder/models/reminder/reminder_model.dart';
import '/features/reminder/service/reminder_service.dart';

/// Example showing how to handle iOS notification limits in your habit tracking app
class NotificationLimitExample extends StatefulWidget {
  const NotificationLimitExample({super.key});

  @override
  State<NotificationLimitExample> createState() => _NotificationLimitExampleState();
}

class _NotificationLimitExampleState extends State<NotificationLimitExample> {
  List<ReminderModel> _reminders = [];
  int _currentNotificationCount = 0;
  bool _isApproachingLimit = false;

  @override
  void initState() {
    super.initState();
    _loadExampleReminders();
    _updateNotificationStats();
  }

  /// Load example reminders to demonstrate the notification limit issue
  void _loadExampleReminders() {
    _reminders = [
      // Water drinking habit - 3 times per day, 7 days per week = 21 notifications
      ReminderModel(
        id: 1,
        multipleReminders: MultipleReminderModel(
          id: 1,
          reminderTimes: [
            DateTime(2024, 1, 1, 8, 0), // 8:00 AM
            DateTime(2024, 1, 1, 14, 0), // 2:00 PM
            DateTime(2024, 1, 1, 20, 0), // 8:00 PM
          ],
          days: Days.values, // All 7 days
        ),
      ),

      // Exercise habit - 2 times per day, 5 days per week = 10 notifications
      ReminderModel(
        id: 2,
        multipleReminders: MultipleReminderModel(
          id: 2,
          reminderTimes: [
            DateTime(2024, 1, 1, 7, 0), // 7:00 AM
            DateTime(2024, 1, 1, 18, 0), // 6:00 PM
          ],
          days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri],
        ),
      ),

      // Meditation habit - 1 time per day, 7 days per week = 7 notifications
      ReminderModel(
        id: 3,
        reminderTime: DateTime(2024, 1, 1, 21, 0), // 9:00 PM
        days: Days.values,
      ),

      // Reading habit - 2 times per day, 6 days per week = 12 notifications
      ReminderModel(
        id: 4,
        multipleReminders: MultipleReminderModel(
          id: 4,
          reminderTimes: [
            DateTime(2024, 1, 1, 9, 0), // 9:00 AM
            DateTime(2024, 1, 1, 19, 0), // 7:00 PM
          ],
          days: [Days.mon, Days.tue, Days.wed, Days.thu, Days.fri, Days.sat],
        ),
      ),

      // Journaling habit - 1 time per day, 7 days per week = 7 notifications
      ReminderModel(
        id: 5,
        reminderTime: DateTime(2024, 1, 1, 22, 0), // 10:00 PM
        days: Days.values,
      ),
    ];
  }

  /// Update notification statistics
  Future<void> _updateNotificationStats() async {
    _currentNotificationCount = await ReminderService.getCurrentNotificationCount();
    _isApproachingLimit = await ReminderService.isApproachingLimit();
    setState(() {});
  }

  /// Schedule all reminders using the smart notification system
  Future<void> _scheduleAllReminders() async {
    await ReminderService.createMultipleReminderNotifications(
      _reminders,
      'Habit Reminder',
      'Time to complete your habit!',
    );
    await _updateNotificationStats();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminders scheduled using smart notification management!'),
        ),
      );
    }
  }

  /// Show detailed notification breakdown
  void _showNotificationBreakdown() {
    showDialog(
      context: context,
      builder: (context) => NotificationBreakdownDialog(reminders: _reminders),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = NotificationUtils.shared.getNotificationUsageStats(_reminders);
    final totalPossible = NotificationUtils.shared.calculateTotalNotifications(_reminders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('iOS Notification Limit Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showNotificationBreakdown,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Current status
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: context.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Scheduled notifications: $_currentNotificationCount'),
                    Text('Approaching limit: ${_isApproachingLimit ? "Yes" : "No"}'),
                    Text('Total possible notifications: $totalPossible'),
                  ],
                ),
              ),
            ),

            // Notification limit widget
            NotificationLimitWidget(
              reminders: _reminders,
              onOptimizePressed: _showNotificationBreakdown,
            ),

            // Example scenarios
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example Scenarios',
                      style: context.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildScenarioItem(
                      context,
                      'Water Drinking',
                      '3 times/day × 7 days = 21 notifications',
                      Colors.blue,
                    ),
                    _buildScenarioItem(
                      context,
                      'Exercise',
                      '2 times/day × 5 days = 10 notifications',
                      Colors.green,
                    ),
                    _buildScenarioItem(
                      context,
                      'Meditation',
                      '1 time/day × 7 days = 7 notifications',
                      Colors.purple,
                    ),
                    _buildScenarioItem(
                      context,
                      'Reading',
                      '2 times/day × 6 days = 12 notifications',
                      Colors.orange,
                    ),
                    _buildScenarioItem(
                      context,
                      'Journaling',
                      '1 time/day × 7 days = 7 notifications',
                      Colors.brown,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Total: $totalPossible notifications',
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: stats.wouldExceedLimit ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _scheduleAllReminders,
                      icon: const Icon(Icons.schedule),
                      label: const Text('Schedule All Reminders (Smart)'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _updateNotificationStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Stats'),
                    ),
                  ),
                ],
              ),
            ),

            // Information about the solution
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How This Solves the iOS Limit',
                      style: context.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSolutionItem(
                      context,
                      '1. Smart Scheduling',
                      'Only schedules the most important upcoming notifications within the 64-notification limit.',
                    ),
                    _buildSolutionItem(
                      context,
                      '2. Priority System',
                      'Prioritizes morning habits, frequent habits, and habits with more commitment.',
                    ),
                    _buildSolutionItem(
                      context,
                      '3. Dynamic Rescheduling',
                      'Automatically reschedules notifications when the app becomes active.',
                    ),
                    _buildSolutionItem(
                      context,
                      '4. User Feedback',
                      'Shows users their notification usage and provides optimization suggestions.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioItem(BuildContext context, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: context.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: context.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
