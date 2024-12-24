part of 'habit_bloc.dart';

@immutable
sealed class HabitEvent {}

@immutable
class IdleHabitEvent extends HabitEvent {}

@immutable
class FetchHabitsEvent extends HabitEvent {}

@immutable
class SaveHabitsEvent extends HabitEvent {}
