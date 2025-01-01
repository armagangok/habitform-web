part of 'reminder_time_cubit.dart';

@immutable
sealed class ReminderTimeState {
  late final ReminderModel? reminderModel;
}

final class ReminderTimeCubitInitial extends ReminderTimeState {
  @override
  final ReminderModel? reminderModel;

  ReminderTimeCubitInitial({
    this.reminderModel,
  });
}

final class SelectTimeCubitInitial extends ReminderTimeState {
  @override
  final ReminderModel? reminderModel;

  SelectTimeCubitInitial({
    this.reminderModel,
  });
}
