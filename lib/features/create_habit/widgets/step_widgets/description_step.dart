import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../models/create_habit_step.dart';
import '../../provider/create_habit_provider.dart';
import 'base_step_widget.dart';

class DescriptionStep extends ConsumerWidget {
  const DescriptionStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createHabitProvider);
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();

    return BaseStepWidget(
      step: CreateHabitStep.description,
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
                  'Tell us more about this habit',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This step is optional. You can add more details about your habit, why it\'s important to you, or any specific goals you have.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ],
            ),
          ),

          // Input section
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: CupertinoTextField(
                  controller: state.value?.habitDescriptionController ?? TextEditingController(),
                  placeholder: LocaleKeys.habit_habit_description.tr(),
                  decoration: null,
                  maxLines: 4,
                  minLines: 3,
                  style: Theme.of(context).textTheme.bodyMedium,
                  autofocus: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
