part of 'chain_habit_bloc.dart';

@immutable
sealed class ChainHabitEvent {}

@immutable
class FetchChainedHabitEvent extends ChainHabitEvent {}

@immutable
class SaveChainHabitEvent extends ChainHabitEvent {}
