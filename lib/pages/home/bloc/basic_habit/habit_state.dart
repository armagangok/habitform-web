part of 'habit_bloc.dart';

@immutable
sealed class HabitState {}

final class HabitInitial extends HabitState {}

final class HabitsLoading extends HabitState {}

final class HabitsFetched extends HabitState {
  final List<Habit> habits;

  HabitsFetched(this.habits);
}

final class HabitsFetchError extends HabitState {
  final String message;

  HabitsFetchError(this.message);
}
