import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_model.dart';
import 'habit_canvas_model.dart';

/// Provider for the canvas state
final habitCanvasProvider = StateNotifierProvider<HabitCanvasNotifier, HabitCanvasState>((ref) {
  return HabitCanvasNotifier();
});

/// Notifier for managing habit canvas state
class HabitCanvasNotifier extends StateNotifier<HabitCanvasState> {
  HabitCanvasNotifier() : super(const HabitCanvasState()) {
    _loadStateFuture = _loadState();
  }

  late final Future<void> _loadStateFuture;
  bool _isLoaded = false;

  // Debounce timer for position updates to avoid excessive disk I/O
  Timer? _saveStateTimer;
  static const Duration _saveDebounceDuration = Duration(milliseconds: 300);

  Future<void> _loadState() async {
    final loadedState = await HabitCanvasStorage.load();
    state = loadedState;
    _isLoaded = true;
  }

  /// Wait for initial state to be loaded
  Future<void> ensureLoaded() async {
    if (!_isLoaded) {
      await _loadStateFuture;
    }
  }

  Future<void> _saveState({bool immediate = false}) async {
    if (immediate) {
      _saveStateTimer?.cancel();
      await HabitCanvasStorage.save(state);
    } else {
      _saveStateTimer?.cancel();
      _saveStateTimer = Timer(_saveDebounceDuration, () async {
        await HabitCanvasStorage.save(state);
      });
    }
  }

  /// Initialize positions for habits that don't have positions yet
  /// Accepts both Habit and HabitSummary (both have id field)
  Future<void> initializePositions(List<dynamic> habits, double canvasWidth, double canvasHeight) async {
    // Ensure state is loaded before initializing
    await ensureLoaded();

    final updatedPositions = Map<String, HabitPosition>.from(state.positions);
    bool hasChanges = false;

    // Remove positions for habits that no longer exist
    final habitIds = habits.map((h) => h.id as String).toSet();
    updatedPositions.removeWhere((key, _) => !habitIds.contains(key));

    // Add positions for new habits
    final random = math.Random();
    final centerX = canvasWidth / 2;
    final centerY = canvasHeight / 2;

    for (final habit in habits) {
      final habitId = habit.id as String;
      if (!updatedPositions.containsKey(habitId)) {
        // Place new habits in a circular pattern around center
        final existingCount = updatedPositions.length;
        final angle = (existingCount * 2 * math.pi / math.max(habits.length, 1)) + random.nextDouble() * 0.5;
        final radius = 100.0 + random.nextDouble() * 150;

        updatedPositions[habitId] = HabitPosition(
          habitId: habitId,
          x: centerX + math.cos(angle) * radius,
          y: centerY + math.sin(angle) * radius,
        );
        hasChanges = true;
      }
    }

    if (hasChanges || updatedPositions.length != state.positions.length) {
      state = state.copyWith(positions: updatedPositions);
      _saveState(immediate: true); // Immediate save for initialization
    }
  }

  /// Update position of a single habit
  /// Uses debounced save to avoid excessive disk I/O during dragging
  void updatePosition(String habitId, double x, double y) {
    final updatedPositions = Map<String, HabitPosition>.from(state.positions);
    updatedPositions[habitId] = HabitPosition(habitId: habitId, x: x, y: y);
    state = state.copyWith(positions: updatedPositions);
    _saveState(); // Debounced save
  }

  /// Add a connection between two habits
  void addConnection(String fromHabitId, String toHabitId) {
    if (fromHabitId == toHabitId) return;

    final connection = HabitConnection(fromHabitId: fromHabitId, toHabitId: toHabitId);
    final updatedConnections = Set<HabitConnection>.from(state.connections);

    // Check if connection already exists (in either direction)
    final exists = updatedConnections.any((c) => (c.fromHabitId == fromHabitId && c.toHabitId == toHabitId) || (c.fromHabitId == toHabitId && c.toHabitId == fromHabitId));

    if (!exists) {
      updatedConnections.add(connection);
      state = state.copyWith(connections: updatedConnections);
      _saveState(immediate: true); // Immediate save for user actions
    }
  }

  /// Remove a connection between two habits
  void removeConnection(String fromHabitId, String toHabitId) {
    final updatedConnections = Set<HabitConnection>.from(state.connections);
    updatedConnections.removeWhere((c) => (c.fromHabitId == fromHabitId && c.toHabitId == toHabitId) || (c.fromHabitId == toHabitId && c.toHabitId == fromHabitId));
    state = state.copyWith(connections: updatedConnections);
    _saveState(immediate: true); // Immediate save for user actions
  }

  /// Toggle connection between two habits
  void toggleConnection(String fromHabitId, String toHabitId) {
    if (fromHabitId == toHabitId) return;

    final exists = state.connections.any((c) => (c.fromHabitId == fromHabitId && c.toHabitId == toHabitId) || (c.fromHabitId == toHabitId && c.toHabitId == fromHabitId));

    if (exists) {
      removeConnection(fromHabitId, toHabitId);
    } else {
      addConnection(fromHabitId, toHabitId);
    }
  }

  /// Update canvas scale
  void updateScale(double scale) {
    state = state.copyWith(scale: scale.clamp(0.3, 3.0));
    _saveState(); // Debounced save for smooth zoom/pan
  }

  /// Update canvas offset
  void updateOffset(double offsetX, double offsetY) {
    state = state.copyWith(offsetX: offsetX, offsetY: offsetY);
    _saveState(); // Debounced save for smooth zoom/pan
  }

  /// Update canvas scale and offset immediately (for interaction end)
  /// Also saves the raw matrix values for precise restoration
  void updateTransformImmediate(double scale, double offsetX, double offsetY, {List<double>? matrixValues}) {
    LogHelper.shared.debugPrint('🟡 [CanvasProvider] updateTransformImmediate called - scale: $scale, offsetX: $offsetX, offsetY: $offsetY, hasMatrix: ${matrixValues != null}');
    state = state.copyWith(
      scale: scale.clamp(0.3, 3.0),
      offsetX: offsetX,
      offsetY: offsetY,
      matrixValues: matrixValues,
    );
    // Use unawaited to ensure save happens without blocking, but still executes
    unawaited(_saveState(immediate: true)); // Immediate save for interaction end
  }

  /// Reset all positions to default layout
  Future<void> resetLayout(List<Habit> habits, double canvasWidth, double canvasHeight) async {
    // Create a fresh state to clear matrixValues
    state = HabitCanvasState(
      positions: const {},
      connections: state.connections, // Keep connections
      scale: 1.0,
      offsetX: 0.0,
      offsetY: 0.0,
      matrixValues: null, // Clear saved matrix
    );
    await initializePositions(habits, canvasWidth, canvasHeight);
  }

  /// Clear all connections
  void clearConnections() {
    state = state.copyWith(connections: {});
    _saveState(immediate: true); // Immediate save for user actions
  }
}
