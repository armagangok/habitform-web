import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../models/create_habit_state.dart';
import '../../provider/create_habit_provider.dart';
import 'category_step.dart';
import 'color_step.dart';
import 'description_step.dart';
import 'difficulty_step.dart';
import 'emoji_step.dart';
import 'habit_name_step.dart';
import 'reminder_step.dart';

class StepRouter extends ConsumerWidget {
  const StepRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(createHabitProvider).currentStep;

    switch (currentStep) {
      case CreateHabitStep.habitName:
        return const HabitNameStep();
      case CreateHabitStep.description:
        return const DescriptionStep();
      case CreateHabitStep.emoji:
        return const EmojiStep();
      case CreateHabitStep.color:
        return const ColorStep();
      case CreateHabitStep.reminder:
        return const ReminderStep();
      case CreateHabitStep.category:
        return const CategoryStep();
      case CreateHabitStep.difficulty:
        return const DifficultyStep();
    }
  }
}
