import '../../../models/models.dart';

void sortHabitsByReminderTime(List<Habit> habits) {
  habits.sort((Habit a, Habit b) {
    final timeA = a.reminderModel?.reminderTime;
    final timeB = b.reminderModel?.reminderTime;

    if (timeA == null && timeB == null) return 0; // Both null, consider equal
    if (timeA == null) return 1; // Null values go to the end
    if (timeB == null) return -1;

    // Compare only the time part (hours and minutes)
    final timeAMinutes = timeA.hour * 60 + timeA.minute;
    final timeBMinutes = timeB.hour * 60 + timeB.minute;

    return timeAMinutes.compareTo(timeBMinutes);
  });
}
