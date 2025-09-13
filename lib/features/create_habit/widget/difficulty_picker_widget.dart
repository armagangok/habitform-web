import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/habit/habit_difficulty.dart';
import '../provider/create_habit_provider.dart';

class DifficultyPickerWidget extends ConsumerWidget {
  const DifficultyPickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficulty = ref.watch(createHabitProvider).difficulty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Info card
          _buildInfoCard(context),
          const SizedBox(height: 24),
          // Difficulty selection cards
          ...HabitDifficulty.values.map((diff) {
            final isSelected = difficulty == diff;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildDifficultyCard(context, diff, isSelected, () {
                ref.watch(createHabitProvider.notifier).updateDifficulty(diff);
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context,
    HabitDifficulty diff,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final color = Color(diff.colorValue);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      color: color.withValues(alpha: 0.001),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color.withValues(alpha: 0.3) : context.primaryContrastingColor.withValues(alpha: 0.1),
                width: isSelected ? 1 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Difficulty indicator with better design
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Difficulty content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        diff.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? color : null,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Estimated days with better design
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${diff.estimatedFormationDays}d',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            diff.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                  height: 1.4,
                ),
            maxLines: 12,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return CupertinoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.info_circle_fill,
              size: 20,
              color: context.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Choose how challenging this habit feels. We use this to estimate formation time and personalize insights.',
              style: context.bodySmall.copyWith(
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
