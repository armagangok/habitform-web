import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../models/habit/habit_model.dart';
import '../../../habit_color/color_picker_widget.dart';
import '../../../habit_color/provider/habit_color_provider.dart';
import '../../../home/views/widgets/habit_widget.dart';
import '../../models/create_habit_state.dart';
import '../../provider/create_habit_provider.dart';
import 'base_step_widget.dart';

class ColorStep extends ConsumerStatefulWidget {
  const ColorStep({super.key});

  @override
  ConsumerState<ColorStep> createState() => _ColorStepState();
}

class _ColorStepState extends ConsumerState<ColorStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeColor();
    });
  }

  void _initializeColor() {
    // Initialize color from create habit state if available
    final createHabitState = ref.watch(createHabitProvider);
    final existingColor = createHabitState.colorCode;

    if (existingColor != null) {
      ref.read(colorProvider.notifier).pickColor(Color(existingColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createHabitProvider);
    final selectedIcon = state.emoji;
    final selectedColor = state.colorCode;

    // Get habit name from controller
    final habitName = state.habitNameController.text;
    final habitDescription = state.habitDescriptionController.text;
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();

    // Watch color provider to prevent auto-disposal
    ref.watch(colorProvider);

    return BaseStepWidget(
      step: CreateHabitStep.color,
      canProceed: canProceed,
      onNext: () {
        _saveColorState();
        ref.watch(createHabitProvider.notifier).nextStep();
      },
      onPrevious: () {
        _saveColorState();
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
                  'Choose a color for your habit',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          // Enhanced Preview Section - Compact Hero Design
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Your habit will look like this',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.titleLarge.color,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: AbsorbPointer(
                    child: HabitWidget(
                      habit: Habit(
                        id: '1',
                        habitName: habitName.isEmpty ? 'Your Habit' : habitName,
                        habitDescription: habitDescription.isEmpty ? '' : habitDescription,
                        emoji: selectedIcon ?? '',
                        colorCode: selectedColor ?? context.primaryContrastingColor.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Color picker
          ColorPickerWidget(
            selectedColor: selectedColor != null ? Color(selectedColor) : null,
            onColorSelected: (color) {
              ref.watch(createHabitProvider.notifier).updateColorCode(color.value);
            },
          ),
        ],
      ),
    );
  }

  void _saveColorState() {
    // Save color state to create habit provider
    final selectedColor = ref.read(colorProvider);

    if (selectedColor != null) {
      ref.watch(createHabitProvider.notifier).updateColorCode(selectedColor.value);
    }
  }
}
