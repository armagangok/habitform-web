import 'package:flutter/material.dart';

import '/models/completion_entry/completion_entry.dart';
import '/models/habit/habit_model.dart';
import 'circular_habit_item.dart';

/// Preview version of CircularHabitWidget for onboarding and habit creation
/// This widget doesn't require provider but can be interactive for demo purposes
class CircularHabitPreviewWidget extends StatefulWidget {
  final Habit habit;
  final bool showName;
  final bool isCompleted;
  final VoidCallback? onTap;
  final bool showCompleteButton; // Show complete button even in preview mode
  final bool enableCompleteButton; // Enable/disable complete button interaction

  const CircularHabitPreviewWidget({
    super.key,
    required this.habit,
    this.showName = true,
    this.isCompleted = false,
    this.onTap,
    this.showCompleteButton = false,
    this.enableCompleteButton = true,
  });

  @override
  State<CircularHabitPreviewWidget> createState() => _CircularHabitPreviewWidgetState();
}

class _CircularHabitPreviewWidgetState extends State<CircularHabitPreviewWidget> {
  late Habit _currentHabit;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _currentHabit = widget.habit;
    _isCompleted = widget.isCompleted;
    _updateHabitCompletion();
  }

  @override
  void didUpdateWidget(CircularHabitPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCompleted != widget.isCompleted || oldWidget.habit != widget.habit) {
      _isCompleted = widget.isCompleted;
      _updateHabitCompletion();
    }
  }

  void _updateHabitCompletion() {
    final today = DateTime.now();
    final todayKey = today.toIso8601String();
    final updatedCompletions = Map<String, CompletionEntry>.from(_currentHabit.completions);

    if (_isCompleted) {
      // Add today's completion
      updatedCompletions[todayKey] = CompletionEntry(
        id: todayKey,
        date: today,
        count: widget.habit.dailyTarget <= 0 ? 1 : widget.habit.dailyTarget,
        isCompleted: true,
      );
    } else {
      // Remove today's completion
      updatedCompletions.remove(todayKey);
    }

    _currentHabit = _currentHabit.copyWith(completions: updatedCompletions);
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Default behavior: toggle completion
      setState(() {
        _isCompleted = !_isCompleted;
        _updateHabitCompletion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use CircularHabitWidget with useProvider=false to avoid provider dependency
    // Scale up for better visibility in preview (onboarding, etc.)
    final double scale = 1.95; // 30% larger for preview
    return GestureDetector(
      onTap: widget.onTap ?? _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Transform.scale(
        scale: scale,
      child: CircularHabitWidget(
        habit: _currentHabit,
        showName: widget.showName,
        isSelected: false,
        isDragging: false,
        isConnecting: false,
        useProvider: false, // Don't use provider for preview
        showCompleteButton: widget.showCompleteButton,
        enableCompleteButton: widget.enableCompleteButton,
      ),
      ),
    );
  }
}
