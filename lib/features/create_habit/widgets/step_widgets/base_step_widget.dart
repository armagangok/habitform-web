import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../models/create_habit_step.dart';

class BaseStepWidget extends ConsumerWidget {
  final CreateHabitStep step;
  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final bool canProceed;

  const BaseStepWidget({
    super.key,
    required this.step,
    required this.child,
    this.onNext,
    this.onPrevious,
    this.canProceed = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Step progress indicator
        _buildProgressIndicator(context),

        // Step content - scrollable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: child,
          ),
        ),

        // Navigation buttons
        _buildNavigationButtons(context),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final totalSteps = CreateHabitStep.values.length;
    final currentStepIndex = CreateHabitStep.values.indexOf(step);
    final progress = (currentStepIndex + 1) / totalSteps;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${currentStepIndex + 1} of $totalSteps',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(),
        child: Row(
          children: [
            // Previous button
            if (!step.isFirst)
              Expanded(
                child: CupertinoButton.tinted(
                  onPressed: onPrevious,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: Theme.of(context).hintColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (!step.isFirst) const SizedBox(width: 12),

            // Next/Save button
            Expanded(
              flex: step.isFirst ? 1 : 1,
              child: CupertinoButton.filled(
                onPressed: canProceed ? onNext : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      step.isLast ? 'Create Habit' : 'Next',
                      style: TextStyle(
                        color: canProceed ? Colors.white : Theme.of(context).hintColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!step.isLast) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: canProceed ? Colors.white : Theme.of(context).hintColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
