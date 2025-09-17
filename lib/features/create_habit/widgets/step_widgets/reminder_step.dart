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
                  style: context.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.create_habit_reminder_description.tr(),
                  style: context.bodyLarge.copyWith(
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

          const SizedBox(height: 16),

          // Daily target selector
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(createHabitProvider);
              return CupertinoListSection.insetGrouped(
                header: const Text("Daily target per day"),
                footer: Text(
                  "How many times do you want to complete this habit each day?",
                  style: context.bodyMedium.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text("Completions/day", style: context.titleMedium),
                      ),
                      Row(
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.all(8),
                            onPressed: () => ref.read(createHabitProvider.notifier).updateDailyTarget(state.dailyTarget - 1),
                            child: const Icon(CupertinoIcons.minus_circle),
                          ),
                          Text(state.dailyTarget.toString(), style: context.titleMedium),
                          CupertinoButton(
                            padding: const EdgeInsets.all(8),
                            onPressed: () => ref.read(createHabitProvider.notifier).updateDailyTarget(state.dailyTarget + 1),
                            child: const Icon(CupertinoIcons.plus_circle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
