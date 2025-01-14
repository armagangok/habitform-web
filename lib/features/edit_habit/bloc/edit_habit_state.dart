part of 'edit_habit_bloc.dart';

abstract class EditHabitState extends Equatable {
  const EditHabitState();
  
  @override
  List<Object> get props => [];
}

class EditHabitInitial extends EditHabitState {}

class EditHabitLoading extends EditHabitState {}

class EditHabitSuccess extends EditHabitState {}

class EditHabitFailure extends EditHabitState {
  final String error;

  const EditHabitFailure({required this.error});

  @override
  List<Object> get props => [error];
} 