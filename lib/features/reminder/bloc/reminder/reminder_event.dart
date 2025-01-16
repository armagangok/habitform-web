// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'reminder_bloc.dart';

@immutable
sealed class ReminderEvent {}

class InitializeReminderEvent extends ReminderEvent {
  final ReminderModel? reminder;
  final BuildContext context;

  InitializeReminderEvent({
    this.reminder,
    required this.context,
  });
}

class CancelReminderEvent extends ReminderEvent {
  final ReminderModel? reminder;

  CancelReminderEvent({this.reminder});
}

class ScheduleReminderEvent extends ReminderEvent {
  final String title;
  final String body;

  ScheduleReminderEvent(this.title, this.body);
}

class UpdateReminderDaysEvent extends ReminderEvent {
  final List<Days>? days;

  UpdateReminderDaysEvent({required this.days});
}

class UpdateReminderTimeEvent extends ReminderEvent {
  final DateTime? time;

  UpdateReminderTimeEvent({required this.time});
}
