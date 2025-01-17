import '../../../models/models.dart';

void sortHabitsByReminderTime(List<Habit> habits) {
  habits.sort((Habit a, Habit b) {
    final timeA = a.reminderModel?.reminderTime;
    final timeB = b.reminderModel?.reminderTime;

    if (timeA == null && timeB == null) return 0; // İkisi de null ise eşit
    if (timeA == null) return 1; // Null olanlar sona gider
    if (timeB == null) return -1;

    final parsedTimeA = timeA;
    final parsedTimeB = timeB;

    return parsedTimeA.compareTo(parsedTimeB);
  });
}
