import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../models/habit/habit_difficulty.dart';
import '../../models/create_habit_step.dart';
import '../../provider/create_habit_provider.dart';
import '../../widget/difficulty_picker_widget.dart';
import 'base_step_widget.dart';

class DifficultyStep extends ConsumerWidget {
  const DifficultyStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createHabitProvider);
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();

    return BaseStepWidget(
      step: CreateHabitStep.difficulty,
      canProceed: canProceed,
      onNext: () {
        // This is the last step, so create the habit
        ref.read(createHabitProvider.notifier).createHabit(context);
      },
      onPrevious: () {
        ref.read(createHabitProvider.notifier).previousStep();
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
                  'Choose the difficulty level that best describes this habit. This helps us provide better formation estimates and support.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ],
            ),
          ),

          // Difficulty picker
          DifficultyPickerWidget(),

          const SizedBox(height: 16),

          // Formation time info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 20,
                        color: context.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estimated Formation Time',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on scientific research, habits typically take ${state.value?.difficulty.estimatedFormationDays ?? 45} days to form. This helps us provide you with more accurate progress tracking and motivation.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
