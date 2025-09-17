import 'dart:io';

import '/core/core.dart';
import '/core/helpers/notifications/notification_utils.dart';
import '/features/reminder/models/reminder/reminder_model.dart';

/// Widget that shows notification usage information and limits
class NotificationLimitWidget extends StatelessWidget {
  final List<ReminderModel> reminders;
  final VoidCallback? onOptimizePressed;

  const NotificationLimitWidget({
    super.key,
    required this.reminders,
    this.onOptimizePressed,
  });

  @override
  Widget build(BuildContext context) {
    final stats = NotificationUtils.shared.getNotificationUsageStats(reminders);
    final suggestions = NotificationUtils.shared.getOptimizationSuggestions(reminders);

    if (Platform.isIOS) {
      return _buildCupertinoCard(context, stats, suggestions);
    } else {
      return _buildMaterialCard(context, stats, suggestions);
    }
  }

  Widget _buildCupertinoCard(BuildContext context, NotificationUsageStats stats, List<String> suggestions) {
    return CupertinoCard(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.bell_fill,
                  color: stats.wouldExceedLimit ? CupertinoColors.systemOrange : CupertinoTheme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${Platform.isIOS ? 'iOS' : 'Android'} Notification Usage',
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Usage bar
            _buildCupertinoUsageBar(context, stats),
            const SizedBox(height: 12),

            // Usage text
            Text(
              '${stats.totalNotifications} / ${stats.limit} notifications',
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontSize: 14,
                  ),
            ),

            if (stats.wouldExceedLimit) ...[
              const SizedBox(height: 8),
              Text(
                '${stats.excessCount} notifications will be automatically managed',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      color: CupertinoColors.systemOrange,
                      fontSize: 12,
                    ),
              ),
            ],

            const SizedBox(height: 16),

            // Suggestions
            if (suggestions.isNotEmpty) ...[
              Text(
                'Suggestions:',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 8),
              ...suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.lightbulb,
                          size: 16,
                          color: CupertinoColors.systemYellow,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                  fontSize: 12,
                                  color: CupertinoColors.systemGrey,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            if (onOptimizePressed != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: onOptimizePressed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.slider_horizontal_3, size: 16),
                      const SizedBox(width: 8),
                      const Text('Optimize Notifications'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, NotificationUsageStats stats, List<String> suggestions) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: stats.wouldExceedLimit ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${Platform.isIOS ? 'iOS' : 'Android'} Notification Usage',
                  style: context.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Usage bar
            _buildUsageBar(context, stats),
            const SizedBox(height: 12),

            // Usage text
            Text(
              '${stats.totalNotifications} / ${stats.limit} notifications',
              style: context.bodyMedium,
            ),

            if (stats.wouldExceedLimit) ...[
              const SizedBox(height: 8),
              Text(
                '${stats.excessCount} notifications will be automatically managed',
                style: context.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Suggestions
            if (suggestions.isNotEmpty) ...[
              Text(
                'Suggestions:',
                style: context.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...suggestions.map((suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: context.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            if (onOptimizePressed != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onOptimizePressed,
                  icon: const Icon(Icons.tune),
                  label: const Text('Optimize Notifications'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsageBar(BuildContext context, NotificationUsageStats stats) {
    final percentage = stats.percentage / 100.0;
    final theme = Theme.of(context);
    Color barColor;

    if (percentage < 0.7) {
      barColor = theme.colorScheme.primary;
    } else if (percentage < 0.9) {
      barColor = theme.colorScheme.tertiary;
    } else {
      barColor = theme.colorScheme.error;
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: percentage.clamp(0.0, 1.0),
          backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        ),
        const SizedBox(height: 4),
        Text(
          '${stats.percentage}% of ${Platform.isIOS ? 'iOS' : 'Android'} limit used',
          style: context.bodySmall.copyWith(
            color: barColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCupertinoUsageBar(BuildContext context, NotificationUsageStats stats) {
    final percentage = stats.percentage / 100.0;
    final cupertinoTheme = CupertinoTheme.of(context);
    Color barColor;

    if (percentage < 0.7) {
      barColor = cupertinoTheme.primaryColor;
    } else if (percentage < 0.9) {
      barColor = CupertinoColors.systemOrange;
    } else {
      barColor = CupertinoColors.systemRed;
    }

    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${stats.percentage}% of ${Platform.isIOS ? 'iOS' : 'Android'} limit used',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: barColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}

/// Dialog that shows detailed notification breakdown
class NotificationBreakdownDialog extends StatelessWidget {
  final List<ReminderModel> reminders;

  const NotificationBreakdownDialog({
    super.key,
    required this.reminders,
  });

  @override
  Widget build(BuildContext context) {
    final breakdown = NotificationUtils.shared.getHabitNotificationBreakdown(reminders);
    final stats = NotificationUtils.shared.getNotificationUsageStats(reminders);

    if (Platform.isIOS) {
      return _buildCupertinoDialog(context, breakdown, stats);
    } else {
      return _buildMaterialDialog(context, breakdown, stats);
    }
  }

  Widget _buildCupertinoDialog(BuildContext context, List<HabitNotificationInfo> breakdown, NotificationUsageStats stats) {
    return CupertinoAlertDialog(
      title: Text('${Platform.isIOS ? 'iOS' : 'Android'} Notification Breakdown'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stats.wouldExceedLimit ? CupertinoColors.systemOrange.withValues(alpha: 0.1) : CupertinoTheme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: stats.wouldExceedLimit ? CupertinoColors.systemOrange.withValues(alpha: 0.3) : CupertinoTheme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCupertinoStatItem(context, 'Total', '${stats.totalNotifications}'),
                  _buildCupertinoStatItem(context, 'Limit', '${stats.limit}'),
                  _buildCupertinoStatItem(context, 'Usage', '${stats.percentage}%'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Breakdown list
            if (breakdown.isNotEmpty) ...[
              Text(
                'Habits by notification count:',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.33,
                ),
                child: breakdown.length <= 3
                    ? CupertinoListSection(
                        children: breakdown.asMap().entries.map((entry) {
                          final habit = entry.value;
                          return CupertinoListTile(
                            title: Text(
                              'Habit ${habit.reminderId}',
                              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                            ),
                            subtitle: Text(
                              '${habit.timesPerDay} times/day × ${habit.daysPerWeek} days = ${habit.notificationCount} notifications',
                              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 12,
                                  ),
                              maxLines: 6,
                            ),
                            trailing: Text(
                              '${habit.notificationCount}',
                              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getCupertinoPriorityColor(context, habit.priority),
                                    fontSize: 14,
                                  ),
                            ),
                            additionalInfo: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _getCupertinoPriorityColor(context, habit.priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: breakdown.asMap().entries.map((entry) {
                            final index = entry.key;
                            final habit = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: _getCupertinoPriorityColor(context, habit.priority),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Habit ${habit.reminderId}',
                                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${habit.timesPerDay} times/day × ${habit.daysPerWeek} days = ${habit.notificationCount} notifications',
                                          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                                color: CupertinoColors.systemGrey,
                                                fontSize: 12,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${habit.notificationCount}',
                                    style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _getCupertinoPriorityColor(context, habit.priority),
                                          fontSize: 14,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildMaterialDialog(BuildContext context, List<HabitNotificationInfo> breakdown, NotificationUsageStats stats) {
    return AlertDialog(
      title: Text('${Platform.isIOS ? 'iOS' : 'Android'} Notification Breakdown'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary
            Card(
              color: stats.wouldExceedLimit ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, 'Total', '${stats.totalNotifications}'),
                    _buildStatItem(context, 'Limit', '${stats.limit}'),
                    _buildStatItem(context, 'Usage', '${stats.percentage}%'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Breakdown list
            if (breakdown.isNotEmpty) ...[
              Text(
                'Habits by notification count:',
                style: context.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.33,
                ),
                child: breakdown.length <= 3
                    ? Column(
                        children: breakdown.asMap().entries.map((entry) {
                          final index = entry.key;
                          final habit = entry.value;
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: CircleAvatar(
                              radius: 14,
                              backgroundColor: _getPriorityColor(context, habit.priority),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              'Habit ${habit.reminderId}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              '${habit.timesPerDay} times/day × ${habit.daysPerWeek} days = ${habit.notificationCount} notifications',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '${habit.notificationCount}',
                              style: context.titleSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getPriorityColor(context, habit.priority),
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: breakdown.asMap().entries.map((entry) {
                            final index = entry.key;
                            final habit = entry.value;
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: _getPriorityColor(context, habit.priority),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Habit ${habit.reminderId}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                '${habit.timesPerDay} times/day × ${habit.daysPerWeek} days = ${habit.notificationCount} notifications',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                '${habit.notificationCount}',
                                style: context.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getPriorityColor(context, habit.priority),
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: context.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCupertinoStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: CupertinoColors.systemGrey,
                fontSize: 12,
              ),
        ),
      ],
    );
  }

  Color _getPriorityColor(BuildContext context, int priority) {
    final theme = Theme.of(context);
    if (priority >= 150) return theme.colorScheme.error;
    if (priority >= 120) return theme.colorScheme.tertiary;
    if (priority >= 100) return theme.colorScheme.primary;
    return theme.colorScheme.outline;
  }

  Color _getCupertinoPriorityColor(BuildContext context, int priority) {
    final cupertinoTheme = CupertinoTheme.of(context);
    if (priority >= 150) return cupertinoTheme.primaryColor;
    if (priority >= 120) return CupertinoColors.systemOrange;
    if (priority >= 100) return CupertinoColors.systemBlue;
    return cupertinoTheme.textTheme.textStyle.color ?? CupertinoColors.systemGrey;
  }
}
