part of 'habit_detail_bloc.dart';

@immutable
sealed class HabitDetailEvent {}

class InitializeHabitDetailEvent extends HabitDetailEvent {
  final Habit habit;

  InitializeHabitDetailEvent({required this.habit});
}

class UpdateHabitDetailEvent extends HabitDetailEvent {
  final Habit habit;

  UpdateHabitDetailEvent({required this.habit});
}
