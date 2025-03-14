import '/core/core.dart';

/// Card widget to display progress for a specific habit
class HabitProgressCard extends StatelessWidget {
  final String habitName;
  final int completedDays;
  final int totalDays;
  final double progressPercentage;

  const HabitProgressCard({
    super.key,
    required this.habitName,
    required this.completedDays,
    required this.totalDays,
    required this.progressPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(
        habitName,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: context.theme.dividerColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getColorByPercentage(context, progressPercentage),
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${progressPercentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getColorByPercentage(context, progressPercentage),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$completedDays / $totalDays gün',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.theme.hintColor,
                ),
          ),
        ],
      ),
    );
  }

  /// Returns appropriate color based on progress percentage
  Color _getColorByPercentage(BuildContext context, double percentage) {
    final theme = Theme.of(context);
    if (percentage >= 80) {
      return theme.colorScheme.primary;
    } else if (percentage >= 50) {
      return theme.colorScheme.secondary;
    } else {
      return theme.colorScheme.error;
    }
  }
}
