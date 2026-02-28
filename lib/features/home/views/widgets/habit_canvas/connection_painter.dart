import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'habit_canvas_model.dart';

/// Painter for drawing connection lines between habits
/// Accepts both Habit and HabitSummary (both have id and colorCode)
class ConnectionPainter extends CustomPainter {
  final Set<HabitConnection> connections;
  final Map<String, HabitPosition> positions;
  final List<dynamic> habits; // Can be List<Habit> or List<HabitSummary>
  final bool isDark;

  ConnectionPainter({
    required this.connections,
    required this.positions,
    required this.habits,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (connections.isEmpty || positions.isEmpty) return;

    // Create a map of habit id to color
    final habitColors = <String, Color>{};
    for (final habit in habits) {
      habitColors[habit.id as String] = Color(habit.colorCode as int);
    }

    for (final connection in connections) {
      final fromPos = positions[connection.fromHabitId];
      final toPos = positions[connection.toHabitId];

      if (fromPos == null || toPos == null) continue;

      final fromColor = habitColors[connection.fromHabitId] ?? Colors.grey;
      final toColor = habitColors[connection.toHabitId] ?? Colors.grey;

      _drawConnection(
        canvas,
        Offset(fromPos.x, fromPos.y),
        Offset(toPos.x, toPos.y),
        fromColor,
        toColor,
      );
    }
  }

  void _drawConnection(
    Canvas canvas,
    Offset start,
    Offset end,
    Color startColor,
    Color endColor,
  ) {
    // Create gradient shader
    final gradient = LinearGradient(
      colors: [
        startColor.withValues(),
        endColor.withValues(),
      ],
    ).createShader(Rect.fromPoints(start, end));

    // Main line paint
    final linePaint = Paint()
      ..shader = gradient
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Glow paint
    final glowPaint = Paint()
      ..shader = gradient
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Calculate control points for curved line
    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;
    final distance = (end - start).distance;

    // Add slight curve to the line
    final perpX = -(end.dy - start.dy) / distance;
    final perpY = (end.dx - start.dx) / distance;
    final curveAmount = math.min(distance * 0.1, 30);

    final controlPoint = Offset(
      midX + perpX * curveAmount,
      midY + perpY * curveAmount,
    );

    // Create curved path
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    // Draw glow
    canvas.drawPath(path, glowPaint);

    // Draw main line
    canvas.drawPath(path, linePaint);

    // Draw dots at connection points
    final dotPaint = Paint()..style = PaintingStyle.fill;

    dotPaint.color = startColor;
    canvas.drawCircle(start, 6, dotPaint);

    dotPaint.color = endColor;
    canvas.drawCircle(end, 6, dotPaint);

    // Draw outer rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    ringPaint.color = startColor.withValues();
    canvas.drawCircle(start, 10, ringPaint);

    ringPaint.color = endColor.withValues();
    canvas.drawCircle(end, 10, ringPaint);
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    // Optimized: Check reference equality first (fast path)
    if (oldDelegate.connections == connections && oldDelegate.positions == positions && oldDelegate.isDark == isDark) {
      return false;
    }

    // If references differ, check if content actually changed
    // For connections: compare size first, then check if any connection is different
    if (oldDelegate.connections.length != connections.length) return true;
    if (oldDelegate.positions.length != positions.length) return true;
    if (oldDelegate.isDark != isDark) return true;

    // Check if any connection was added/removed (quick check)
    final oldConnectionSet = oldDelegate.connections.map((c) => '${c.fromHabitId}_${c.toHabitId}').toSet();
    final newConnectionSet = connections.map((c) => '${c.fromHabitId}_${c.toHabitId}').toSet();
    if (oldConnectionSet != newConnectionSet) return true;

    // Check if any position changed (only check positions that are used in connections)
    for (final connection in connections) {
      final oldFromPos = oldDelegate.positions[connection.fromHabitId];
      final newFromPos = positions[connection.fromHabitId];
      if (oldFromPos?.x != newFromPos?.x || oldFromPos?.y != newFromPos?.y) return true;

      final oldToPos = oldDelegate.positions[connection.toHabitId];
      final newToPos = positions[connection.toHabitId];
      if (oldToPos?.x != newToPos?.x || oldToPos?.y != newToPos?.y) return true;
    }

    return false;
  }
}
