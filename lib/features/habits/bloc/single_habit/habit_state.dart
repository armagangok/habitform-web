part of 'habit_bloc.dart';

@immutable
sealed class SingleHabitState {}

final class SingleHabitInitial extends SingleHabitState {}

final class SingleHabitLoading extends SingleHabitState {}

final class HabitsFetched extends SingleHabitState {
  final List<Habit> habits;

  HabitsFetched(this.habits);
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
