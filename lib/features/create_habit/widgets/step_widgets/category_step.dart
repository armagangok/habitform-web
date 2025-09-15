import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../habit_category/provider/habit_category_button_provider.dart';
import '../../../habit_category/widget/category_picker_button.dart';
import '../../models/create_habit_state.dart';
import '../../provider/create_habit_provider.dart';
import 'base_step_widget.dart';

class CategoryStep extends ConsumerStatefulWidget {
  const CategoryStep({super.key});

  @override
  ConsumerState<CategoryStep> createState() => _CategoryStepState();
}

class _CategoryStepState extends ConsumerState<CategoryStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCategories();
    });
  }

  void _initializeCategories() {
    // Initialize categories from create habit state if available
    final createHabitState = ref.watch(createHabitProvider);
    final existingCategories = createHabitState.categoryIds;

    if (existingCategories.isNotEmpty) {
      ref.read(categoryButtonProvider.notifier).setSelectedCategories(existingCategories);
    } else {
      // Initialize with empty list if none exists
      ref.read(categoryButtonProvider.notifier).setSelectedCategories([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();
    // Watch category provider to prevent auto-disposal
    ref.watch(categoryButtonProvider);

    return BaseStepWidget(
      step: CreateHabitStep.category,
      canProceed: canProceed,
      onNext: () {
        _saveCategoryState();
        ref.watch(createHabitProvider.notifier).nextStep();
      },
      onPrevious: () {
        _saveCategoryState();
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
                  LocaleKeys.create_habit_category_title.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  LocaleKeys.create_habit_category_description.tr(),
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

  void _saveCategoryState() {
    // Save category state to create habit provider
    final selectedCategories = ref.read(categoryButtonProvider);

    // Always save the category state, even if it's null/empty
    ref.watch(createHabitProvider.notifier).updateCategories(selectedCategories ?? []);
  }
}
