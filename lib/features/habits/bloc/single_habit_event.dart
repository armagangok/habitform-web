// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'single_habit_bloc.dart';

sealed class SingleHabitEvent {}

@immutable
class IdleSingleHabitEvent extends SingleHabitEvent {}

@immutable
class FetchSingleHabitEvent extends SingleHabitEvent {}

@immutable
class SaveSingleHabitEvent extends SingleHabitEvent {
  final Habit habit;
  SaveSingleHabitEvent({
    required this.habit,
  });
}

@immutable
class DeleteSingleHabitEvent extends SingleHabitEvent {
  final Habit habit;
  DeleteSingleHabitEvent({
    required this.habit,
  });
}

class UpdateHabitForSelectedDayEvent extends SingleHabitEvent {
  Habit habit;
  DateTime dateToSaveOrRemove;

  UpdateHabitForSelectedDayEvent({
    required this.habit,
    required this.dateToSaveOrRemove,
  });
}

class UpdateSingleHabitEvent extends SingleHabitEvent {
  final Habit habit;

  UpdateSingleHabitEvent({required this.habit});
}
