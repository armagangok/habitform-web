import 'package:flutter/material.dart';

import '/models/habit/habit_model.dart';
import 'circular_habit_item.dart';

/// Preview version of CircularHabitWidget for onboarding and habit creation
/// This widget doesn't require provider and is non-interactive
class CircularHabitPreviewWidget extends StatelessWidget {
  final Habit habit;
  final bool showName;

  const CircularHabitPreviewWidget({
    super.key,
    required this.habit,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use CircularHabitWidget with useProvider=false to avoid provider dependency
    return CircularHabitWidget(
      habit: habit,
      showName: showName,
      isSelected: false,
      isDragging: false,
      isConnecting: false,
      useProvider: false, // Don't use provider for preview
    );
  }
}
