part of 'edit_habit_bloc.dart';

abstract class EditHabitEvent extends Equatable {
  const EditHabitEvent();

  @override
  List<Object> get props => [];
}

class UpdateHabitEvent extends EditHabitEvent {
  final Habit habit;

  const UpdateHabitEvent({required this.habit});

  @override
  List<Object> get props => [habit];
} 