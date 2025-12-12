import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/models/habit/habit_model.dart';
import 'habit_canvas_model.dart';

/// Painter for drawing connection lines between habits
class ConnectionPainter extends CustomPainter {
  final Set<HabitConnection> connections;
  final Map<String, HabitPosition> positions;
  final List<Habit> habits;
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
      habitColors[habit.id] = Color(habit.colorCode);
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
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Glow paint
    final glowPaint = Paint()
      ..shader = gradient
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

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
    return oldDelegate.connections != connections || oldDelegate.positions != positions || oldDelegate.isDark != isDark;
  }
}
