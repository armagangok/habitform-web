part of 'edit_habit_bloc.dart';

abstract class IEditHabitEvent extends Equatable {
  const IEditHabitEvent();

  @override
  List<Object> get props => [];
}

class UpdateEditHabitEvent extends IEditHabitEvent {
  final Habit habit;

  const UpdateEditHabitEvent({required this.habit});

  @override
  List<Object> get props => [habit];
}

class InitializeHabitEvent extends IEditHabitEvent {
  final Habit habit;

  const InitializeHabitEvent({required this.habit});

  @override
  List<Object> get props => [habit];
}
