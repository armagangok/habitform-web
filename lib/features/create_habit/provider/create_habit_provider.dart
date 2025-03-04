import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/widgets/habit_color_sheet/provider/habit_color_provider.dart';
import '../../../core/widgets/habit_icon/provider/habit_icon_provider.dart';
import '../../../models/habit/habit_model.dart';
import '../../home/provider/home_provider.dart';
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

    state = const AsyncValue.loading();

    try {
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitName: habitName,
        habitDescription: habitDescription,
        emoji: emoji,
        colorCode: color?.value ?? Colors.deepOrangeAccent.value,
        reminderModel: reminder,
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
