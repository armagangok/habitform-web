import 'dart:math' as math;

import 'package:flutter/material.dart';

import '/models/habit/habit_summary.dart';
import 'habit_canvas_model.dart';

/// Painter for drawing connection lines with directional arrows between habits.
///
/// Arrow direction:
/// 1. Time-based (priority): toward the habit with the later effective time
///    (completionTime preferred, reminderTime as fallback).
/// 2. Selection-based (fallback): stored from → to tap order.
///
/// Animation: a staggered scale “wave” along the curve. When today’s sequence is
/// fulfilled (both habits met target, first completed before second per
/// [CompletionEntry.updatedAt]), arrows on that link stay static.
class ConnectionPainter extends CustomPainter {
  final Set<HabitConnection> connections;
  final Map<String, HabitPosition> positions;
  final List<dynamic> habits;
  final bool isDark;
  final Animation<double> arrowAnimation;

  ConnectionPainter({
    required this.connections,
    required this.positions,
    required this.habits,
    required this.isDark,
    required this.arrowAnimation,
  }) : super(repaint: arrowAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    if (connections.isEmpty || positions.isEmpty) return;

    final habitColors = <String, Color>{};
    final habitTimes = <String, DateTime>{};
    final habitById = <String, dynamic>{};

    for (final habit in habits) {
      final id = habit.id as String;
      habitById[id] = habit;
      habitColors[id] = Color(habit.colorCode as int);

      final DateTime? effectiveTime = _resolveEffectiveTime(habit);
      if (effectiveTime != null) {
        habitTimes[id] = effectiveTime;
      }
    }

    for (final connection in connections) {
      final fromPos = positions[connection.fromHabitId];
      final toPos = positions[connection.toHabitId];
      if (fromPos == null || toPos == null) continue;

      final resolved = _resolveDirection(connection, habitTimes);

      final startColor = habitColors[resolved.fromId] ?? Colors.grey;
      final endColor = habitColors[resolved.toId] ?? Colors.grey;

      _drawConnection(
        canvas,
        Offset(positions[resolved.fromId]!.x, positions[resolved.fromId]!.y),
        Offset(positions[resolved.toId]!.x, positions[resolved.toId]!.y),
        startColor,
        endColor,
      );
    }
  }



  /// Extracts the effective time-of-day for direction comparison.
  DateTime? _resolveEffectiveTime(dynamic habit) {
    final DateTime? completionTime = habit.completionTime as DateTime?;
    if (completionTime != null) return completionTime;

    if (habit is HabitSummary) {
      return habit.reminderTime;
    }

    try {
      final reminderModel = habit.reminderModel;
      if (reminderModel != null) {
        return reminderModel.reminderTime as DateTime?;
      }
    } catch (_) {}
    return null;
  }

  _DirectedPair _resolveDirection(
    HabitConnection connection,
    Map<String, DateTime> habitTimes,
  ) {
    final timeA = habitTimes[connection.fromHabitId];
    final timeB = habitTimes[connection.toHabitId];

    if (timeA != null && timeB != null) {
      final minutesA = timeA.hour * 60 + timeA.minute;
      final minutesB = timeB.hour * 60 + timeB.minute;

      if (minutesA <= minutesB) {
        return _DirectedPair(connection.fromHabitId, connection.toHabitId);
      }
      return _DirectedPair(connection.toHabitId, connection.fromHabitId);
    }

    return _DirectedPair(connection.fromHabitId, connection.toHabitId);
  }

  void _drawConnection(
    Canvas canvas,
    Offset start,
    Offset end,
    Color startColor,
    Color endColor,
  ) {
    final gradient = LinearGradient(
      colors: [startColor.withValues(), endColor.withValues()],
    ).createShader(Rect.fromPoints(start, end));

    final linePaint = Paint()
      ..shader = gradient
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..shader = gradient
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;
    final distance = (end - start).distance;

    final perpX = -(end.dy - start.dy) / distance;
    final perpY = (end.dx - start.dx) / distance;
    final curveAmount = math.min(distance * 0.1, 30);

    final controlPoint = Offset(
      midX + perpX * curveAmount,
      midY + perpY * curveAmount,
    );

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    _drawDirectionalArrows(
      canvas,
      start,
      controlPoint,
      end,
      startColor,
      endColor,
    );

    final dotPaint = Paint()..style = PaintingStyle.fill;
    dotPaint.color = startColor;
    canvas.drawCircle(start, 6, dotPaint);
    dotPaint.color = endColor;
    canvas.drawCircle(end, 6, dotPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    ringPaint.color = startColor.withValues();
    canvas.drawCircle(start, 10, ringPaint);
    ringPaint.color = endColor.withValues();
    canvas.drawCircle(end, 10, ringPaint);
  }

  /// Staggered scale wave along the curve.
  void _drawDirectionalArrows(
    Canvas canvas,
    Offset p0,
    Offset p1,
    Offset p2,
    Color startColor,
    Color endColor,
  ) {
    const arrowTs = [0.35, 0.5, 0.65];
    const baseChevronSize = 7.5;
    const chevronAngle = 0.5;
    const phaseStep = 0.12;

    final anim = arrowAnimation.value;

    for (var i = 0; i < arrowTs.length; i++) {
      final t = arrowTs[i];
      final point = _quadraticBezierPoint(p0, p1, p2, t);
      final tangent = _quadraticBezierTangent(p0, p1, p2, t);
      final angle = math.atan2(tangent.dy, tangent.dx);

      final phase = 2 * math.pi * (anim + i * phaseStep);
      final scale = 0.88 + 0.24 * (0.5 + 0.5 * math.sin(phase));
      final opacity = 0.82 + 0.18 * (0.5 + 0.5 * math.sin(phase + math.pi * 0.25));

      final chevronSize = baseChevronSize * scale;
      final color = Color.lerp(startColor, endColor, t)!.withValues(alpha: opacity);

      final arrowPaint = Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final tip = point;
      final leftTail = Offset(
        tip.dx - chevronSize * math.cos(angle - chevronAngle),
        tip.dy - chevronSize * math.sin(angle - chevronAngle),
      );
      final rightTail = Offset(
        tip.dx - chevronSize * math.cos(angle + chevronAngle),
        tip.dy - chevronSize * math.sin(angle + chevronAngle),
      );

      canvas.drawLine(leftTail, tip, arrowPaint);
      canvas.drawLine(rightTail, tip, arrowPaint);
    }
  }

  Offset _quadraticBezierPoint(Offset p0, Offset p1, Offset p2, double t) {
    final mt = 1.0 - t;
    return Offset(
      mt * mt * p0.dx + 2 * mt * t * p1.dx + t * t * p2.dx,
      mt * mt * p0.dy + 2 * mt * t * p1.dy + t * t * p2.dy,
    );
  }

  Offset _quadraticBezierTangent(Offset p0, Offset p1, Offset p2, double t) {
    final mt = 1.0 - t;
    return Offset(
      2 * mt * (p1.dx - p0.dx) + 2 * t * (p2.dx - p1.dx),
      2 * mt * (p1.dy - p0.dy) + 2 * t * (p2.dy - p1.dy),
    );
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    if (oldDelegate.isDark != isDark) return true;
    if (oldDelegate.connections.length != connections.length) return true;
    if (oldDelegate.positions.length != positions.length) return true;

    final oldConnectionSet = oldDelegate.connections.map((c) => '${c.fromHabitId}_${c.toHabitId}').toSet();
    final newConnectionSet = connections.map((c) => '${c.fromHabitId}_${c.toHabitId}').toSet();
    if (oldConnectionSet != newConnectionSet) return true;

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

class _DirectedPair {
  final String fromId;
  final String toId;
  const _DirectedPair(this.fromId, this.toId);
}
