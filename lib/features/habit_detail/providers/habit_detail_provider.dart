import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../models/completion_entry/completion_entry.dart';
import '../../../models/habit/habit_model.dart';
import '../../../services/habit_service/habit_service_interface.dart';
import '../../home/provider/home_provider.dart';

final habitDetailProvider = AutoDisposeNotifierProvider<HabitDetailNotifier, Habit?>(() {
  return HabitDetailNotifier();
});

class HabitDetailNotifier extends AutoDisposeNotifier<Habit?> {
  @override
  Habit? build() => null;

  Future<void> updateHabit(Habit habit) async {
    try {
      await habitService.updateHabit(habit);
      state = habit;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setHabit(Habit habit) async {
    state = habit;
  }

  Future<void> markHabitAsComplete(String habitId, CompletionEntry completion) async {
    try {
      await habitService.updateHabitCompletionStatus(habitId, completion);

      if (state != null) {
        final habits = await habitService.getHabits();

        final updatedHabit = habits.firstWhere((h) => h.id == habitId);

        state = updatedHabit;

        ref.read(homeProvider.notifier).fetchHabits();
      }
    } catch (e, s) {
      LogHelper.shared.debugPrint("$e\n$s");
    }
  }
}
