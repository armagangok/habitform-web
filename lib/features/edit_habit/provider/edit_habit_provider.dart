import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/models/habit/habit_model.dart';
import '../../../core/core.dart';
import '../../../core/widgets/habit_color_sheet/provider/habit_color_provider.dart';
import '../../../core/widgets/habit_icon/provider/habit_icon_provider.dart';
import '../../habit_detail/providers/habit_detail_provider.dart';
import '../../home/provider/home_provider.dart';
import '../../reminder/provider/reminder_provider.dart';

final editHabitProvider = AutoDisposeNotifierProvider<EditHabitNotifier, Habit?>(() {
  return EditHabitNotifier();
});

class EditHabitNotifier extends AutoDisposeNotifier<Habit?> {
  final habitNameController = TextEditingController();
  final habitDescriptionController = TextEditingController();

  @override
  Habit? build() => null;

  void initHabit(Habit habit) {
    habitNameController.text = habit.habitName;
    habitDescriptionController.text = habit.habitDescription ?? '';

    final reminder = habit.reminderModel;

    ref.watch(iconProvider.notifier).pickIcon(habit.emoji);
    ref.watch(colorProvider.notifier).pickColor(Color(habit.colorCode));

    ref.watch(reminderProvider.notifier).initializeReminder(reminder);
    state = habit;
  }

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

    // Mevcut alışkanlığın hatırlatıcısını al
    final currentReminderModel = state?.reminderModel;

    // Store references to notifiers before making any state changes
    final habitDetailNotifier = ref.read(habitDetailProvider.notifier);
    final homeNotifier = ref.read(homeProvider.notifier);
    final reminderNotifier = ref.read(reminderProvider.notifier);

    final updatedHabit = state?.copyWith(
      habitName: habitName,
      habitDescription: habitDescription,
      emoji: habitIconState,
      colorCode: habitColorState?.value,
      reminderModel: reminderModel,
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
