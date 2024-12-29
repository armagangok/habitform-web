part of 'habit_bloc.dart';

@immutable
sealed class SingleHabitEvent {}

@immutable
class IdleHabitEvent extends SingleHabitEvent {}

@immutable
class FetchHabitsEvent extends SingleHabitEvent {}

@immutable
class SaveHabitsEvent extends SingleHabitEvent {}
