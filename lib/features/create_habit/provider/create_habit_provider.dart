import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/habit/habit_difficulty.dart';
import '../../../models/habit/habit_model.dart';
import '../../habit_category/provider/habit_category_button_provider.dart';
import '../../habit_color/provider/habit_color_provider.dart';
import '../../habit_emoji/provider/emoji_picker_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../purchase/providers/purchase_provider.dart';
import '../../reminder/models/reminder/reminder_model.dart';
import '../../reminder/provider/reminder_provider.dart';
import '../models/create_habit_state.dart';

final createHabitProvider = AutoDisposeNotifierProvider<CreateHabitNotifier, CreateHabitState>(() {
  return CreateHabitNotifier();
});

class CreateHabitNotifier extends AutoDisposeNotifier<CreateHabitState> {
  @override
  CreateHabitState build() {
    return CreateHabitState();
  }

  Future<bool> get isProUser async {
    final purchaseState = ref.read(purchaseProvider);
    return purchaseState.value?.isSubscriptionActive ?? false;
  }

  Future<bool> canCreateHabit(int currentHabitCount) async {
    final isPro = await isProUser;
    if (isPro) return true;
    return currentHabitCount <= 1;
  }

  // Navigation helpers
  bool isCurrentStepValid() {
    switch (state.currentStep) {
      case CreateHabitStep.habitName:
        return state.habitNameController.text.trim().isNotEmpty;
      case CreateHabitStep.description:
        return true; // optional
      case CreateHabitStep.emoji:
        return true; // optional
      case CreateHabitStep.color:
        return state.colorCode != null;
      case CreateHabitStep.reminder:
        return true; // optional
      case CreateHabitStep.category:
        return true; // optional multi-select
      case CreateHabitStep.difficulty:
        return state.dailyTarget >= 1 && state.dailyTarget <= 24; // daily target sanity
    }
  }

  void nextStep() {
    final next = state.currentStep.nextStep;
    if (next != null) {
      state = state.copyWith(currentStep: next);
    } else {
      // No next step, create habit
      createHabit();
    }
  }

  void previousStep() {
    final prev = state.currentStep.previousStep;
    if (prev != null) {
      state = state.copyWith(currentStep: prev);
    }
  }

  // Updaters used by steps
  void updateEmoji(String? emoji) {
    // Update the create habit state
    state = state.copyWith(emoji: emoji);
  }

  void updateColorCode(int colorValue) {
    ref.read(colorProvider.notifier).pickColor(Color(colorValue));
    state = state.copyWith(colorCode: colorValue);
  }

  void updateDifficulty(HabitDifficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  void updateDailyTarget(int target) {
    final clamped = target < 1 ? 1 : (target > 24 ? 24 : target);
    state = state.copyWith(dailyTarget: clamped);
  }

  void updateRewardFactor(double rewardFactor) {
    // Clamp reward factor to valid range: 0.5 (low reward) to 2.0 (high reward)
    final clamped = rewardFactor.clamp(0.5, 2.0);
    state = state.copyWith(rewardFactor: clamped);
  }

  void updateReminder(ReminderModel? reminder) {
    state = state.copyWith(reminder: reminder);

    // Also update the reminder provider to keep it in sync
    if (reminder != null) {
      ref.read(reminderProvider.notifier).initializeReminder(reminder);
    }
  }

  void updateCompletionTime(DateTime? completionTime) {
    if (completionTime == null) {
      // Use clearCompletionTime flag to explicitly set to null
      state = state.copyWith(clearCompletionTime: true);
    } else {
      state = state.copyWith(completionTime: completionTime);
    }
  }

  void updateCategories(List<String> categoryIds) {
    state = state.copyWith(categoryIds: categoryIds);

    // Also update the category provider to keep it in sync
    ref.read(categoryButtonProvider.notifier).setSelectedCategories(categoryIds);
  }

  // // Set category IDs for the habit
  // void setCategoryIds(List<String> categoryIds) {
  //   if (state.value != null) {
  //     state = AsyncValue.data(state.value!.copyWith(categoryIds: categoryIds));
  //   } else {
  //     state = AsyncValue.data(CreateHabitState(categoryIds: categoryIds));
  //   }
  // }

  Future<void> createHabit() async {
    final habitName = state.habitNameController.text;
    final habitDescription = state.habitDescriptionController.text;
    if (habitName.trim().isEmpty) {
      AppFlushbar.shared.warningFlushbar(LocaleKeys.errors_required_field.tr());
      return;
    }

    final emoji = ref.read(emojiPickerProvider);
    final color = ref.read(colorProvider);
    final reminder = state.reminder ?? ref.read(reminderProvider).reminder;
    final categoryIds = state.categoryIds.isNotEmpty ? state.categoryIds : (ref.read(categoryButtonProvider) ?? []);

    final defaultColor = NavigationService.shared.navigatorKey.currentContext?.theme.primaryColor.value;

    try {
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitName: habitName.trim(),
        habitDescription: habitDescription.trim().isEmpty ? null : habitDescription.trim(),
        emoji: emoji.selectedEmoji ?? state.emoji ?? '📝',
        colorCode: color?.value ?? state.colorCode ?? defaultColor ?? Colors.blueAccent.value,
        reminderModel: reminder,
        dailyTarget: state.dailyTarget,
        categoryIds: categoryIds,
        difficulty: state.difficulty,
        rewardFactor: state.rewardFactor,
        completionTime: state.completionTime,
      );

      await ref.watch(homeProvider.notifier).createHabit(habit);

      if (reminder != null) {
        LogHelper.shared.debugPrint('Scheduling reminder for new habit: $reminder');
        final displayName = (habit.emoji != null && habit.emoji!.isNotEmpty) ? '${habit.emoji} $habitName' : habitName;
        await ref.watch(reminderProvider.notifier).scheduleReminder(
              title: displayName,
              body: LocaleKeys.reminder_personalized_body.tr(namedArgs: {'habit': displayName}),
              reminderToSchedule: reminder,
            );
      } else {
        LogHelper.shared.debugPrint('No reminder to schedule for new habit');
      }

      // Clear category selection after successful habit creation
      ref.read(categoryButtonProvider.notifier).clearCategories();

      // Clear emoji selection after successful habit creation
      ref.read(emojiPickerProvider.notifier).clearSelection();

      // Reset state and navigate back
      state = CreateHabitState();
      navigator.pop();
    } catch (e, stack) {
      LogHelper.shared.debugPrint("$e\n$stack");
      AppFlushbar.shared.errorFlushbar(LocaleKeys.errors_something_went_wrong.tr());
    }
  }
}
