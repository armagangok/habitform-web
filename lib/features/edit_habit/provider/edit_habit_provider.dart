import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_difficulty.dart';
import '/models/habit/habit_model.dart';
import '../../habit_category/provider/habit_category_button_provider.dart';
import '../../habit_category/provider/habit_category_provider.dart';
import '../../habit_color/provider/habit_color_provider.dart';
import '../../habit_detail/providers/habit_detail_provider.dart';
import '../../habit_emoji/provider/emoji_picker_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../reminder/provider/reminder_provider.dart';

final editHabitProvider = AutoDisposeNotifierProvider<EditHabitNotifier, Habit?>(() {
  return EditHabitNotifier();
});

class EditHabitNotifier extends AutoDisposeNotifier<Habit?> {
  final habitNameController = TextEditingController();
  final habitDescriptionController = TextEditingController();

  HabitDifficulty _selectedDifficulty = HabitDifficulty.moderate;
  double _selectedRewardFactor = 1.0;

  @override
  Habit? build() => null;

  void initHabit(Habit habit) {
    habitNameController.text = habit.habitName;
    habitDescriptionController.text = habit.habitDescription ?? '';
    _selectedDifficulty = habit.difficulty;
    _selectedRewardFactor = habit.rewardFactor;

    final reminder = habit.reminderModel;

    // Initialize emoji picker state for edit flow to match create flow
    if (habit.emoji != null && habit.emoji!.isNotEmpty) {
      ref.read(emojiPickerProvider.notifier).initializeWithSelectedIcon(habit.emoji);
    }
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
  double get selectedRewardFactor => _selectedRewardFactor;

  void updateDailyTarget(int target) {
    final clamped = target < 1 ? 1 : (target > 24 ? 24 : target);
    if (state != null) {
      state = state?.copyWith(dailyTarget: clamped);
    }
  }

  void updateRewardFactor(double rewardFactor) {
    // Clamp reward factor to valid range: 0.5 (low reward) to 2.0 (high reward)
    final clamped = rewardFactor.clamp(0.5, 2.0);
    _selectedRewardFactor = clamped;
    // Update the state to trigger UI rebuild
    if (state != null) {
      state = state?.copyWith(rewardFactor: clamped);
    }
  }

  void updateHabit() async {
    final habitName = habitNameController.text;

    if (habitName.isEmpty) {
      AppFlushbar.shared.warningFlushbar(LocaleKeys.edit_habit_name_cannot_be_empty.tr());
      return;
    }

    final habitDescription = habitDescriptionController.text;
    final reminderState = ref.watch(reminderProvider);
    final habitEmojiState = ref.watch(emojiPickerProvider).selectedEmoji;
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
      emoji: habitEmojiState ?? state?.emoji,
      colorCode: habitColorState?.value,
      reminderModel: reminderModel,
      categoryIds: categoryIds,
      difficulty: _selectedDifficulty,
      rewardFactor: _selectedRewardFactor,
    );

    if (updatedHabit != null) {
      // Update local state
      state = updatedHabit;

      // Use stored references to perform operations
      await habitDetailNotifier.updateHabit(updatedHabit);
      await homeNotifier.updateHabit(updatedHabit);

      // Hatırlatıcı bildirimi ayarla (değişiklik kontrolü ReminderNotifier içinde yapılacak)
      if (reminderModel != null) {
        final emoji = updatedHabit.emoji ?? '';
        final displayName = emoji.isNotEmpty ? '$emoji $habitName' : habitName;
        await reminderNotifier.scheduleReminder(
          title: displayName,
          body: LocaleKeys.reminder_personalized_body.tr(namedArgs: {'habit': displayName}),
          oldReminder: currentReminderModel,
          reminderToSchedule: reminderModel,
        );
      }

      // Fetch habits before navigating back
      await homeNotifier.fetchHabits();
    }
    navigator.pop();
  }

  void updateEmoji(String? emoji) {
    // Update provider state so UI reflects immediately
    if (emoji != null && emoji.isNotEmpty) {
      ref.read(emojiPickerProvider.notifier).selectEmoji(emoji, 0);
    } else {
      ref.read(emojiPickerProvider.notifier).clearSelection();
    }

    // Update local habit state for immediate UI feedback
    if (state != null) {
      state = state?.copyWith(emoji: emoji);
    }
  }
}
