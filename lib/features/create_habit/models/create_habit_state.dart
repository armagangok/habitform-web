// CreateHabitStep enum and extension
import '../../../core/core.dart';
import '../../../models/habit/habit_difficulty.dart';
import '../../reminder/models/reminder/reminder_model.dart';

enum CreateHabitStep {
  habitName,
  description,
  emoji,
  color,
  reminder,
  category,
  difficulty,
}

extension CreateHabitStepExtension on CreateHabitStep {
  String get title {
    switch (this) {
      case CreateHabitStep.habitName:
        return 'Habit Name';
      case CreateHabitStep.description:
        return 'Description';
      case CreateHabitStep.emoji:
        return 'Choose Icon';
      case CreateHabitStep.color:
        return 'Choose Color';
      case CreateHabitStep.reminder:
        return 'Set Reminder';
      case CreateHabitStep.category:
        return 'Select Category';
      case CreateHabitStep.difficulty:
        return 'Choose Difficulty';
    }
  }

  String get subtitle {
    switch (this) {
      case CreateHabitStep.habitName:
        return 'What habit would you like to build?';
      case CreateHabitStep.description:
        return 'Tell us more about this habit (optional)';
      case CreateHabitStep.emoji:
        return 'Pick an icon that represents your habit';
      case CreateHabitStep.color:
        return 'Choose a color for your habit';
      case CreateHabitStep.reminder:
        return 'When would you like to be reminded?';
      case CreateHabitStep.category:
        return 'Which category does this habit belong to?';
      case CreateHabitStep.difficulty:
        return 'How difficult is this habit to build?';
    }
  }

  bool get isFirst => this == CreateHabitStep.habitName;
  bool get isLast => this == CreateHabitStep.difficulty;

  CreateHabitStep? get nextStep {
    switch (this) {
      case CreateHabitStep.habitName:
        return CreateHabitStep.description;
      case CreateHabitStep.description:
        return CreateHabitStep.emoji;
      case CreateHabitStep.emoji:
        return CreateHabitStep.color;
      case CreateHabitStep.color:
        return CreateHabitStep.reminder;
      case CreateHabitStep.reminder:
        return CreateHabitStep.category;
      case CreateHabitStep.category:
        return CreateHabitStep.difficulty;
      case CreateHabitStep.difficulty:
        return null;
    }
  }

  CreateHabitStep? get previousStep {
    switch (this) {
      case CreateHabitStep.habitName:
        return null;
      case CreateHabitStep.description:
        return CreateHabitStep.habitName;
      case CreateHabitStep.emoji:
        return CreateHabitStep.description;
      case CreateHabitStep.color:
        return CreateHabitStep.emoji;
      case CreateHabitStep.reminder:
        return CreateHabitStep.color;
      case CreateHabitStep.category:
        return CreateHabitStep.reminder;
      case CreateHabitStep.difficulty:
        return CreateHabitStep.category;
    }
  }
}

// CreateHabitState class
class CreateHabitState {
  final String? habitName;
  final String? habitDescription;
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
    this.habitName,
    this.habitDescription,
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
      habitName: title ?? habitName,
      habitDescription: description ?? habitDescription,
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
}
