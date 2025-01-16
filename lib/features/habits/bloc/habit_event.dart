// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'habit_bloc.dart';

sealed class HabitEvent {}

@immutable
class IdleHabitEvent extends HabitEvent {}

@immutable
class FetchHabitEvent extends HabitEvent {}

@immutable
class SaveHabitEvent extends HabitEvent {
  final Habit habit;
  SaveHabitEvent({
    required this.habit,
  });
}

@immutable
class DeleteHabitEvent extends HabitEvent {
  final Habit habit;
  DeleteHabitEvent({
    required this.habit,
  });
}

class UpdateHabitForSelectedDayEvent extends HabitEvent {
  Habit habit;
  DateTime dateToSaveOrRemove;

  UpdateHabitForSelectedDayEvent({
    required this.habit,
    required this.dateToSaveOrRemove,
  });
}

class UpdateHabitEvent extends HabitEvent {
  final Habit habit;

  UpdateHabitEvent({required this.habit});
}
