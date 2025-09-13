import 'package:flutter/material.dart';

import '/core/helpers/notifications/notification_utils.dart';
import '/features/reminder/models/days/days_enum.dart';
import '/features/reminder/models/multiple_reminder/multiple_reminder_model.dart';
import '/features/reminder/models/reminder/reminder_model.dart';
import '/features/reminder/service/reminder_service.dart';

/// Test widget to verify the smart notification system integration
class NotificationIntegrationTest extends StatefulWidget {
  const NotificationIntegrationTest({super.key});

  @override
  State<NotificationIntegrationTest> createState() => _NotificationIntegrationTestState();
}

class _NotificationIntegrationTestState extends State<NotificationIntegrationTest> {
  List<ReminderModel> _testReminders = [];
  int _currentNotificationCount = 0;
  bool _isApproachingLimit = false;
  String _testResults = '';

  @override
  void initState() {
    super.initState();
    _createTestReminders();
    _updateStats();
  }

  void _createTestReminders() {
    _testReminders = [
      // Test 1: Water drinking - 3 times per day, 7 days = 21 notifications
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

      // Test 2: Exercise - 2 times per day, 5 days = 10 notifications
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

      // Test 3: Meditation - 1 time per day, 7 days = 7 notifications
      ReminderModel(
        id: 3,
        reminderTime: DateTime(2024, 1, 1, 21, 0), // 9:00 PM
        days: Days.values,
      ),
    ];
  }

  Future<void> _updateStats() async {
    final count = await ReminderService.getCurrentNotificationCount();
    final approaching = await ReminderService.isApproachingLimit();

    setState(() {
      _currentNotificationCount = count;
      _isApproachingLimit = approaching;
    });
  }

  Future<void> _testSmartScheduling() async {
    setState(() {
      _testResults = 'Testing smart notification scheduling...\n';
    });

    try {
      // Test the smart notification system
      await ReminderService.createMultipleReminderNotifications(
        _testReminders,
        'Test Habit',
        'Test reminder message',
      );

      final stats = NotificationUtils.shared.getNotificationUsageStats(_testReminders);
      final totalPossible = NotificationUtils.shared.calculateTotalNotifications(_testReminders);

      setState(() {
        _testResults += '✅ Smart scheduling completed!\n';
        _testResults += 'Total possible notifications: $totalPossible\n';
        _testResults += 'iOS limit: ${stats.limit}\n';
        _testResults += 'Would exceed limit: ${stats.wouldExceedLimit}\n';
        _testResults += 'Percentage used: ${stats.percentage}%\n';
        _testResults += 'Scheduled notifications: ${stats.totalNotifications}\n';
      });

      await _updateStats();
    } catch (e) {
      setState(() {
        _testResults += '❌ Error: $e\n';
      });
    }
  }

  Future<void> _testRescheduling() async {
    setState(() {
      _testResults += '\nTesting rescheduling...\n';
    });

    try {
      await ReminderService.rescheduleAllNotifications(
        _testReminders,
        'Rescheduled Test',
        'Rescheduled reminder message',
      );

      setState(() {
        _testResults += '✅ Rescheduling completed!\n';
      });

      await _updateStats();
    } catch (e) {
      setState(() {
        _testResults += '❌ Rescheduling error: $e\n';
      });
    }
  }

  Future<void> _clearNotifications() async {
    setState(() {
      _testResults += '\nClearing all notifications...\n';
    });

    try {
      for (final reminder in _testReminders) {
        await ReminderService.cancelReminderNotification(reminder.id);
      }

      setState(() {
        _testResults += '✅ All notifications cleared!\n';
      });

      await _updateStats();
    } catch (e) {
      setState(() {
        _testResults += '❌ Clear error: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = NotificationUtils.shared.getNotificationUsageStats(_testReminders);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Integration Test'),
        backgroundColor: Colors.blue[50],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status
            Card(
              color: _isApproachingLimit ? Colors.orange[50] : Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('Scheduled notifications: $_currentNotificationCount'),
                    Text('Approaching limit: ${_isApproachingLimit ? "Yes" : "No"}'),
                    Text('Test reminders: ${_testReminders.length}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Statistics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total possible notifications: ${stats.totalNotifications}'),
                    Text('iOS limit: ${stats.limit}'),
                    Text('Percentage used: ${stats.percentage}%'),
                    Text('Would exceed limit: ${stats.wouldExceedLimit}'),
                    if (stats.wouldExceedLimit)
                      Text(
                        'Excess notifications: ${stats.excessCount}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testSmartScheduling,
                    icon: const Icon(Icons.schedule),
                    label: const Text('Test Smart Scheduling'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testRescheduling,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Test Rescheduling'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _clearNotifications,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All Notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.red[800],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test results
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Results',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _testResults.isEmpty ? 'No tests run yet' : _testResults,
                      style: const TextStyle(fontFamily: 'monospace'),
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
}
