import '../../core/extension/datetime_extension.dart';

/// Lightweight summary of a habit for main page display
/// Contains only essential data needed for rendering, without full completion history
class HabitSummary {
  final String id;
  final String habitName;
  final String? emoji;
  final int colorCode;
  final int dailyTarget;
  final List<String> categoryIds;
  final DateTime? completionTime;
  final DateTime? reminderTime;
  final int todayCount;
  final bool todayIsCompleted;
  /// Last time today's completion entry was updated (for link sequence ordering).
  final DateTime? todayCompletionUpdatedAt;
  final int currentStreak;
  final double? constellationPosX;
  final double? constellationPosY;
  final List<String> linkedHabitIds;

  HabitSummary({
    required this.id,
    required this.habitName,
    this.emoji,
    required this.colorCode,
    required this.dailyTarget,
    required this.categoryIds,
    this.completionTime,
    this.reminderTime,
    required this.todayCount,
    required this.todayIsCompleted,
    this.todayCompletionUpdatedAt,
    required this.currentStreak,
    this.constellationPosX,
    this.constellationPosY,
    this.linkedHabitIds = const [],
  });

  /// Get count for a specific date
  /// Only returns data for today, returns 0 for other dates
  int getCountForDate(DateTime date) {
    final normalizedDate = date.normalized;
    final today = DateTime.now().normalized;

    if (normalizedDate.isSameDayWith(today)) {
      return todayCount;
    }
    return 0;
  }

  /// Get completion ratio for a specific date
  /// Only returns data for today, returns 0.0 for other dates
  double getCompletionRatioForDate(DateTime date) {
    final normalizedDate = date.normalized;
    final today = DateTime.now().normalized;

    if (normalizedDate.isSameDayWith(today)) {
      final effectiveTarget = dailyTarget <= 0 ? 1 : dailyTarget;
      return (todayCount / effectiveTarget).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  /// Calculate current streak (pre-calculated, just returns stored value)
  int calculateCurrentStreak() {
    return currentStreak;
  }
}
