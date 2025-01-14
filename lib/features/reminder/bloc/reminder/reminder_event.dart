part of 'reminder_bloc.dart';

@immutable
sealed class ReminderEvent {}

class UpdateReminderTime extends ReminderEvent {}

class SetReminderEvent extends ReminderEvent {
  final ReminderModel reminder;

  SetReminderEvent({required this.reminder});
}
