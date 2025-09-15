import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/habit_icon/icon_picker_button.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../habit_category/widget/category_picker_button.dart';
import '../habit_color/color_picker_widget.dart';
import '../habit_color/provider/habit_color_provider.dart';
import '../reminder/widget/reminder_selection_widget.dart';
import 'provider/edit_habit_provider.dart';
import 'widgets/difficulty_selection_widget.dart';

class EditHabitPage extends ConsumerWidget {
  final Habit habit;

  const EditHabitPage({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editHabitNotifier = ref.watch(editHabitProvider.notifier);
    final editHabitState = ref.watch(editHabitProvider);
    final selectedDifficulty = editHabitState?.difficulty ?? editHabitNotifier.selectedDifficulty;

    return CupertinoPopupSurface(
      child: GestureDetector(
        onTap: context.hideKeyboard,
        child: CupertinoPageScaffold(
          navigationBar: SheetHeader(
            title: LocaleKeys.habit_edit_habit.tr(),
            closeButtonPosition: CloseButtonPosition.left,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                editHabitNotifier.updateHabit();
              },
              child: Text(
                LocaleKeys.common_save.tr(),
                style: context.titleMedium.copyWith(color: context.primary),
              ),
            ),
          ),
          child: ListView(
            children: [
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Icon Selection
                    CupertinoListSection.insetGrouped(
                      header: Text("Emoji"),
                      footer: Text(
                        'Choose an emoji that represents your habit',
                        style: context.bodyMedium.copyWith(
                          color: context.bodyMedium.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Center(
                                child: IconPickerButton(
                                  selectedIcon: habit.emoji,
                                  habitColor: Color(habit.colorCode),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Habit Name
                    CupertinoListSection.insetGrouped(
                      header: Text(
                        LocaleKeys.habit_habit_name.tr(),
                      ),
                      footer: Text(
                        'Give your habit a clear, memorable name',
                        style: context.bodyMedium.copyWith(
                          color: context.bodyMedium.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      children: [
                        CupertinoTextField(
                          controller: editHabitNotifier.habitNameController,
                          placeholder: LocaleKeys.habit_habit_name.tr(),
                          decoration: null,
                          style: context.bodyLarge,
                        ),
                      ],
                    ),

                    // Habit Description
                    CupertinoListSection.insetGrouped(
                      header: Text(
                        LocaleKeys.habit_habit_description.tr(),
                      ),
                      footer: Text(
                        'Add details about your habit to stay motivated',
                        style: context.bodyMedium.copyWith(
                          color: context.bodyMedium.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CupertinoTextField(
                              controller: editHabitNotifier.habitDescriptionController,
                              placeholder: LocaleKeys.habit_habit_description.tr(),
                              decoration: null,
                              maxLines: null,
                              style: context.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Difficulty Selection
                    DifficultySelectionWidget(
                      selectedDifficulty: selectedDifficulty,
                      onDifficultyChanged: (difficulty) {
                        editHabitNotifier.updateDifficulty(difficulty);
                      },
                    ),

                    // Reminder Selection
                    Consumer(
                      builder: (context, ref, child) {
                        final editHabitState = ref.watch(editHabitProvider);
                        return ReminderSelectionWidget(
                          initialReminder: editHabitState?.reminderModel,
                          header: Text(LocaleKeys.habit_reminder.tr()),
                        );
                      },
                    ),

                    // Category Selection
                    CategoryPickerButton(
                      header: Text("Category"),
                    ),

                    // Color Selection
                    ColorPickerWidget(
                      selectedColor: Color(habit.colorCode),
                      onColorSelected: (color) {
                        ref.watch(colorProvider.notifier).pickColor(color);
                      },
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
