import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../habit_emoji/emoji_picker_button.dart';
import '../../models/create_habit_state.dart';
import '../../provider/create_habit_provider.dart';
import 'base_step_widget.dart';

class EmojiStep extends ConsumerWidget {
  const EmojiStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createHabitProvider);
    final selectedEmoji = state.emoji;
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();

    return BaseStepWidget(
      step: CreateHabitStep.emoji,
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
                  'Pick an emoji for your habit',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose an icon that represents your habit. This will help you quickly identify it in your habit list.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Emoji picker button
          EmojiPickerButton(
            selectedIcon: selectedEmoji,
            onEmojiSelected: (icon) {
              ref.watch(createHabitProvider.notifier).updateEmoji(icon);
            },
          ),
        ],
      ),
    );
  }
}
