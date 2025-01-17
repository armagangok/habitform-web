part of 'habit_detail_bloc.dart';

@immutable
sealed class HabitDetailState {}

class HabitDetailInitial extends HabitDetailState {}

class HabitDetailLoaded extends HabitDetailState {
  final Habit habit;

  HabitDetailLoaded({required this.habit});
}
