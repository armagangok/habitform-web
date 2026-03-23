import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/auth/providers/auth_provider.dart';
import '/models/habit/habit_model.dart';
import '/models/habit/habit_summary.dart';
import '/services/habit_service/habit_service_interface.dart';
import '/services/sync_service.dart';
import 'habit_canvas_model.dart';

/// Provider for the canvas state
final habitCanvasProvider = StateNotifierProvider<HabitCanvasNotifier, HabitCanvasState>((ref) {
  final notifier = HabitCanvasNotifier(ref);
  ref.onDispose(() {
    unawaited(notifier.flushPendingRemoteSync());
  });
  return notifier;
});

/// Notifier for managing habit canvas state
class HabitCanvasNotifier extends StateNotifier<HabitCanvasState> {
  final Ref _ref;
  HabitCanvasNotifier(this._ref) : super(const HabitCanvasState()) {
    _loadStateFuture = _loadState();
  }

  late final Future<void> _loadStateFuture;
  bool _isLoaded = false;

  // Debounce timer for position updates to avoid excessive disk I/O
  Timer? _saveStateTimer;
  static const Duration _saveDebounceDuration = Duration(milliseconds: 300);

  /// Firestore writes for habit positions / canvas: single idle window — any canvas-related
  /// activity resets this timer; all pending remote work runs once after 3s of no activity.
  static const Duration _firebaseDebounceDuration = Duration(seconds: 3);

  Timer? _remoteFirebaseIdleTimer;
  final Set<String> _pendingRemoteHabitIds = {};

  double? _pendingCanvasFirestoreScale;
  double? _pendingCanvasFirestoreOffsetX;
  double? _pendingCanvasFirestoreOffsetY;

  Future<void> _loadState() async {
    // 1. Load local state for migration/fallback
    final localState = await HabitCanvasStorage.load();

    // 2. Load global canvas state from user profile if available
    final userProfile = await _ref.read(userProfileProvider.future);
    final scale = userProfile?.canvasScale ?? localState.scale;
    final offsetX = userProfile?.canvasOffsetX ?? localState.offsetX;
    final offsetY = userProfile?.canvasOffsetY ?? localState.offsetY;

    state = localState.copyWith(
      scale: scale,
      offsetX: offsetX,
      offsetY: offsetY,
    );
    _isLoaded = true;
  }

  /// Wait for initial state to be loaded
  Future<void> ensureLoaded() async {
    if (!_isLoaded) {
      await _loadStateFuture;
    }
  }

  Future<void> _saveLocalState({bool immediate = false}) async {
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
  ///
  /// [shouldAbort] — when it returns true (e.g. host widget disposed), skips any
  /// [state] mutation so Riverpod does not try to rebuild a defunct element.
  Future<void> initializePositions(
    List<dynamic> habits,
    double canvasWidth,
    double canvasHeight, {
    bool Function()? shouldAbort,
  }) async {
    // Ensure state is loaded before initializing
    await ensureLoaded();
    if (shouldAbort?.call() ?? false) return;

    final updatedPositions = Map<String, HabitPosition>.from(state.positions);
    final updatedConnections = Set<HabitConnection>.from(state.connections);
    bool hasChanges = false;

    // Load local storage as a fallback for migration
    final localState = await HabitCanvasStorage.load();
    if (shouldAbort?.call() ?? false) return;

    for (final habit in habits) {
      if (shouldAbort?.call() ?? false) return;
      final habitId = (habit is Habit) ? habit.id : (habit as HabitSummary).id;

      // 1. Try to get position from the habit itself
      double? posX;
      double? posY;
      List<String> linkedIds = [];

      if (habit is Habit) {
        posX = habit.constellationPosX;
        posY = habit.constellationPosY;
        linkedIds = habit.linkedHabitIds;
      } else if (habit is HabitSummary) {
        posX = habit.constellationPosX;
        posY = habit.constellationPosY;
        linkedIds = habit.linkedHabitIds;
      }

      // 2. Migration fallback: If habit doesn't have position, use localState
      if (posX == null || posY == null) {
        final localPos = localState.positions[habitId];
        if (localPos != null) {
          posX = localPos.x;
          posY = localPos.y;
          // Mark as changed so we save it back to the Habit model later
          hasChanges = true;
        }
      }

      // 3. Last fallback: random circular pattern
      if (posX == null || posY == null) {
        final random = math.Random();
        final centerX = canvasWidth / 2;
        final centerY = canvasHeight / 2;
        final existingCount = updatedPositions.length;
        final angle = (existingCount * 2 * math.pi / math.max(habits.length, 1)) + random.nextDouble() * 0.5;
        final radius = 100.0 + random.nextDouble() * 150;

        posX = centerX + math.cos(angle) * radius;
        posY = centerY + math.sin(angle) * radius;
        hasChanges = true;
      }

      // 4. Update state and detect changes from model (important for device sync)
      final existingPos = updatedPositions[habitId];
      if (existingPos == null || existingPos.x != posX || existingPos.y != posY) {
        updatedPositions[habitId] = HabitPosition(habitId: habitId, x: posX, y: posY);
        hasChanges = true;
      }

      // 5. Update connections from linkedHabitIds
      for (final targetId in linkedIds) {
        final connection = HabitConnection(fromHabitId: habitId, toHabitId: targetId);
        if (!updatedConnections.contains(connection)) {
          updatedConnections.add(connection);
          hasChanges = true;
        }
      }
    }

    // 5. Cleanup connections for non-existent habits
    final habitIds = habits.map((h) => (h is Habit) ? h.id : (h as HabitSummary).id).toSet();
    updatedConnections.removeWhere((c) => !habitIds.contains(c.fromHabitId) || !habitIds.contains(c.toHabitId));

    if (shouldAbort?.call() ?? false) return;

    if (hasChanges || updatedPositions.length != state.positions.length || updatedConnections.length != state.connections.length) {
      state = state.copyWith(positions: updatedPositions, connections: updatedConnections);
      unawaited(_saveLocalState(immediate: true));

      // If we migrated or generated new positions, update the habits themselves
      if (hasChanges) {
        for (final habit in habits) {
          final habitId = (habit is Habit) ? habit.id : (habit as HabitSummary).id;
          final pos = updatedPositions[habitId]!;
          if (habit is Habit) {
            if (habit.constellationPosX != pos.x || habit.constellationPosY != pos.y) {
              _updateHabitModelPosition(habit, pos.x, pos.y);
            }
          }
        }
      }
    }
  }

  /// Update position of a single habit
  void updatePosition(String habitId, double x, double y) {
    final updatedPositions = Map<String, HabitPosition>.from(state.positions);
    updatedPositions[habitId] = HabitPosition(habitId: habitId, x: x, y: y);
    state = state.copyWith(positions: updatedPositions);

    _saveLocalState();

    // Update the Habit model itself to trigger sync
    _deferHabitUpdate(habitId, (habit) => habit.copyWith(constellationPosX: x, constellationPosY: y));
  }

  Timer? _habitUpdateDebounce;
  final Map<String, Habit> _pendingHabitUpdates = {};

  void _deferHabitUpdate(String habitId, Habit Function(Habit) updater) async {
    final habit = await habitService.getHabit(habitId);
    if (habit == null) return;

    final updatedHabit = updater(habit);
    _pendingHabitUpdates[habitId] = updatedHabit;

    _habitUpdateDebounce?.cancel();
    _habitUpdateDebounce = Timer(_saveDebounceDuration, () async {
      final ids = _pendingHabitUpdates.keys.toList();
      for (final habit in _pendingHabitUpdates.values) {
        await habitService.updateHabit(habit, skipRemoteSync: true);
      }
      _pendingHabitUpdates.clear();
      for (final id in ids) {
        _pendingRemoteHabitIds.add(id);
      }
      _scheduleRemoteFirebaseIdleSync();
    });
  }

  /// Resets the 3s idle clock on every call. Dragging another item, zoom, or pan after a drop
  /// all keep pushing the Firestore flush until the user is idle for a full [_firebaseDebounceDuration].
  void _scheduleRemoteFirebaseIdleSync() {
    _remoteFirebaseIdleTimer?.cancel();
    _remoteFirebaseIdleTimer = Timer(_firebaseDebounceDuration, () async {
      await _runPendingRemoteFirebaseWrites();
    });
  }

  Future<void> _runPendingRemoteFirebaseWrites() async {
    final sync = _ref.read(syncServiceProvider);

    final ids = _pendingRemoteHabitIds.toList();
    _pendingRemoteHabitIds.clear();
    for (final id in ids) {
      final h = await habitService.getHabit(id);
      if (h != null) {
        try {
          await sync.syncHabit(h);
        } catch (e, st) {
          LogHelper.shared.debugPrint('❌ Idle sync syncHabit failed for $id: $e\n$st');
        }
      }
    }

    final s = _pendingCanvasFirestoreScale;
    final ox = _pendingCanvasFirestoreOffsetX;
    final oy = _pendingCanvasFirestoreOffsetY;
    if (s != null && ox != null && oy != null) {
      try {
        await sync.updateCanvasState(s, ox, oy);
        _pendingCanvasFirestoreScale = null;
        _pendingCanvasFirestoreOffsetX = null;
        _pendingCanvasFirestoreOffsetY = null;
      } catch (e, st) {
        LogHelper.shared.debugPrint('❌ Idle sync updateCanvasState failed: $e\n$st');
      }
    }
  }

  /// Pushes any pending Firestore writes immediately (e.g. app background / provider dispose).
  Future<void> flushPendingRemoteSync() async {
    _habitUpdateDebounce?.cancel();
    _remoteFirebaseIdleTimer?.cancel();

    if (_pendingHabitUpdates.isNotEmpty) {
      final ids = _pendingHabitUpdates.keys.toList();
      for (final habit in _pendingHabitUpdates.values) {
        await habitService.updateHabit(habit, skipRemoteSync: true);
      }
      _pendingHabitUpdates.clear();
      for (final id in ids) {
        _pendingRemoteHabitIds.add(id);
      }
    }

    await _runPendingRemoteFirebaseWrites();
  }

  Future<void> _updateHabitModelPosition(Habit habit, double x, double y) async {
    await habitService.updateHabit(habit.copyWith(constellationPosX: x, constellationPosY: y));
  }

  /// Toggle connection between two habits
  void toggleConnection(String fromHabitId, String toHabitId) async {
    if (fromHabitId == toHabitId) return;

    final exists = state.connections.any((c) => (c.fromHabitId == fromHabitId && c.toHabitId == toHabitId) || (c.fromHabitId == toHabitId && c.toHabitId == fromHabitId));

    final fromHabit = await habitService.getHabit(fromHabitId);
    final toHabit = await habitService.getHabit(toHabitId);

    if (fromHabit == null || toHabit == null) return;

    final updatedFromLinks = List<String>.from(fromHabit.linkedHabitIds);
    final updatedToLinks = List<String>.from(toHabit.linkedHabitIds);

    if (exists) {
      updatedFromLinks.remove(toHabitId);
      updatedToLinks.remove(fromHabitId);
    } else {
      if (!updatedFromLinks.contains(toHabitId)) updatedFromLinks.add(toHabitId);
      if (!updatedToLinks.contains(fromHabitId)) updatedToLinks.add(fromHabitId);
    }

    await habitService.updateHabit(fromHabit.copyWith(linkedHabitIds: updatedFromLinks));
    await habitService.updateHabit(toHabit.copyWith(linkedHabitIds: updatedToLinks));

    // Update local state
    final updatedConnections = Set<HabitConnection>.from(state.connections);
    if (exists) {
      updatedConnections.removeWhere((c) => (c.fromHabitId == fromHabitId && c.toHabitId == toHabitId) || (c.fromHabitId == toHabitId && c.toHabitId == fromHabitId));
    } else {
      updatedConnections.add(HabitConnection(fromHabitId: fromHabitId, toHabitId: toHabitId));
    }

    state = state.copyWith(connections: updatedConnections);
    _saveLocalState(immediate: true);
  }

  /// Update canvas scale
  void updateScale(double scale) {
    state = state.copyWith(scale: scale.clamp(0.3, 3.0));
    _saveLocalState();
  }

  /// Update canvas offset
  void updateOffset(double offsetX, double offsetY) {
    state = state.copyWith(offsetX: offsetX, offsetY: offsetY);
    _saveLocalState();
  }

  /// Update canvas scale and offset immediately (for interaction end)
  void updateTransformImmediate(double scale, double offsetX, double offsetY, {List<double>? matrixValues}) {
    LogHelper.shared.debugPrint('🟡 [CanvasProvider] updateTransformImmediate called - scale: $scale, offsetX: $offsetX, offsetY: $offsetY');
    state = state.copyWith(
      scale: scale.clamp(0.3, 3.0),
      offsetX: offsetX,
      offsetY: offsetY,
      matrixValues: matrixValues,
    );

    unawaited(_saveLocalState(immediate: true));

    _pendingCanvasFirestoreScale = scale;
    _pendingCanvasFirestoreOffsetX = offsetX;
    _pendingCanvasFirestoreOffsetY = offsetY;
    _scheduleRemoteFirebaseIdleSync();
  }

  /// Reset all positions to default layout
  Future<void> resetLayout(List<Habit> habits, double canvasWidth, double canvasHeight) async {
    state = HabitCanvasState(
      positions: const {},
      connections: state.connections,
      scale: 1.0,
      offsetX: 0.0,
      offsetY: 0.0,
      matrixValues: null,
    );

    // Reset positions on habit models too
    for (final habit in habits) {
      await habitService.updateHabit(habit.copyWith(constellationPosX: null, constellationPosY: null));
    }

    await initializePositions(habits, canvasWidth, canvasHeight);
  }

  /// Clear all connections
  void clearConnections() async {
    final activeHabits = await habitService.getHabits();
    for (final habit in activeHabits) {
      if (habit.linkedHabitIds.isNotEmpty) {
        await habitService.updateHabit(habit.copyWith(linkedHabitIds: []));
      }
    }
    state = state.copyWith(connections: {});
    _saveLocalState(immediate: true);
  }
}
