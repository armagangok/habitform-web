import 'package:flutter/services.dart';

import '../../../core/core.dart';
import '../../../models/habit/habit_model.dart';

/// Dialog to collect reward rating (α) after completing a habit
/// User must select how they felt after completing the habit
/// Returns the selected rating when dialog is closed
class RewardRatingDialog extends StatefulWidget {
  final Habit habit;

  const RewardRatingDialog({
    super.key,
    required this.habit,
  });

  @override
  State<RewardRatingDialog> createState() => _RewardRatingDialogState();
}

class _RewardRatingDialogState extends State<RewardRatingDialog> {
  double? _selectedRating;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        'onboarding.reward_rating.title'.tr(),
        style: context.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'onboarding.reward_rating.description'.tr(),
            style: context.bodyMedium.copyWith(
              color: context.bodyMedium.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Reward rating options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildRatingOption(
                  context,
                  emoji: '😞',
                  value: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingOption(
                  context,
                  emoji: '😐',
                  value: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingOption(
                  context,
                  emoji: '😊',
                  value: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingOption(
                  context,
                  emoji: '🤩',
                  value: 2.0,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: _selectedRating != null
              ? () {
                  HapticFeedback.mediumImpact();
                  // Pop dialog and return the selected rating
                  Navigator.of(context).pop(_selectedRating);
                }
              : null,
          child: Text(
            'onboarding.reward_rating.continue'.tr(),
            style: TextStyle(
              color: _selectedRating != null ? context.primary : CupertinoColors.placeholderText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingOption(
    BuildContext context, {
    required String emoji,
    required double value,
  }) {
    final isSelected = _selectedRating == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedRating = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primary : context.primaryContrastingColor.withValues(alpha: 0.2),
            width: 2,
          ),
          color: isSelected ? context.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}
