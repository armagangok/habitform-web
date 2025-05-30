import 'habit_model.dart';
import 'habit_status.dart';

extension EasyHabitStatus on Habit {
  bool get isActive => status == HabitStatus.active;
  bool get isArchived => status == HabitStatus.archived;
}

extension EasySort on List<Habit> {
  List<Habit> get sortHabitsByTime {
    final sortedHabits = this
      ..sort((a, b) {
        // Habits without reminder time go at the end
        if (a.reminderModel?.reminderTime == null && b.reminderModel?.reminderTime == null) {
          return 0; // Both have no reminder time, keep original order
        }
        if (a.reminderModel?.reminderTime == null) {
          return 1; // a goes after b
        }
        if (b.reminderModel?.reminderTime == null) {
          return -1; // a goes before b
        }

        // Compare only the time part of the day (ignoring date)
        final aTime = a.reminderModel!.reminderTime!;
        final bTime = b.reminderModel!.reminderTime!;

        // Create DateTime objects with just the hour and minute for comparison
        final aTimeOnly = DateTime(0, 0, 0, aTime.hour, aTime.minute);
        final bTimeOnly = DateTime(0, 0, 0, bTime.hour, bTime.minute);

        return aTimeOnly.compareTo(bTimeOnly);
      });

    return sortedHabits;
  }
}
