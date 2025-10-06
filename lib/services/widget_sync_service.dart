import 'dart:async';
import 'dart:io';

import '../core/helpers/logger/logger.dart';
import '../models/completion_entry/completion_entry.dart';
import '../models/habit/habit_model.dart';
import 'habit_service/habit_service_interface.dart';
import 'habit_service/local_habit_service.dart';
import 'widget_method_channel_service.dart';

/// Service to handle synchronization between Flutter app and iOS widgets
class WidgetSyncService {
  static final WidgetSyncService _instance = WidgetSyncService._internal();
  factory WidgetSyncService() => _instance;
  WidgetSyncService._internal();

  final WidgetMethodChannelService _methodChannelService = WidgetMethodChannelService();
  final HabitService _habitService = LocalHabitService.instance;

  Timer? _syncTimer;
  Timer? _debounceTimer;
  bool _isInitialized = false;
  List<Habit>? _pendingHabits;
  DateTime? _lastWidgetUpdate;

  // Stream controller for widget updates
  final StreamController<Map<String, dynamic>> _widgetUpdateController = StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of widget updates
  Stream<Map<String, dynamic>> get widgetUpdates => _widgetUpdateController.stream;

  /// Initialize the sync service
  Future<void> initialize() async {
    if (_isInitialized || !Platform.isIOS) {
      LogHelper.shared.debugPrint('WidgetSyncService: ${_isInitialized ? "Already initialized" : "Not iOS platform"}');

      return;
    }

    _isInitialized = true;

    LogHelper.shared.debugPrint('🚀 WidgetSyncService initialized successfully');

    // Start periodic sync to check for widget updates
    _startPeriodicSync();

    // Check for any pending updates immediately
    await checkForWidgetUpdates();

    // Force initial widget data sync
    await _forceInitialWidgetSync();
  }

  /// Start periodic sync timer
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkForWidgetUpdates();
    });
  }

  /// Stop the sync service
  void dispose() {
    _syncTimer?.cancel();
    _debounceTimer?.cancel();
    _widgetUpdateController.close();
    _isInitialized = false;
  }

  /// Check for completion updates from widgets
  Future<void> checkForWidgetUpdates() async {
    try {
      final updates = await _methodChannelService.checkForCompletionUpdates();

      for (final update in updates) {
        await _processWidgetUpdate(update);
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error checking for widget updates: $e');
    }
  }

  /// Process a single widget update
  Future<void> _processWidgetUpdate(Map<String, dynamic> update) async {
    try {
      final habitId = update['habitId'] as String;
      final completionData = update['completion'] as Map<String, dynamic>;

      // Parse completion entry
      final completion = CompletionEntry(
        id: completionData['id'] as String,
        date: DateTime.parse(completionData['date'] as String),
        isCompleted: completionData['isCompleted'] as bool,
        count: completionData['count'] as int,
      );

      // Update the habit in the main app
      await _habitService.updateHabitCompletionStatus(habitId, completion);

      // Notify listeners that a widget update occurred
      _notifyWidgetUpdateListeners(habitId, completion);

      LogHelper.shared.debugPrint('✅ Processed widget update for habit $habitId: ${completion.isCompleted} (count: ${completion.count})');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error processing widget update: $e');
    }
  }

  /// Update widget data when habits change in the main app (with debouncing)
  Future<void> updateWidgetData(List<Habit> habits) async {
    if (!Platform.isIOS || !_isInitialized) {
      LogHelper.shared.debugPrint('Widget sync not initialized or not iOS platform');
      return;
    }

    // Store the latest habits for debounced update
    _pendingHabits = habits;

    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    // Set a new debounce timer (500ms delay)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await _performWidgetDataUpdate(_pendingHabits);
    });
  }

  /// Actually perform the widget data update
  Future<void> _performWidgetDataUpdate(List<Habit>? habits) async {
    if (habits == null) return;

    final widgetUpdateStart = DateTime.now();
    LogHelper.shared.debugPrint('📱 [PERF] Starting widget data update at ${widgetUpdateStart.millisecondsSinceEpoch}');

    // Throttle widget updates to prevent too frequent updates
    final now = DateTime.now();
    if (_lastWidgetUpdate != null && now.difference(_lastWidgetUpdate!).inMilliseconds < 1000) {
      LogHelper.shared.debugPrint('⏳ Throttling widget update (too frequent)');
      return;
    }

    try {
      // Update widget data using the method channel service
      final methodChannelStart = DateTime.now();
      await _methodChannelService.updateWidgetData(habits);
      final methodChannelEnd = DateTime.now();
      LogHelper.shared.debugPrint('📡 [PERF] Method channel update completed in ${methodChannelEnd.difference(methodChannelStart).inMilliseconds}ms');

      _lastWidgetUpdate = now;

      final widgetUpdateEnd = DateTime.now();
      LogHelper.shared.debugPrint('✅ [PERF] Widget data update total time: ${widgetUpdateEnd.difference(widgetUpdateStart).inMilliseconds}ms');

      LogHelper.shared.debugPrint('✅ Updated widget data with ${habits.length} habits');
      for (final habit in habits) {
        LogHelper.shared.debugPrint('  - ${habit.habitName} (${habit.id})');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error updating widget data: $e');
    }
  }

  /// Handle habit completion from widget (called by App Intents)
  Future<void> handleWidgetHabitCompletion(String habitId, DateTime date) async {
    if (!Platform.isIOS) return;

    try {
      // Create completion entry
      final completion = CompletionEntry(
        id: '${habitId}_${date.toIso8601DateString}',
        date: date,
        isCompleted: true,
        count: 1,
      );

      // Update in main app database
      await _habitService.updateHabitCompletionStatus(habitId, completion);

      // Update widget data
      final habits = await _habitService.getAllHabits();
      await updateWidgetData(habits);

        LogHelper.shared.debugPrint('Handled widget habit completion for $habitId on $date');
    } catch (e) {
      LogHelper.shared.debugPrint('Error handling widget habit completion: $e');
    }
  }

  /// Handle habit completion update from widget (called by App Intents)
  Future<void> handleWidgetHabitCompletionUpdate(String habitId, DateTime date, bool isCompleted, int count) async {
    if (!Platform.isIOS) return;

    try {
      // Create completion entry
      final completion = CompletionEntry(
        id: '${habitId}_${date.toIso8601DateString}',
        date: date,
        isCompleted: isCompleted,
        count: count,
      );

      // Update in main app database
      await _habitService.updateHabitCompletionStatus(habitId, completion);

      // Update widget data
      final habits = await _habitService.getAllHabits();
      await updateWidgetData(habits);

      LogHelper.shared.debugPrint('Handled widget habit completion update for $habitId on $date: $isCompleted (count: $count)');
    } catch (e) {
      LogHelper.shared.debugPrint('Error handling widget habit completion update: $e');
    }
  }

  /// Force initial widget data sync on app launch
  Future<void> _forceInitialWidgetSync() async {
    try {
      LogHelper.shared.debugPrint('🔄 Forcing initial widget data sync...');

      // Get all habits and sync to widget
      final habits = await _habitService.getAllHabits();
      await updateWidgetData(habits);

      LogHelper.shared.debugPrint('✅ Initial widget data sync completed with ${habits.length} habits');
    } catch (e) {
      LogHelper.shared.debugPrint('❌ Error during initial widget data sync: $e');
    }
  }

  /// Notify listeners of widget updates
  void _notifyWidgetUpdateListeners(String habitId, CompletionEntry completion) {
    _widgetUpdateController.add({
      'habitId': habitId,
      'completion': completion,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

/// Extension to convert DateTime to ISO8601 date string
extension DateTimeExtension on DateTime {
  String toIso8601DateString() {
    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
