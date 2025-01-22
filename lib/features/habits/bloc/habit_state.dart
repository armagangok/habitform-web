part of 'habit_bloc.dart';

@immutable
sealed class HabitState {}

final class SingleHabitInitial extends HabitState {}

final class SingleHabitLoading extends HabitState {}

final class HabitsFetched extends HabitState {
  final List<Habit> habits;

  HabitsFetched(this.habits);
}

final class SingleHabitFetchError extends HabitState {
  final String message;

  SingleHabitFetchError(this.message);
}

final class SingleHabitSaveError extends HabitState {
  final String message;

  SingleHabitSaveError(this.message);
}

final class SingleHabitSaveSuccess extends HabitState {
  final String message;

  SingleHabitSaveSuccess(this.message);
}
