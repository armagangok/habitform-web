import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../models/create_habit_step.dart';
import '../../provider/create_habit_provider.dart';
import '../../widget/difficulty_picker_widget.dart';
import 'base_step_widget.dart';

class DifficultyStep extends ConsumerWidget {
  const DifficultyStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();

    return BaseStepWidget(
      step: CreateHabitStep.difficulty,
      canProceed: canProceed,
      onNext: () {
        ref.watch(createHabitProvider.notifier).nextStep();
      },
      onPrevious: () {
        ref.watch(createHabitProvider.notifier).previousStep();
      },
      child: Column(
        children: [
          // Step title and description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How difficult is this habit to build?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the difficulty level that best describes this habit.',
                  style: context.bodySmall.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),

          // Difficulty picker
          DifficultyPickerWidget(),
        ],
      ),
    );
  }
}
