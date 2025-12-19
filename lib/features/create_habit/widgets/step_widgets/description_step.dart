import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../models/create_habit_state.dart';
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
                  LocaleKeys.create_habit_description_title.tr(),
                  style: context.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.create_habit_description_description.tr(),
                  style: context.bodySmall.copyWith(
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
                  controller: state.habitDescriptionController,
                  placeholder: LocaleKeys.habit_habit_description.tr(),
                  decoration: null,
                  maxLines: 4,
                  minLines: 3,
                  style: context.bodyMedium,
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
