import '../core/helpers/logger/logger.dart';
import '../models/habit/habit_model.dart';

/// Home-screen widgets are not used in the web build; calls are no-ops.
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  Future<void> exportHabitsForWidget(List<Habit> habits) async {}

  Future<void> updateHabitCompletionFromWidget(String habitId, bool isCompleted) async {
    LogHelper.shared.debugPrint('Widget habit update ignored on web: $habitId $isCompleted');
  }
}
