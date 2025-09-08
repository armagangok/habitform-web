import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/habit/habit_difficulty.dart';
import '../provider/create_habit_provider.dart';

class DifficultyPickerWidget extends ConsumerWidget {
  const DifficultyPickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficulty = ref.watch(createHabitProvider).value?.difficulty ?? HabitDifficulty.moderate;

    return CupertinoListSection.insetGrouped(
      header: Text('Habit Difficulty'),
      children: [
        // Difficulty selection buttons
        Column(
          children: HabitDifficulty.values.map((diff) {
            final isSelected = difficulty == diff;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  ref.read(createHabitProvider.notifier).updateDifficulty(diff);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(diff.colorValue).withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Color(diff.colorValue) : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Difficulty indicator
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(diff.colorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Difficulty name and description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diff.displayName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Color(diff.colorValue) : null,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              diff.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Estimated days
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(diff.colorValue).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${diff.estimatedFormationDays}d',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Color(diff.colorValue),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Info card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: context.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: context.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Choose how challenging this habit feels. We use this to estimate formation time and personalize insights.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.primary,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
