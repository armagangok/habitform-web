import 'package:flutter/material.dart';

import '../../../models/habit/habit_difficulty.dart';
import '../../reminder/models/reminder/reminder_model.dart';
import '../models/create_habit_step.dart';

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
  final CreateHabitStep currentStep;
  final HabitDifficulty difficulty;

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
    this.currentStep = CreateHabitStep.habitName,
    this.difficulty = HabitDifficulty.moderate,
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
    CreateHabitStep? currentStep,
    HabitDifficulty? difficulty,
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
      currentStep: currentStep ?? this.currentStep,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  void dispose() {
    habitNameController.dispose();
    habitDescriptionController.dispose();
  }
}
