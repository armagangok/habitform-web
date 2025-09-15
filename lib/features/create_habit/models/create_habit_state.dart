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
        return LocaleKeys.create_habit_step_titles_habit_name.tr();
      case CreateHabitStep.description:
        return LocaleKeys.create_habit_step_titles_description.tr();
      case CreateHabitStep.emoji:
        return LocaleKeys.create_habit_step_titles_emoji.tr();
      case CreateHabitStep.color:
        return LocaleKeys.create_habit_step_titles_color.tr();
      case CreateHabitStep.reminder:
        return LocaleKeys.create_habit_step_titles_reminder.tr();
      case CreateHabitStep.category:
        return LocaleKeys.create_habit_step_titles_category.tr();
      case CreateHabitStep.difficulty:
        return LocaleKeys.create_habit_step_titles_difficulty.tr();
    }
  }

  String get subtitle {
    switch (this) {
      case CreateHabitStep.habitName:
        return LocaleKeys.create_habit_step_subtitles_habit_name.tr();
      case CreateHabitStep.description:
        return LocaleKeys.create_habit_step_subtitles_description.tr();
      case CreateHabitStep.emoji:
        return LocaleKeys.create_habit_step_subtitles_emoji.tr();
      case CreateHabitStep.color:
        return LocaleKeys.create_habit_step_subtitles_color.tr();
      case CreateHabitStep.reminder:
        return LocaleKeys.create_habit_step_subtitles_reminder.tr();
      case CreateHabitStep.category:
        return LocaleKeys.create_habit_step_subtitles_category.tr();
      case CreateHabitStep.difficulty:
        return LocaleKeys.create_habit_step_subtitles_difficulty.tr();
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
