part of 'reminder_bloc.dart';

sealed class ReminderState {
  final ReminderModel? reminder;

  ReminderState({this.reminder});
}

class ReminderStateInitial extends ReminderState {
  ReminderStateInitial({super.reminder});

  ReminderStateInitial copyWith({ReminderModel? reminder}) {
    return ReminderStateInitial(reminder: reminder ?? this.reminder);
  }
}

class ReminderSelectionState extends ReminderState {
  ReminderSelectionState({super.reminder});

  ReminderSelectionState copyWith({ReminderModel? reminder}) {
    return ReminderSelectionState(reminder: reminder ?? this.reminder);
  }
}

class CancelReminderState extends ReminderState {
  CancelReminderState({super.reminder});

  CancelReminderState copyWith({ReminderModel? reminder}) {
    return CancelReminderState(reminder: reminder ?? this.reminder);
  }
}
