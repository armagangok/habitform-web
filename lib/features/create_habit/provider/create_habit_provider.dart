import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/habit/habit_model.dart';
import '../../habit_color/provider/habit_color_provider.dart';
import '../../habit_icon/provider/habit_icon_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../purchase/providers/purchase_provider.dart';
import '../../reminder/provider/reminder_provider.dart';
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
    final categoryIds = state.value?.categoryIds ?? [];

    state = const AsyncValue.loading();

    try {
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitName: habitName,
        habitDescription: habitDescription,
        emoji: emoji,
        colorCode: color?.value ?? Colors.blueAccent.value,
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
