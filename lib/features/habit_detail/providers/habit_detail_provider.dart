import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitrise/features/home/provider/home_provider.dart';

import '../../../core/core.dart';
import '../../../models/completion_entry/completion_entry.dart';
import '../../../models/habit/habit_model.dart';
import '../../../services/local_habit_service.dart';

final habitDetailProvider = AutoDisposeNotifierProvider<HabitDetailNotifier, Habit?>(() {
  return HabitDetailNotifier();
});

class HabitDetailNotifier extends AutoDisposeNotifier<Habit?> {
  final LocalHabitService _habitService = LocalHabitService.instance;

  @override
  Habit? build() => null;

  Future<void> updateHabit(Habit habit) async {
    try {
      await _habitService.updateHabit(habit);
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
      await _habitService.updateHabitCompletionStatus(habitId, completion);

      if (state != null) {
        final habits = await _habitService.getHabits();

        final updatedHabit = habits.firstWhere((h) => h.id == habitId);

        state = updatedHabit;

        ref.read(homeProvider.notifier).fetchHabits();
      }
    } catch (e, s) {
      LogHelper.shared.debugPrint("$e\n$s");
    }
  }
}
