import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:habitform/core/core.dart';
import 'package:habitform/models/habit/habit_extension.dart';

import '../models/completion_entry/completion_entry.dart';
import '../models/habit/habit_model.dart';
import 'widget_service.dart';

/// Service for handling Method Channel communication with iOS widgets
class WidgetMethodChannelService {
  static const MethodChannel _channel = MethodChannel('com.appsweat.habitrise/widget');
  // static const String _appGroupIdentifier = 'group.com.AppSweat.HabitFormWidget';

  // Cache for widget data to avoid repeated file operations
  List<Habit>? _cachedHabits;
  DateTime? _lastCacheUpdate;

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
        LogHelper.shared.debugPrint('📁 Created App Group container directory: $containerPath');
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
      LogHelper.shared.debugPrint('✅ Written completion update for habit: $habitId');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error writing completion update: $e');
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
          LogHelper.shared.debugPrint('📁 Method Channel App Group container path from iOS: $result');
          return result as String;
        } else {
          LogHelper.shared.debugPrint('❌ iOS returned null for App Group container path');
          return null;
        }
      }
      return null;
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error getting App Group container path: $e');
      return null;
    }
  }

  /// Called by main app to update widget data
  Future<void> updateWidgetData(List<Habit> habits, {bool isProMember = false}) async {
    if (!Platform.isIOS) return;

    final methodChannelStart = DateTime.now();
    LogHelper.shared.debugPrint('📡 [PERF] WidgetMethodChannelService: Starting updateWidgetData at ${methodChannelStart.millisecondsSinceEpoch}');

    // Check if we can use cached data to avoid unnecessary operations
    final now = DateTime.now();
    if (_cachedHabits != null && _lastCacheUpdate != null && now.difference(_lastCacheUpdate!).inSeconds < 2 && _habitsAreEqual(_cachedHabits!, habits)) {
      LogHelper.shared.debugPrint('⏭️ WidgetMethodChannelService: Using cached data (no changes detected)');
      return;
    }

    LogHelper.shared.debugPrint('🔄 WidgetMethodChannelService: updateWidgetData called with ${habits.length} habits');

    // Filter out archived habits and ensure we have valid habits
    final activeHabits = habits.where((habit) => habit.status.name == 'active').toList();
    LogHelper.shared.debugPrint('🔄 WidgetMethodChannelService: ${activeHabits.length} active habits after filtering');

    for (final habit in activeHabits) {
      LogHelper.shared.debugPrint('  - ${habit.habitName} (${habit.id}) - ${habit.completions.length} completions');
    }

    try {
      // Export habits for widget using existing WidgetService
      LogHelper.shared.debugPrint('📤 WidgetMethodChannelService: Exporting habits via WidgetService...');
      final exportStart = DateTime.now();
      await WidgetService().exportHabitsForWidget(activeHabits);
      final exportEnd = DateTime.now();
      LogHelper.shared.debugPrint('📤 [PERF] WidgetService export completed in ${exportEnd.difference(exportStart).inMilliseconds}ms');

      // Also write to the new format for Method Channel communication
      LogHelper.shared.debugPrint('📤 WidgetMethodChannelService: Writing habits to shared container...');
      final writeStart = DateTime.now();
      await _writeHabitsToSharedContainer(activeHabits, isProMember: isProMember);
      final writeEnd = DateTime.now();
      LogHelper.shared.debugPrint('📤 [PERF] Shared container write completed in ${writeEnd.difference(writeStart).inMilliseconds}ms');

      // Use Method Channel to sync with iOS
      LogHelper.shared.debugPrint('📤 WidgetMethodChannelService: Syncing habits via Method Channel...');
      final syncStart = DateTime.now();
      await _syncHabitsViaMethodChannel(activeHabits, isProMember: isProMember);
      final syncEnd = DateTime.now();
      LogHelper.shared.debugPrint('📤 [PERF] Method channel sync completed in ${syncEnd.difference(syncStart).inMilliseconds}ms');

      // Force reload widget timelines
      LogHelper.shared.debugPrint('📤 WidgetMethodChannelService: Force reloading widget timelines...');
      final reloadStart = DateTime.now();
      await _forceReloadWidgetTimelines();
      final reloadEnd = DateTime.now();
      LogHelper.shared.debugPrint('📤 [PERF] Widget timeline reload completed in ${reloadEnd.difference(reloadStart).inMilliseconds}ms');

      // Update cache
      _cachedHabits = List.from(habits);
      _lastCacheUpdate = now;

      final methodChannelEnd = DateTime.now();
      LogHelper.shared.debugPrint('✅ [PERF] WidgetMethodChannelService total time: ${methodChannelEnd.difference(methodChannelStart).inMilliseconds}ms');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ WidgetMethodChannelService: Error updating widget data: $e');
    }
  }

  /// Check if two habit lists are equal (for caching purposes)
  bool _habitsAreEqual(List<Habit> habits1, List<Habit> habits2) {
    if (habits1.length != habits2.length) return false;

    for (int i = 0; i < habits1.length; i++) {
      final habit1 = habits1[i];
      final habit2 = habits2[i];

      if (habit1.id != habit2.id || habit1.habitName != habit2.habitName || habit1.completions.length != habit2.completions.length) {
        return false;
      }
    }

    return true;
  }

  /// Force reload all widget timelines
  Future<void> _forceReloadWidgetTimelines() async {
    try {
      await _channel.invokeMethod('forceReloadWidgetTimelines');
      LogHelper.shared.debugPrint('✅ WidgetMethodChannelService: Forced widget timeline reload');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ WidgetMethodChannelService: Error forcing widget timeline reload: $e');
    }
  }

  /// Write habits to shared container in Method Channel format
  Future<void> _writeHabitsToSharedContainer(List<Habit> habits, {bool isProMember = false}) async {
    try {
      final containerPath = await _getAppGroupContainerPath();
      if (containerPath == null) {
        LogHelper.shared.debugPrint('❌ WidgetMethodChannelService: Failed to get App Group container path');
        return;
      }

      LogHelper.shared.debugPrint('📁 WidgetMethodChannelService: Using container path: $containerPath');

      // Create the directory if it doesn't exist
      final containerDir = Directory(containerPath);
      if (!await containerDir.exists()) {
        await containerDir.create(recursive: true);
        LogHelper.shared.debugPrint('📁 WidgetMethodChannelService: Created App Group container directory: $containerPath');
      } else {
        LogHelper.shared.debugPrint('📁 WidgetMethodChannelService: Container directory already exists');
      }

      final filePath = '$containerPath/habits.json';
      final file = File(filePath);
      LogHelper.shared.debugPrint('📄 WidgetMethodChannelService: Writing to file: $filePath');

      // Convert habits to widget-compatible format
      final widgetHabits = habits.map((habit) => _convertHabitForWidget(habit, isProMember: isProMember)).toList();
      LogHelper.shared.debugPrint('🔄 WidgetMethodChannelService: Converted ${habits.length} habits to widget format');

      // Write to file with atomic operation
      final jsonString = jsonEncode(widgetHabits);
      final tempFilePath = '$filePath.tmp';
      final tempFile = File(tempFilePath);

      // Write to temporary file first
      await tempFile.writeAsString(jsonString);

      // Atomically move to final location
      await tempFile.rename(filePath);

      LogHelper.shared.debugPrint('✅ WidgetMethodChannelService: Written ${widgetHabits.length} habits to $filePath');
      LogHelper.shared.debugPrint('📊 WidgetMethodChannelService: File size: ${jsonString.length} characters');

      // Verify the file was written
      if (await file.exists()) {
        final fileSize = await file.length();
        LogHelper.shared.debugPrint('✅ WidgetMethodChannelService: File exists, size: $fileSize bytes');

        // Verify the content can be read back
        try {
          final content = await file.readAsString();
          final parsedHabits = jsonDecode(content) as List;
          LogHelper.shared.debugPrint('✅ WidgetMethodChannelService: Verified file content - ${parsedHabits.length} habits readable');
        } catch (e) {
          LogHelper.shared.debugPrint('❌ WidgetMethodChannelService: Error verifying file content: $e');
        }
      } else {
        LogHelper.shared.debugPrint('❌ WidgetMethodChannelService: File does not exist after writing!');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('❌ WidgetMethodChannelService: Error writing habits to shared container: $e');
    }
  }

  /// Convert Flutter Habit model to widget-compatible format
  Map<String, dynamic> _convertHabitForWidget(Habit habit, {bool isProMember = false}) {
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

    // Align "Total Days" with Habit Detail: days since first completion (inclusive)
    int totalDaysSinceFirstCompletion = 0;
    final firstCompletionDate = habit.getFirstCompletionDate();
    if (firstCompletionDate != null) {
      final startDate = DateUtils.dateOnly(firstCompletionDate);
      final today = DateTime.now();
      totalDaysSinceFirstCompletion = today.difference(startDate).inDays + 1;
    }

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
      'flutterTotalDays': totalDaysSinceFirstCompletion,
      // Pro membership status
      'isProMember': isProMember,
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
      LogHelper.shared.debugPrint('Error checking for completion updates: $e');
      return [];
    }
  }

  /// Sync habits via Method Channel to iOS
  Future<void> _syncHabitsViaMethodChannel(List<Habit> habits, {bool isProMember = false}) async {
    try {
      // Convert habits to JSON string
      final widgetHabits = habits.map((habit) => _convertHabitForWidget(habit, isProMember: isProMember)).toList();
      final habitsJson = jsonEncode(widgetHabits);

      // Debug: LogHelper.shared.debugPrint habit IDs being sent
      LogHelper.shared.debugPrint('🔄 Method Channel: Syncing ${habits.length} habits:');
      for (final habit in widgetHabits) {
        LogHelper.shared.debugPrint('  - ID: "${habit['id']}", Name: "${habit['habitName']}", Status: "${habit['status']}"');
      }

      // Call iOS Method Channel
      await _channel.invokeMethod('syncHabitsToWidget', {'habits': habitsJson});

      LogHelper.shared.debugPrint('✅ Synced ${habits.length} habits via Method Channel');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error syncing habits via Method Channel: $e');
    }
  }
}
