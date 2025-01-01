part of 'single_habit_bloc.dart';

@immutable
sealed class SingleHabitState {}

final class SingleHabitInitial extends SingleHabitState {}

final class SingleHabitLoading extends SingleHabitState {}

final class SingleHabitsFetched extends SingleHabitState {
  final List<Habit> habits;

  SingleHabitsFetched(this.habits);
}

final class SingleHabitFetchError extends SingleHabitState {
  final String message;

  SingleHabitFetchError(this.message);
}

final class SingleHabitSaveError extends SingleHabitState {
  final String message;

  SingleHabitSaveError(this.message);
}

final class SingleHabitSaveSuccess extends SingleHabitState {
  final String message;

  SingleHabitSaveSuccess(this.message);
}

