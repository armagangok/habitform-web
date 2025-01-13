import 'package:intl/intl.dart';

import '../../../models/models.dart';

void sortHabitsByReminderTime(List<Habit> habits) {
  // Saat formatını belirtin
  final timeFormat = DateFormat("HH:mm");

  habits.sort((a, b) {
    final timeA = a.reminderModel?.reminderTime;
    final timeB = b.reminderModel?.reminderTime;

    if (timeA == null && timeB == null) return 0; // İkisi de null ise eşit
    if (timeA == null) return 1; // Null olanlar sona gider
    if (timeB == null) return -1;

    final parsedTimeA = timeFormat.parse(timeA);
    final parsedTimeB = timeFormat.parse(timeB);

    return parsedTimeA.compareTo(parsedTimeB);
  });
}
