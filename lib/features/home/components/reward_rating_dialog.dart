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
        'How did you feel?',
        style: context.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'Rate how enjoyable this completion felt. This helps us understand your habit formation better.',
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
              _buildRatingOption(
                context,
                emoji: '😞',
                label: 'Low',
                value: 0.5,
              ),
              _buildRatingOption(
                context,
                emoji: '😐',
                label: 'Normal',
                value: 1.0,
              ),
              _buildRatingOption(
                context,
                emoji: '😊',
                label: 'High',
                value: 1.5,
              ),
              _buildRatingOption(
                context,
                emoji: '😄',
                label: 'Very High',
                value: 2.0,
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
            'Continue',
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
    required String label,
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
              style: const TextStyle(fontSize: 28),
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
