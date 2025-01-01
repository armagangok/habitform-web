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

// @immutable
// class UpdateHabitForTodayEvent extends SingleHabitEvent {
//   final Habit habit;
//   UpdateHabitForTodayEvent({
//     required this.habit,
//   });
// }

@immutable
class UpdateHabitForSelectedDayEvent extends SingleHabitEvent {
  final Habit habit;
  final List<DateTime> days;
  final DateTime selectedDate;
  UpdateHabitForSelectedDayEvent({
    required this.habit,
    required this.days,
    required this.selectedDate,
  });
}
