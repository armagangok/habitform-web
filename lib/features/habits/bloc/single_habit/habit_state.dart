part of 'habit_bloc.dart';

@immutable
sealed class SingleHabitState {}

final class HabitInitial extends SingleHabitState {}

final class HabitsLoading extends SingleHabitState {}

final class HabitsFetched extends SingleHabitState {
  final List<Habit> habits;

  HabitsFetched(this.habits);
}

final class HabitsFetchError extends SingleHabitState {
  final String message;

  HabitsFetchError(this.message);
}
