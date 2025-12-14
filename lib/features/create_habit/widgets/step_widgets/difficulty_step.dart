import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../models/create_habit_state.dart';
import '../../provider/create_habit_provider.dart';
import '../difficulty_picker_widget.dart';
import 'base_step_widget.dart';

class DifficultyStep extends ConsumerWidget {
  const DifficultyStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canProceed = ref.watch(createHabitProvider.notifier).isCurrentStepValid();

    return BaseStepWidget(
      step: CreateHabitStep.difficulty,
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
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.create_habit_difficulty_title.tr(),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    LocaleKeys.create_habit_difficulty_question.tr(),
                    style: context.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Difficulty picker
          DifficultyPickerWidget(),

          const SizedBox(height: 32),

          // Reward factor section
          _buildRewardFactorSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildRewardFactorSection(BuildContext context, WidgetRef ref) {
    final rewardFactor = ref.watch(createHabitProvider).rewardFactor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'How enjoyable is this habit?',
            style: context.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'More enjoyable habits form faster. How do you feel when you complete this habit?',
            style: context.bodySmall.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 16),

          // Reward factor options
          Row(
            children: [
              Expanded(
                child: _buildRewardOption(
                  context,
                  ref,
                  emoji: '😞',
                  label: 'Low',
                  value: 0.5,
                  isSelected: rewardFactor == 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRewardOption(
                  context,
                  ref,
                  emoji: '😐',
                  label: 'Normal',
                  value: 1.0,
                  isSelected: rewardFactor == 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRewardOption(
                  context,
                  ref,
                  emoji: '😊',
                  label: 'High',
                  value: 1.5,
                  isSelected: rewardFactor == 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRewardOption(
                  context,
                  ref,
                  emoji: '😄',
                  label: 'Very High',
                  value: 2.0,
                  isSelected: rewardFactor == 2.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardOption(
    BuildContext context,
    WidgetRef ref, {
    required String emoji,
    required String label,
    required double value,
    required bool isSelected,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        ref.read(createHabitProvider.notifier).updateRewardFactor(value);
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primary : context.primaryContrastingColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? context.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.labelSmall.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? context.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
