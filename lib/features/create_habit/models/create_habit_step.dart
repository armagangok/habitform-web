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
