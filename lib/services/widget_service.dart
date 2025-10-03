import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/habit/habit_model.dart';

class WidgetService {
  static const String _appGroupIdentifier = 'group.com.AppSweat.HabitFormWidget';
  static const String _habitsFileName = 'widget_habits.json';

  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// Export habit data to App Group container for widget access
  Future<void> exportHabitsForWidget(List<Habit> habits) async {
    try {
      final containerPath = await _getAppGroupContainerPath();
      if (containerPath == null) {
        print('Failed to get App Group container path');
        return;
      }

      final filePath = '$containerPath/$_habitsFileName';
      final file = File(filePath);

      // Convert habits to widget-compatible format
      final widgetHabits = habits.map((habit) => _convertHabitForWidget(habit)).toList();

      // Write to file
      await file.writeAsString(jsonEncode(widgetHabits));
      print('Exported ${habits.length} habits to widget container');
    } catch (e) {
      print('Error exporting habits for widget: $e');
    }
  }

  /// Convert Flutter Habit model to widget-compatible format
  Map<String, dynamic> _convertHabitForWidget(Habit habit) {
    // Convert completions map to widget format
    final widgetCompletions = <String, Map<String, dynamic>>{};

    habit.completions.forEach((key, completion) {
      final dateString = '${completion.date.year}-${completion.date.month.toString().padLeft(2, '0')}-${completion.date.day.toString().padLeft(2, '0')}';
      widgetCompletions[dateString] = {
        'id': completion.id,
        'date': dateString,
        'isCompleted': completion.isCompleted,
        'count': completion.count,
      };
    });

    return {
      'id': habit.id,
      'name': habit.habitName,
      'emoji': habit.emoji,
      'colorCode': habit.colorCode,
      'dailyTarget': habit.dailyTarget,
      'completions': widgetCompletions,
      'difficulty': habit.difficulty.name,
      'status': habit.status.name,
    };
  }

  /// Get App Group container path
  Future<String?> _getAppGroupContainerPath() async {
    try {
      if (Platform.isIOS) {
        // For iOS, we need to use the App Group container
        // This will be the path where both the main app and widget can access
        final documentsPath = await getApplicationDocumentsDirectory();
        final appGroupPath = documentsPath.path.replaceAll('/Documents', '/Library/Group Containers/$_appGroupIdentifier');
        return appGroupPath;
      }
      return null;
    } catch (e) {
      print('Error getting App Group container path: $e');
      return null;
    }
  }

  /// Update habit completion from widget
  Future<void> updateHabitCompletionFromWidget(String habitId, bool isCompleted) async {
    try {
      // This method will be called when the widget updates a habit
      // We'll need to sync this back to the main app's database
      print('Widget updated habit $habitId: $isCompleted');

      // TODO: Implement sync back to main app database
      // This could involve:
      // 1. Writing to a shared file that the main app monitors
      // 2. Using a notification system
      // 3. Using a shared database
    } catch (e) {
      print('Error updating habit completion from widget: $e');
    }
  }
}
