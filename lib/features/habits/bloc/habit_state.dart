part of 'habit_bloc.dart';

@immutable
sealed class HabitState {}

final class HabitInitial extends HabitState {}

final class HabitLoading extends HabitState {}

final class HabitsFetched extends HabitState {
  final List<Habit> habits;

  HabitsFetched(this.habits);
}

final class HabitFetchError extends HabitState {
  final String message;

  HabitFetchError(this.message);
}

final class HabitSaveError extends HabitState {
  final String message;

  HabitSaveError(this.message);
}

final class HabitSaveSuccess extends HabitState {
  final String message;

  HabitSaveSuccess(this.message);
}
