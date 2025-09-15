import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../reminder/widget/reminder_selection_widget.dart';
import '../../models/create_habit_state.dart';
import '../../provider/create_habit_provider.dart';
import 'base_step_widget.dart';

class ReminderStep extends ConsumerStatefulWidget {
  const ReminderStep({super.key});

  @override
  ConsumerState<ReminderStep> createState() => _ReminderStepState();
}

class _ReminderStepState extends ConsumerState<ReminderStep> {
  @override
  Widget build(BuildContext context) {
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();

    return BaseStepWidget(
      step: CreateHabitStep.reminder,
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
                  LocaleKeys.create_habit_reminder_title.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.create_habit_reminder_description.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ],
            ),
          ),

          // Reminder selection widget
          Consumer(
            builder: (context, ref, child) {
              final createHabitState = ref.watch(createHabitProvider);
              return ReminderSelectionWidget(
                initialReminder: createHabitState.reminder,
                onReminderChanged: (reminder) {
                  ref.read(createHabitProvider.notifier).updateReminder(reminder);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
