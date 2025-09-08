import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../reminder/widget/reminder_selection_widget.dart';
import '../../models/create_habit_step.dart';
import '../../provider/create_habit_provider.dart';
import 'base_step_widget.dart';

class ReminderStep extends ConsumerWidget {
  const ReminderStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();

    return BaseStepWidget(
      step: CreateHabitStep.reminder,
      canProceed: canProceed,
      onNext: () {
        ref.read(createHabitProvider.notifier).nextStep();
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
                  'Reminder for your habit',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reminders are optional but highly recommended. They help you stay consistent by notifying you when it\'s time to complete your habit.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ],
            ),
          ),

          // Reminder selection widget
          ReminderSelectionWidget(),
        ],
      ),
    );
  }
}
