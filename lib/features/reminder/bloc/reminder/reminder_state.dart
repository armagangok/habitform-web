part of "reminder_bloc.dart";

sealed class ReminderState {
  late final ReminderModel? reminder;
}

class ReminderStateInitial extends ReminderState {
  @override
  late final ReminderModel? reminder;

  ReminderStateInitial({this.reminder});

  ReminderStateInitial copyWith({ReminderModel? reminderModel}) {
    return ReminderStateInitial(
      reminder: reminderModel ?? reminder,
    );
  }
}

final class ReminderSelectionState extends ReminderState {
  ReminderSelectionState({this.reminder});
  @override
  late final ReminderModel? reminder;

  ReminderStateInitial copyWith({
    ReminderModel? reminderModel,
  }) {
    return ReminderStateInitial(
      reminder: reminderModel ?? reminder,
    );
  }
}
