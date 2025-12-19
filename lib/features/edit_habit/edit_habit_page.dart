import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitform/features/habit_emoji/emoji_picker_button.dart';

import '/core/core.dart';
import '/models/models.dart';
import '../create_habit/widgets/step_widgets/completion_time_widget.dart';
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

    final selectedEmoji = ref.watch(editHabitProvider)?.emoji;

    // Initialize edit state and related providers once with the passed habit
    if (editHabitState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        editHabitNotifier.initHabit(habit);
      });
    }

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
                      header: Text(LocaleKeys.edit_habit_emoji.tr()),
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Center(
                                child: EmojiPickerButton(
                                  selectedIcon: selectedEmoji,
                                  onEmojiSelected: (emoji) {
                                    editHabitNotifier.updateEmoji(emoji);
                                  },
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
                        LocaleKeys.edit_habit_habit_name_description.tr(),
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
                        LocaleKeys.edit_habit_habit_description_description.tr(),
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

                    ColorPickerWidget(
                      selectedColor: Color(habit.colorCode),
                      onColorSelected: (color) {
                        ref.watch(colorProvider.notifier).pickColor(color);
                      },
                    ),

                    // Difficulty Selection
                    DifficultySelectionWidget(
                      selectedDifficulty: selectedDifficulty,
                      onDifficultyChanged: (difficulty) {
                        editHabitNotifier.updateDifficulty(difficulty);
                      },
                    ),

                    // Daily target selector (edit)
                    Consumer(
                      builder: (context, ref, child) {
                        final state = ref.watch(editHabitProvider);
                        final currentTarget = state?.dailyTarget ?? 1;
                        return CupertinoListSection.insetGrouped(
                          header: Text(LocaleKeys.create_habit_reminder_daily_target_header.tr()),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Text(LocaleKeys.create_habit_reminder_completions_per_day.tr(), style: context.titleMedium),
                                ),
                                Row(
                                  children: [
                                    CupertinoButton(
                                      padding: const EdgeInsets.all(8),
                                      onPressed: () {
                                        final newValue = (currentTarget - 1) < 1 ? 1 : (currentTarget - 1);
                                        ref.read(editHabitProvider.notifier).updateDailyTarget(newValue);
                                      },
                                      child: const Icon(CupertinoIcons.minus_circle),
                                    ),
                                    Text(currentTarget.toString(), style: context.titleMedium),
                                    CupertinoButton(
                                      padding: const EdgeInsets.all(8),
                                      onPressed: () {
                                        final newValue = (currentTarget + 1) > 24 ? 24 : (currentTarget + 1);
                                        ref.read(editHabitProvider.notifier).updateDailyTarget(newValue);
                                      },
                                      child: const Icon(CupertinoIcons.plus_circle),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    // Completion Time
                    Consumer(
                      builder: (context, ref, child) {
                        final editHabitState = ref.watch(editHabitProvider);
                        return CompletionTimeWidget(
                          initialTime: editHabitState?.completionTime,
                          onCompletionTimeChanged: (completionTime) {
                            ref.read(editHabitProvider.notifier).updateCompletionTime(completionTime);
                          },
                        );
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
                      header: Text(LocaleKeys.edit_habit_category.tr()),
                    ),

                    // Color Selection

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
