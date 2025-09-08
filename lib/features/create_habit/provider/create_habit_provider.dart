import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/habit/habit_difficulty.dart';
import '../../../models/habit/habit_model.dart';
import '../../habit_category/provider/habit_category_button_provider.dart';
import '../../habit_color/provider/habit_color_provider.dart';
import '../../habit_icon/provider/habit_icon_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../purchase/providers/purchase_provider.dart';
import '../../reminder/provider/reminder_provider.dart';
import '../models/create_habit_step.dart';
import 'create_habit_state.dart';

final createHabitProvider = AutoDisposeAsyncNotifierProvider<CreateHabitNotifier, CreateHabitState>(() {
  return CreateHabitNotifier();
});

class CreateHabitNotifier extends AutoDisposeAsyncNotifier<CreateHabitState> {
  @override
  Future<CreateHabitState> build() async {
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
    final value = state.value;
    if (value == null) return false;
    switch (value.currentStep) {
      case CreateHabitStep.habitName:
        return value.habitNameController.text.trim().isNotEmpty;
      case CreateHabitStep.description:
        return true; // optional
      case CreateHabitStep.emoji:
        return ref.read(iconProvider) != null || (value.emoji != null && value.emoji!.isNotEmpty);
      case CreateHabitStep.color:
        return ref.read(colorProvider) != null || value.colorCode != null;
      case CreateHabitStep.reminder:
        return true; // optional
      case CreateHabitStep.category:
        return true; // optional multi-select
      case CreateHabitStep.difficulty:
        return true; // always selectable
    }
  }

  void nextStep() {
    final value = state.value;
    if (value == null) return;
    final next = value.currentStep.nextStep;
    if (next != null) {
      state = AsyncValue.data(value.copyWith(currentStep: next));
    } else {
      // No next step, create habit
      createHabit();
    }
  }

  void previousStep() {
    final value = state.value;
    if (value == null) return;
    final prev = value.currentStep.previousStep;
    if (prev != null) {
      state = AsyncValue.data(value.copyWith(currentStep: prev));
    }
  }

  // Updaters used by steps
  void updateEmoji(String? emoji) {
    final value = state.value ?? CreateHabitState();
    ref.read(iconProvider.notifier).pickIcon(emoji);
    state = AsyncValue.data(value.copyWith(emoji: emoji));
  }

  void updateColorCode(int colorValue) {
    final value = state.value ?? CreateHabitState();
    ref.read(colorProvider.notifier).pickColor(Color(colorValue));
    state = AsyncValue.data(value.copyWith(colorCode: colorValue));
  }

  void updateDifficulty(HabitDifficulty difficulty) {
    final value = state.value ?? CreateHabitState();
    state = AsyncValue.data(value.copyWith(difficulty: difficulty));
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
    final habitName = state.value?.habitNameController.text;
    final habitDescription = state.value?.habitDescriptionController.text;
    if (habitName == null || habitName.isEmpty) {
      AppFlushbar.shared.warningFlushbar(LocaleKeys.errors_required_field.tr());
      return;
    }

    final emoji = ref.watch(iconProvider);
    final color = ref.watch(colorProvider);
    final reminder = ref.watch(reminderProvider).reminder;
    final categoryIds = ref.read(categoryButtonProvider) ?? [];

    state = const AsyncValue.loading();
    final defaultColor = NavigationService.shared.navigatorKey.currentContext?.theme.primaryColor.value;

    try {
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitName: habitName,
        habitDescription: habitDescription,
        emoji: emoji,
        colorCode: color?.value ?? defaultColor ?? Colors.blueAccent.value,
        reminderModel: reminder,
        categoryIds: categoryIds,
      );

      await ref.read(homeProvider.notifier).createHabit(habit);

      if (reminder != null) {
        LogHelper.shared.debugPrint('Scheduling reminder for new habit: $reminder');
        await ref.read(reminderProvider.notifier).scheduleReminder(
              title: habitName,
              body: LocaleKeys.reminder_habit_reminder_message.tr(),
            );
      } else {
        LogHelper.shared.debugPrint('No reminder to schedule for new habit');
      }

      // Clear category selection after successful habit creation
      ref.read(categoryButtonProvider.notifier).clearCategories();

      state = AsyncValue.data(CreateHabitState());

      navigator.pop();
    } catch (e, stack) {
      LogHelper.shared.debugPrint("$e\n$stack");
      state = AsyncValue.error(
        LocaleKeys.errors_something_went_wrong.tr(),
        stack,
      );
    }
  }
}
