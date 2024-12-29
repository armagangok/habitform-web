import '../features/add_habit/widgets/add_reminder.dart';

class ReminderModel {
  final DateTime? reminderTime;
  final Set<Days>? days;

  ReminderModel({
    this.reminderTime,
    this.days,
  });

  ReminderModel copyWith({
    DateTime? reminderTime,
    Set<Days>? days,
  }) {
    return ReminderModel(
      reminderTime: reminderTime ?? this.reminderTime,
      days: days ?? this.days,
    );
  }
}
