import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:habitform/models/habit/habit_extension.dart';

import '../models/completion_entry/completion_entry.dart';
import '../models/habit/habit_model.dart';
import 'widget_service.dart';

/// Service for handling Method Channel communication with iOS widgets
class WidgetMethodChannelService {
  static const MethodChannel _channel = MethodChannel('com.appsweat.habitrise/widget');
  static const String _appGroupIdentifier = 'group.com.AppSweat.HabitFormWidget';

  static final WidgetMethodChannelService _instance = WidgetMethodChannelService._internal();
  factory WidgetMethodChannelService() => _instance;
  WidgetMethodChannelService._internal() {
    _setupMethodChannel();
  }

  /// Setup method channel handlers
  void _setupMethodChannel() {
    if (Platform.isIOS) {
      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'completeHabit':
            return await _handleCompleteHabit(call.arguments);
          case 'updateHabitCompletion':
            return await _handleUpdateHabitCompletion(call.arguments);
          case 'getHabits':
            return await _handleGetHabits();
          default:
            throw PlatformException(
              code: 'UNIMPLEMENTED',
              message: 'Method ${call.method} not implemented',
            );
        }
      });
    }
  }

  /// Handle habit completion from widget
  Future<Map<String, dynamic>> _handleCompleteHabit(dynamic arguments) async {
    try {
      final Map<String, dynamic> args = Map<String, dynamic>.from(arguments);
      final String habitId = args['habitId'] as String;
      final String dateString = args['date'] as String;
      final bool isCompleted = args['isCompleted'] as bool? ?? true;
      final int count = args['count'] as int? ?? 1;

      // Parse date
      final DateTime date = DateTime.parse(dateString);

      // Create completion entry
      final completion = CompletionEntry(
        id: '${habitId}_$dateString',
        date: date,
        isCompleted: isCompleted,
        count: count,
      );

      // This will be handled by the main app's habit service
      // We'll emit an event that the main app can listen to
      await _notifyMainAppOfCompletion(habitId, completion);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Handle habit completion update from widget
  Future<Map<String, dynamic>> _handleUpdateHabitCompletion(dynamic arguments) async {
    try {
      final Map<String, dynamic> args = Map<String, dynamic>.from(arguments);
      final String habitId = args['habitId'] as String;
      final String dateString = args['date'] as String;
      final bool isCompleted = args['isCompleted'] as bool;
      final int count = args['count'] as int;

      // Parse date
      final DateTime date = DateTime.parse(dateString);

      // Create completion entry
      final completion = CompletionEntry(
        id: '${habitId}_$dateString',
        date: date,
        isCompleted: isCompleted,
        count: count,
      );

      // Notify main app
      await _notifyMainAppOfCompletion(habitId, completion);

      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Handle get habits request from widget
  Future<Map<String, dynamic>> _handleGetHabits() async {
    try {
      // This will be implemented to return current habits data
      // For now, return empty list
      return {'habits': []};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Notify main app of completion update
  Future<void> _notifyMainAppOfCompletion(String habitId, CompletionEntry completion) async {
    // Write to shared file that main app can monitor
    await _writeCompletionUpdate(habitId, completion);

    // Also update the widget data file
    await _updateWidgetData();
  }

  /// Write completion update to shared file
  Future<void> _writeCompletionUpdate(String habitId, CompletionEntry completion) async {
    try {
      final containerPath = await _getAppGroupContainerPath();
      if (containerPath == null) return;

      // Create the directory if it doesn't exist
      final containerDir = Directory(containerPath);
      if (!await containerDir.exists()) {
        await containerDir.create(recursive: true);
        print('📁 Created App Group container directory: $containerPath');
      }

      final filePath = '$containerPath/completion_updates.json';
      final file = File(filePath);

      // Read existing updates or create new list
      List<Map<String, dynamic>> updates = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        updates = List<Map<String, dynamic>>.from(jsonDecode(content));
      }

      // Add new update
      updates.add({
        'habitId': habitId,
        'completion': {
          'id': completion.id,
          'date': completion.date.toIso8601String(),
          'isCompleted': completion.isCompleted,
          'count': completion.count,
        },
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Keep only last 100 updates to prevent file from growing too large
      if (updates.length > 100) {
        updates = updates.sublist(updates.length - 100);
      }

      // Write back to file
      await file.writeAsString(jsonEncode(updates));
      print('✅ Written completion update for habit: $habitId');
    } catch (e) {
      print('❌ Error writing completion update: $e');
    }
  }

  /// Update widget data file with latest habits
  Future<void> _updateWidgetData() async {
    // This will be called by the main app when habits are updated
    // For now, it's a placeholder
  }

  /// Get App Group container path
  Future<String?> _getAppGroupContainerPath() async {
    try {
      if (Platform.isIOS) {
        // Use Method Channel to get the correct App Group container path from iOS
        final result = await _channel.invokeMethod('getAppGroupContainerPath');
        if (result != null) {
          print('📁 Method Channel App Group container path from iOS: $result');
          return result as String;
        } else {
          print('❌ iOS returned null for App Group container path');
          return null;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting App Group container path: $e');
      return null;
    }
  }

  /// Called by main app to update widget data
  Future<void> updateWidgetData(List<Habit> habits) async {
    if (!Platform.isIOS) return;

    print('🔄 WidgetMethodChannelService: updateWidgetData called with ${habits.length} habits');

    // Filter out archived habits and ensure we have valid habits
    final activeHabits = habits.where((habit) => habit.status.name == 'active').toList();
    print('🔄 WidgetMethodChannelService: ${activeHabits.length} active habits after filtering');

    for (final habit in activeHabits) {
      print('  - ${habit.habitName} (${habit.id}) - ${habit.completions.length} completions');
    }

    try {
      // Export habits for widget using existing WidgetService
      print('📤 WidgetMethodChannelService: Exporting habits via WidgetService...');
      await WidgetService().exportHabitsForWidget(activeHabits);

      // Also write to the new format for Method Channel communication
      print('📤 WidgetMethodChannelService: Writing habits to shared container...');
      await _writeHabitsToSharedContainer(activeHabits);

      // Use Method Channel to sync with iOS
      print('📤 WidgetMethodChannelService: Syncing habits via Method Channel...');
      await _syncHabitsViaMethodChannel(activeHabits);

      // Force reload widget timelines
      print('📤 WidgetMethodChannelService: Force reloading widget timelines...');
      await _forceReloadWidgetTimelines();

      print('✅ WidgetMethodChannelService: Successfully updated widget data');
    } catch (e) {
      print('❌ WidgetMethodChannelService: Error updating widget data: $e');
    }
  }

  /// Force reload all widget timelines
  Future<void> _forceReloadWidgetTimelines() async {
    try {
      await _channel.invokeMethod('forceReloadWidgetTimelines');
      print('✅ WidgetMethodChannelService: Forced widget timeline reload');
    } catch (e) {
      print('❌ WidgetMethodChannelService: Error forcing widget timeline reload: $e');
    }
  }

  /// Write habits to shared container in Method Channel format
  Future<void> _writeHabitsToSharedContainer(List<Habit> habits) async {
    try {
      final containerPath = await _getAppGroupContainerPath();
      if (containerPath == null) {
        print('❌ WidgetMethodChannelService: Failed to get App Group container path');
        return;
      }

      print('📁 WidgetMethodChannelService: Using container path: $containerPath');

      // Create the directory if it doesn't exist
      final containerDir = Directory(containerPath);
      if (!await containerDir.exists()) {
        await containerDir.create(recursive: true);
        print('📁 WidgetMethodChannelService: Created App Group container directory: $containerPath');
      } else {
        print('📁 WidgetMethodChannelService: Container directory already exists');
      }

      final filePath = '$containerPath/habits.json';
      final file = File(filePath);
      print('📄 WidgetMethodChannelService: Writing to file: $filePath');

      // Convert habits to widget-compatible format
      final widgetHabits = habits.map((habit) => _convertHabitForWidget(habit)).toList();
      print('🔄 WidgetMethodChannelService: Converted ${habits.length} habits to widget format');

      // Write to file with atomic operation
      final jsonString = jsonEncode(widgetHabits);
      final tempFilePath = '$filePath.tmp';
      final tempFile = File(tempFilePath);

      // Write to temporary file first
      await tempFile.writeAsString(jsonString);

      // Atomically move to final location
      await tempFile.rename(filePath);

      print('✅ WidgetMethodChannelService: Written ${widgetHabits.length} habits to $filePath');
      print('📊 WidgetMethodChannelService: File size: ${jsonString.length} characters');

      // Verify the file was written
      if (await file.exists()) {
        final fileSize = await file.length();
        print('✅ WidgetMethodChannelService: File exists, size: $fileSize bytes');

        // Verify the content can be read back
        try {
          final content = await file.readAsString();
          final parsedHabits = jsonDecode(content) as List;
          print('✅ WidgetMethodChannelService: Verified file content - ${parsedHabits.length} habits readable');
        } catch (e) {
          print('❌ WidgetMethodChannelService: Error verifying file content: $e');
        }
      } else {
        print('❌ WidgetMethodChannelService: File does not exist after writing!');
      }
    } catch (e) {
      print('❌ WidgetMethodChannelService: Error writing habits to shared container: $e');
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
    final formationProbability = habit.calculateHabitProbability();
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
      'flutterFormationProbability': formationProbability,
      'flutterLongestStreak': longestStreak,
      'flutterCurrentStreak': currentStreak,
      'flutterCompletedDays': completedDays,
      'flutterTotalDays': totalDays,
    };
  }

  /// Check for completion updates from widget
  Future<List<Map<String, dynamic>>> checkForCompletionUpdates() async {
    try {
      final containerPath = await _getAppGroupContainerPath();
      if (containerPath == null) return [];

      final filePath = '$containerPath/completion_updates.json';
      final file = File(filePath);

      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final updates = List<Map<String, dynamic>>.from(jsonDecode(content));

      // Clear the file after reading
      await file.delete();

      return updates;
    } catch (e) {
      print('Error checking for completion updates: $e');
      return [];
    }
  }

  /// Sync habits via Method Channel to iOS
  Future<void> _syncHabitsViaMethodChannel(List<Habit> habits) async {
    try {
      // Convert habits to JSON string
      final widgetHabits = habits.map((habit) => _convertHabitForWidget(habit)).toList();
      final habitsJson = jsonEncode(widgetHabits);

      // Debug: Print habit IDs being sent
      print('🔄 Method Channel: Syncing ${habits.length} habits:');
      for (final habit in widgetHabits) {
        print('  - ID: "${habit['id']}", Name: "${habit['habitName']}", Status: "${habit['status']}"');
      }

      // Call iOS Method Channel
      await _channel.invokeMethod('syncHabitsToWidget', {'habits': habitsJson});

      print('✅ Synced ${habits.length} habits via Method Channel');
    } catch (e) {
      print('❌ Error syncing habits via Method Channel: $e');
    }
  }
}
