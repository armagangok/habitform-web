import 'package:flutter/material.dart';

import '../../reminder/models/reminder/reminder_model.dart';

class CreateHabitState {
  final String? title;
  final String? description;
  final String? emoji;
  final int? colorCode;
  final ReminderModel? reminder;
  final String? error;
  final TextEditingController habitNameController;
  final TextEditingController habitDescriptionController;
  final List<String> categoryIds;

  CreateHabitState({
    this.title,
    this.description,
    this.emoji,
    this.colorCode,
    this.reminder,
    this.error,
    TextEditingController? habitNameController,
    TextEditingController? habitDescriptionController,
    this.categoryIds = const [],
  })  : habitNameController = habitNameController ?? TextEditingController(),
        habitDescriptionController = habitDescriptionController ?? TextEditingController();

  CreateHabitState copyWith({
    String? title,
    String? description,
    String? emoji,
    int? colorCode,
    ReminderModel? reminder,
    String? error,
    TextEditingController? habitNameController,
    TextEditingController? habitDescriptionController,
    List<String>? categoryIds,
  }) {
    return CreateHabitState(
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      colorCode: colorCode ?? this.colorCode,
      reminder: reminder ?? this.reminder,
      error: error,
      habitNameController: habitNameController ?? this.habitNameController,
      habitDescriptionController: habitDescriptionController ?? this.habitDescriptionController,
      categoryIds: categoryIds ?? this.categoryIds,
    );
  }

  void dispose() {
    habitNameController.dispose();
    habitDescriptionController.dispose();
  }
}
