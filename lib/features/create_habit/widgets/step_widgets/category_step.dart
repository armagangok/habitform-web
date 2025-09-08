import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../habit_category/widget/category_picker_button.dart';
import '../../models/create_habit_step.dart';
import '../../provider/create_habit_provider.dart';
import 'base_step_widget.dart';

class CategoryStep extends ConsumerWidget {
  const CategoryStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();

    return BaseStepWidget(
      step: CreateHabitStep.category,
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
                  'Select categories for your habit',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Categories help you organize your habits and track progress in specific areas of your life. You can select multiple categories.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ],
            ),
          ),

          // Category picker
          CategoryPickerButton(),
        ],
      ),
    );
  }
}
