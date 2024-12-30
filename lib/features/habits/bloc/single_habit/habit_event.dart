// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'habit_bloc.dart';

@immutable
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
