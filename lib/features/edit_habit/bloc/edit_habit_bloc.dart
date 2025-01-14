import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/single_habit/habit_model.dart';
import '../../habits/bloc/single_habit/single_habit_bloc.dart';

part 'edit_habit_event.dart';
part 'edit_habit_state.dart';

class EditHabitBloc extends Bloc<EditHabitEvent, EditHabitState> {
  final SingleHabitBloc _singleHabitBloc;

  EditHabitBloc(this._singleHabitBloc) : super(EditHabitInitial()) {
    on<UpdateHabitEvent>(_onUpdateHabit);
  }

  Future<void> _onUpdateHabit(
    UpdateHabitEvent event,
    Emitter<EditHabitState> emit,
  ) async {
    emit(EditHabitLoading());
    try {
      _singleHabitBloc.add(UpdateSingleHabitEvent(habit: event.habit));
      emit(EditHabitSuccess());
    } catch (e) {
      emit(EditHabitFailure(error: e.toString()));
    }
  }
} 