import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/helpers/logger/logger.dart';
import '../models/habit/habit_extension.dart';
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
        LogHelper.shared.debugPrint('Failed to get App Group container path');
        return;
      }

      // Create the directory if it doesn't exist
      final containerDir = Directory(containerPath);
      if (!await containerDir.exists()) {
        await containerDir.create(recursive: true);
        LogHelper.shared.debugPrint('📁 Created App Group container directory: $containerPath');
      }

      // Write to both the old format and the new format for compatibility
      final oldFilePath = '$containerPath/$_habitsFileName';
      final newFilePath = '$containerPath/habits.json';

      final oldFile = File(oldFilePath);
      final newFile = File(newFilePath);

      // Convert habits to widget-compatible format
      final widgetHabits = habits.map((habit) => _convertHabitForWidget(habit)).toList();

      // Write to both files
      await oldFile.writeAsString(jsonEncode(widgetHabits));
      await newFile.writeAsString(jsonEncode(widgetHabits));
      LogHelper.shared.debugPrint('✅ Exported ${habits.length} habits to widget container');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error exporting habits for widget: $e');
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
        'date': completion.date.toIso8601String(),
        'isCompleted': completion.isCompleted,
        'count': completion.count,
      };
    });

    // Calculate Flutter-provided values
    final probabilityScore = habit.calculateHabitProbability();
    final longestStreak = habit.calculateLongestStreak();
    final currentStreak = habit.calculateCurrentStreak();
    final completedDays = habit.completions.values.where((e) => e.isCompleted).length;
    final totalDays = habit.completions.length;

    return {
      'id': habit.id,
      'habitName': habit.habitName,
      'habitDescription': habit.habitDescription,
      'emoji': habit.emoji,
      'dailyTarget': habit.dailyTarget,
      'colorCode': habit.colorCode,
      'completions': widgetCompletions,
      'archiveDate': habit.archiveDate?.toIso8601String(),
      'status': habit.status.name,
      'categoryIds': habit.categoryIds,
      'difficulty': habit.difficulty.name,
      // Flutter-provided calculated values
      'flutterProbabilityScore': probabilityScore,
      'flutterLongestStreak': longestStreak,
      'flutterCurrentStreak': currentStreak,
      'flutterCompletedDays': completedDays,
      'flutterTotalDays': totalDays,
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
      LogHelper.shared.debugPrint('Error getting App Group container path: $e');
      return null;
    }
  }

  /// Update habit completion from widget
  Future<void> updateHabitCompletionFromWidget(String habitId, bool isCompleted) async {
    try {
      // This method will be called when the widget updates a habit
      // We'll need to sync this back to the main app's database
      LogHelper.shared.debugPrint('Widget updated habit $habitId: $isCompleted');

      // TODO: Implement sync back to main app database
      // This could involve:
      // 1. Writing to a shared file that the main app monitors
      // 2. Using a notification system
      // 3. Using a shared database
    } catch (e) {
      LogHelper.shared.debugPrint('Error updating habit completion from widget: $e');
    }
  }
}
