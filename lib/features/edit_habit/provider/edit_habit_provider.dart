import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_difficulty.dart';
import '/models/habit/habit_model.dart';
import '../../habit_category/provider/habit_category_button_provider.dart';
import '../../habit_category/provider/habit_category_provider.dart';
import '../../habit_color/provider/habit_color_provider.dart';
import '../../habit_detail/providers/habit_detail_provider.dart';
import '../../habit_icon/provider/habit_icon_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../reminder/provider/reminder_provider.dart';

final editHabitProvider = AutoDisposeNotifierProvider<EditHabitNotifier, Habit?>(() {
  return EditHabitNotifier();
});

class EditHabitNotifier extends AutoDisposeNotifier<Habit?> {
  final habitNameController = TextEditingController();
  final habitDescriptionController = TextEditingController();

  HabitDifficulty _selectedDifficulty = HabitDifficulty.moderate;

  @override
  Habit? build() => null;

  void initHabit(Habit habit) {
    habitNameController.text = habit.habitName;
    habitDescriptionController.text = habit.habitDescription ?? '';
    _selectedDifficulty = habit.difficulty;

    final reminder = habit.reminderModel;

    ref.watch(iconProvider.notifier).pickIcon(habit.emoji);
    ref.watch(colorProvider.notifier).pickColor(Color(habit.colorCode));

    ref.watch(habitCategoryProvider.notifier).setSelectedCategories(habit.categoryIds.toSet());
    ref.watch(categoryButtonProvider.notifier).setSelectedCategories(habit.categoryIds);

    ref.watch(reminderProvider.notifier).initializeReminder(reminder);
    state = habit;
  }

  void updateDifficulty(HabitDifficulty difficulty) {
    _selectedDifficulty = difficulty;
    // Update the state to trigger UI rebuild
    if (state != null) {
      state = state?.copyWith(difficulty: difficulty);
    }
  }

  HabitDifficulty get selectedDifficulty => _selectedDifficulty;

  void updateHabit() async {
    final habitName = habitNameController.text;

    if (habitName.isEmpty) {
      AppFlushbar.shared.warningFlushbar(LocaleKeys.edit_habit_name_cannot_be_empty.tr());
      return;
    }

    final habitDescription = habitDescriptionController.text;
    final reminderState = ref.watch(reminderProvider);
    final habitIconState = ref.watch(iconProvider);
    final habitColorState = ref.watch(colorProvider);
    final reminderModel = reminderState.reminder;

    final categoryIds = ref.watch(categoryButtonProvider) ?? [];

    // Mevcut alışkanlığın hatırlatıcısını al
    final currentReminderModel = state?.reminderModel;

    // Store references to notifiers before making any state changes
    final habitDetailNotifier = ref.watch(habitDetailProvider.notifier);
    final homeNotifier = ref.watch(homeProvider.notifier);
    final reminderNotifier = ref.watch(reminderProvider.notifier);

    final updatedHabit = state?.copyWith(
      habitName: habitName,
      habitDescription: habitDescription,
      emoji: habitIconState,
      colorCode: habitColorState?.value,
      reminderModel: reminderModel,
      categoryIds: categoryIds,
      difficulty: _selectedDifficulty,
    );

    if (updatedHabit != null) {
      // Update local state
      state = updatedHabit;

      // Use stored references to perform operations
      await habitDetailNotifier.updateHabit(updatedHabit);
      await homeNotifier.updateHabit(updatedHabit);

      // Hatırlatıcı bildirimi ayarla (değişiklik kontrolü ReminderNotifier içinde yapılacak)
      if (reminderModel != null) {
        await reminderNotifier.scheduleReminder(
          title: habitName,
          body: LocaleKeys.reminder_habit_reminder_message.tr(),
          oldReminder: currentReminderModel,
        );
      }

      // Fetch habits before navigating back
      await homeNotifier.fetchHabits();
    }
    navigator.pop();
  }
}
