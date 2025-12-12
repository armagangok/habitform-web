import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Position data for a habit on the canvas
class HabitPosition {
  final String habitId;
  final double x;
  final double y;

  const HabitPosition({
    required this.habitId,
    required this.x,
    required this.y,
  });

  HabitPosition copyWith({double? x, double? y}) {
    return HabitPosition(
      habitId: habitId,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  Map<String, dynamic> toJson() => {
        'habitId': habitId,
        'x': x,
        'y': y,
      };

  factory HabitPosition.fromJson(Map<String, dynamic> json) => HabitPosition(
        habitId: json['habitId'] as String,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}

/// Connection between two habits
class HabitConnection {
  final String fromHabitId;
  final String toHabitId;

  const HabitConnection({
    required this.fromHabitId,
    required this.toHabitId,
  });

  String get id => '${fromHabitId}_$toHabitId';

  Map<String, dynamic> toJson() => {
        'fromHabitId': fromHabitId,
        'toHabitId': toHabitId,
      };

  factory HabitConnection.fromJson(Map<String, dynamic> json) => HabitConnection(
        fromHabitId: json['fromHabitId'] as String,
        toHabitId: json['toHabitId'] as String,
      );

  @override
  bool operator ==(Object other) => identical(this, other) || other is HabitConnection && ((fromHabitId == other.fromHabitId && toHabitId == other.toHabitId) || (fromHabitId == other.toHabitId && toHabitId == other.fromHabitId));

  @override
  int get hashCode => fromHabitId.hashCode ^ toHabitId.hashCode;
}

/// Canvas state containing all positions and connections
class HabitCanvasState {
  final Map<String, HabitPosition> positions;
  final Set<HabitConnection> connections;
  final double scale;
  final double offsetX;
  final double offsetY;

  const HabitCanvasState({
    this.positions = const {},
    this.connections = const {},
    this.scale = 1.0,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
  });

  HabitCanvasState copyWith({
    Map<String, HabitPosition>? positions,
    Set<HabitConnection>? connections,
    double? scale,
    double? offsetX,
    double? offsetY,
  }) {
    return HabitCanvasState(
      positions: positions ?? this.positions,
      connections: connections ?? this.connections,
      scale: scale ?? this.scale,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
    );
  }

  Map<String, dynamic> toJson() => {
        'positions': positions.values.map((p) => p.toJson()).toList(),
        'connections': connections.map((c) => c.toJson()).toList(),
        'scale': scale,
        'offsetX': offsetX,
        'offsetY': offsetY,
      };

  factory HabitCanvasState.fromJson(Map<String, dynamic> json) {
    final positionsList = (json['positions'] as List?)?.map((p) => HabitPosition.fromJson(p as Map<String, dynamic>)).toList() ?? [];
    final connectionsList = (json['connections'] as List?)?.map((c) => HabitConnection.fromJson(c as Map<String, dynamic>)).toSet() ?? {};

    return HabitCanvasState(
      positions: {for (var p in positionsList) p.habitId: p},
      connections: connectionsList,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0.0,
      offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Storage service for canvas state
class HabitCanvasStorage {
  static const String _key = 'habit_canvas_state';

  static Future<HabitCanvasState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      if (jsonString == null) return const HabitCanvasState();

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HabitCanvasState.fromJson(json);
    } catch (e) {
      return const HabitCanvasState();
    }
  }

  static Future<void> save(HabitCanvasState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      // Silently fail
    }
  }
}
