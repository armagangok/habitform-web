part of 'chain_habit_bloc.dart';

sealed class ChainHabitState {}

final class ChainHabitInitial extends ChainHabitState {}

final class ChainHabitsLoading extends ChainHabitState {}

final class ChainHabitsFetched extends ChainHabitState {
  final List<ChainedHabit> habits;

  ChainHabitsFetched(this.habits);
}

final class ChainHabitsFetchError extends ChainHabitState {
  final String message;

  ChainHabitsFetchError(this.message);
}
