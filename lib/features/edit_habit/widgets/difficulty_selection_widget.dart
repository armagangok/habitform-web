import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_difficulty.dart';

class DifficultySelectionWidget extends ConsumerWidget {
  final HabitDifficulty selectedDifficulty;
  final Function(HabitDifficulty) onDifficultyChanged;

  const DifficultySelectionWidget({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoListSection.insetGrouped(
      header: Text(LocaleKeys.edit_habit_difficulty.tr()),
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          title: Text(
            selectedDifficulty.displayName,
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            selectedDifficulty.description,
            style: context.bodyMedium.copyWith(
              color: context.bodyMedium.color?.withValues(alpha: 0.7),
            ),
            maxLines: 4,
          ),
          additionalInfo: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Color(selectedDifficulty.colorValue),
              shape: BoxShape.circle,
            ),
          ),
          trailing: const CupertinoListTileChevron(),
          onTap: () => _showDifficultyPicker(context),
        ),
      ],
    );
  }

  void _showDifficultyPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          LocaleKeys.edit_habit_select_difficulty.tr(),
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        message: Text(
          LocaleKeys.edit_habit_difficulty_description.tr(),
          style: context.bodyMedium.copyWith(
            color: context.bodyMedium.color?.withValues(alpha: 0.7),
          ),
        ),
        actions: HabitDifficulty.values.map((difficulty) {
          final isSelected = difficulty == selectedDifficulty;
          return CupertinoActionSheetAction(
            onPressed: () {
              onDifficultyChanged(difficulty);
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        difficulty.displayName,
                        style: context.bodyLarge.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? context.primary : null,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        difficulty.description,
                        style: context.bodySmall.copyWith(
                          color: context.bodySmall.color?.withValues(alpha: 0.7),
                        ),
                        maxLines: 99,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(difficulty.colorValue),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isSelected)
                      Icon(
                        CupertinoIcons.checkmark,
                        color: context.primary,
                        size: 16,
                      ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            LocaleKeys.common_cancel.tr(),
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
