import '../../core/extension/datetime_extension.dart';
import '../../features/reminder/service/reminder_service.dart';
import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_extension.dart';
import '../../models/habit/habit_model.dart';
import '../../models/habit/habit_status.dart';
import '../../models/habit/habit_summary.dart';
import 'habit_service_interface.dart';
import 'mock_habit_data.dart';

class MockHabitService extends HabitService {
  // In-memory storage for habits
  final List<Habit> _habits = List.from(MockHabitData.habits);

  @override
  Future<List<Habit>> getAllHabits() async {
    return _habits;
  }

  @override
  Future<List<Habit>> getHabits() async {
    return _habits.where((habit) => habit.status == HabitStatus.active).toList();
  }

  @override
  Future<List<HabitSummary>> getHabitSummaries() async {
    final activeHabits = _habits.where((habit) => habit.status == HabitStatus.active).toList();
    final today = DateTime.now().normalized;
    final summaries = <HabitSummary>[];

    for (final habit in activeHabits) {
      // Calculate streak once during load
      final streak = habit.calculateCurrentStreak();

      // Extract today's completion data
      final todayCount = habit.getCountForDate(today);
      final target = habit.dailyTarget <= 0 ? 1 : habit.dailyTarget;
      final todayIsCompleted = todayCount >= target;

      summaries.add(HabitSummary(
        id: habit.id,
        habitName: habit.habitName,
        emoji: habit.emoji,
        colorCode: habit.colorCode,
        dailyTarget: habit.dailyTarget,
        categoryIds: habit.categoryIds,
        completionTime: habit.completionTime,
        todayCount: todayCount,
        todayIsCompleted: todayIsCompleted,
        currentStreak: streak,
      ));
    }

    return summaries;
  }

  @override
  Future<List<Habit>> getArchivedHabits() async {
    return _habits.where((habit) => habit.status == HabitStatus.archived).toList();
  }

  @override
  Future<Habit?> getHabit(String habitId) async {
    try {
      return _habits.firstWhere((habit) => habit.id == habitId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createHabit(Habit habit) async {
    _habits.add(habit);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }

  @override
  Future<void> updateHabitCompletionStatus(String habitId, CompletionEntry completion) async {
    final habit = await getHabit(habitId);
    if (habit != null) {
      final updatedCompletions = Map<String, CompletionEntry>.from(habit.completions);
      updatedCompletions[completion.id] = completion;

      final updatedHabit = habit.copyWith(
        completions: updatedCompletions,
      );

      await updateHabit(updatedHabit);
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    final habit = await getHabit(habitId);
    if (habit != null) {
      final updatedHabit = habit.copyWith(
        status: HabitStatus.archived,
      );
      await updateHabit(updatedHabit);
    }
  }

  @override
  Future<void> archiveHabit(Habit habit) async {
    // Cancel all reminder notifications before archiving
    if (habit.reminderModel != null) {
      await ReminderService.cancelAllReminderNotifications(habit.reminderModel);
    }

    final updatedHabit = habit.copyWith(
      status: HabitStatus.archived,
      archiveDate: DateTime.now(),
    );
    await updateHabit(updatedHabit);
  }

  @override
  Future<void> unarchiveHabit(String habitId) async {
    final habit = await getHabit(habitId);
    if (habit != null) {
      final updatedHabit = habit.copyWith(
        status: HabitStatus.active,
      );
      await updateHabit(updatedHabit);
    }
  }

  @override
  Future<void> permanentlyDeleteHabit(String habitId) async {
    _habits.removeWhere((habit) => habit.id == habitId);
  }

  @override
  Future<void> updateArchivedHabit(Habit habit) async {
    final updatedHabit = habit.copyWith(
      status: HabitStatus.archived,
      archiveDate: habit.archiveDate ?? DateTime.now(),
    );
    await updateHabit(updatedHabit);
  }
}
